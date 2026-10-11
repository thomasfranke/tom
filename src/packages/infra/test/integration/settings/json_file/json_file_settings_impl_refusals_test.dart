/// [JsonFileSettingsImpl] where the file is not the store's alone: a second
/// store over it, and a disk that will not hand it over or take it back.
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Why a test that takes a permission away does not run everywhere: Windows
/// has no POSIX modes, and root is refused nothing.
Object get _needsModes {
  if (Platform.isWindows) {
    return 'chmod does not model POSIX permissions on Windows';
  }
  final Object uid = Process.runSync('id', <String>['-u']).stdout as Object;
  return '$uid'.trim() == '0' ? 'root is refused nothing' : false;
}

void main() {
  late Directory tempDir;
  late String path;

  /// A store of its own over the one file, as a second window would have.
  JsonFileSettingsImpl store() => JsonFileSettingsImpl(
    filesystem: const DartIoFilesystemImpl(),
    path: path,
  );

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  /// A failure whose cause is the disk's own [C].
  Matcher unavailableOver<C extends FilesystemFailure>() =>
      isA<Failure<Object?, SettingsFailure>>().having(
        (Failure<Object?, SettingsFailure> it) => it.failure.cause,
        'cause',
        isA<C>(),
      );

  /// The names beside the settings file, sorted.
  List<String> namesBeside() => <String>[
    for (final FileSystemEntity entity in File(
      path,
    ).parent.listSync(followLinks: false))
      entity.uri.pathSegments.lastWhere((String it) => it.isNotEmpty),
  ]..sort();

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_settings_refusals_');
    path = '${tempDir.path}/tom/preferences.json';
  });

  tearDown(() {
    if (!Platform.isWindows) {
      Process.runSync('chmod', <String>['-R', 'u+rwx', tempDir.path]);
    }
    tempDir.deleteSync(recursive: true);
  });

  group('two stores over one file', () {
    test('one after the other, on different keys, keep both', () async {
      final JsonFileSettingsImpl first = store();
      final JsonFileSettingsImpl second = store();

      valueOf(
        await first.write('app.preferences', <String, Object?>{
          'theme': 'dark',
        }),
      );
      valueOf(await second.write('spaces.recent', <String>['/code/docs']));

      expect(valueOf(await first.read('spaces.recent')), <String>[
        '/code/docs',
      ]);
      expect(valueOf(await second.read('app.preferences')), <String, Object?>{
        'theme': 'dark',
      });
    });

    test('a removal by one is what the other reads next', () async {
      final JsonFileSettingsImpl first = store();
      final JsonFileSettingsImpl second = store();
      valueOf(await first.write('theme', 'dark'));

      valueOf(await second.remove('theme'));

      expect(valueOf(await first.read('theme')), isNull);
    });

    // The last write wins, by the maintainer's decision #23 — two windows
    // are not supported. What is pinned is what must hold even so: the file
    // is never half of each.
    test('at once: every write succeeds, the file stays one JSON object '
        'holding whole values, and no temporary is left', () async {
      final List<JsonFileSettingsImpl> stores = <JsonFileSettingsImpl>[
        for (int i = 0; i < 12; i++) store(),
      ];

      final List<Result<void, SettingsFailure>> written = await Future.wait(
        <Future<Result<void, SettingsFailure>>>[
          for (int i = 0; i < stores.length; i++)
            stores[i].write('key$i', <String, Object?>{
              'writer': i,
              'padding': 'x' * 4000,
            }),
        ],
      );

      expect(written, everyElement(isA<Success<void, SettingsFailure>>()));
      final Object? onDisk = jsonDecode(File(path).readAsStringSync());
      expect(onDisk, isA<Map<String, Object?>>());
      final Map<String, Object?> all = onDisk! as Map<String, Object?>;
      expect(all, isNotEmpty);
      for (final MapEntry<String, Object?> entry in all.entries) {
        final int writer = int.parse(entry.key.substring(3));
        expect(entry.value, <String, Object?>{
          'writer': writer,
          'padding': 'x' * 4000,
        });
      }
      expect(namesBeside(), <String>['preferences.json']);
    });
  });

  group('a file the machine will not open', () {
    test('fails the read, refuses the write and the removal, and is left '
        'as it was', () async {
      const String text = '{\n  "theme": "dark"\n}';
      File(path)
        ..createSync(recursive: true)
        ..writeAsStringSync(text);
      Process.runSync('chmod', <String>['000', path]);
      final JsonFileSettingsImpl settings = store();

      final Result<Object?, SettingsFailure> read = await settings.read(
        'theme',
      );
      final Result<void, SettingsFailure> written = await settings.write(
        'theme',
        'light',
      );
      final Result<void, SettingsFailure> removed = await settings.remove(
        'theme',
      );

      Process.runSync('chmod', <String>['644', path]);
      expect(read, unavailableOver<FilesystemAccessDenied>());
      expect(written, isA<Failure<void, SettingsFailure>>());
      expect(removed, isA<Failure<void, SettingsFailure>>());
      expect(File(path).readAsStringSync(), text);
      expect(namesBeside(), <String>['preferences.json']);
    }, skip: _needsModes);
  });

  group('a file that is not text', () {
    test('fails the read and is never written over', () async {
      final List<int> bytes = <int>[0x7B, 0x22, 0xE7, 0xE3, 0x6F, 0x22, 0x7D];
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);
      final JsonFileSettingsImpl settings = store();

      final Result<Object?, SettingsFailure> read = await settings.read(
        'theme',
      );
      final Result<void, SettingsFailure> written = await settings.write(
        'theme',
        'dark',
      );
      final Result<void, SettingsFailure> removed = await settings.remove(
        'theme',
      );

      expect(read, unavailableOver<FilesystemNotUtf8>());
      expect(written, isA<Failure<void, SettingsFailure>>());
      expect(removed, isA<Failure<void, SettingsFailure>>());
      expect(File(path).readAsBytesSync(), bytes);
    });
  });

  group('a path that is a folder', () {
    test('fails the read and the write, and the folder keeps what it '
        'held', () async {
      File('$path/inside.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync('kept');
      final JsonFileSettingsImpl settings = store();

      final Result<Object?, SettingsFailure> read = await settings.read(
        'theme',
      );
      final Result<void, SettingsFailure> written = await settings.write(
        'theme',
        'dark',
      );

      expect(read, unavailableOver<FilesystemOperationFailed>());
      expect(written, isA<Failure<void, SettingsFailure>>());
      expect(File('$path/inside.txt').readAsStringSync(), 'kept');
      expect(namesBeside(), <String>['preferences.json']);
    });
  });

  group('a folder that refuses writes', () {
    test('the stored value is still read; a write and a removal fail over '
        'the refusal, and the file is as it was', () async {
      const String text = '{\n  "theme": "dark"\n}';
      File(path)
        ..createSync(recursive: true)
        ..writeAsStringSync(text);
      Process.runSync('chmod', <String>['555', File(path).parent.path]);
      final JsonFileSettingsImpl settings = store();

      final Result<Object?, SettingsFailure> read = await settings.read(
        'theme',
      );
      final Result<void, SettingsFailure> written = await settings.write(
        'theme',
        'light',
      );
      final Result<void, SettingsFailure> removed = await settings.remove(
        'theme',
      );

      expect(valueOf(read), 'dark');
      expect(written, unavailableOver<FilesystemAccessDenied>());
      expect(removed, unavailableOver<FilesystemAccessDenied>());
      expect(File(path).readAsStringSync(), text);
      expect(namesBeside(), <String>['preferences.json']);
    }, skip: _needsModes);

    test('a first write, with no file yet, fails and creates none', () async {
      Directory(File(path).parent.path).createSync(recursive: true);
      Process.runSync('chmod', <String>['555', File(path).parent.path]);

      final Result<void, SettingsFailure> written = await store().write(
        'theme',
        'dark',
      );

      expect(written, unavailableOver<FilesystemAccessDenied>());
      expect(namesBeside(), isEmpty);
    }, skip: _needsModes);
  });

  group('a value JSON cannot hold', () {
    test('is this capability\'s failure, and the file keeps every key it '
        'had', () async {
      final JsonFileSettingsImpl settings = store();
      valueOf(await settings.write('theme', 'dark'));
      final String before = File(path).readAsStringSync();

      final Result<void, SettingsFailure> written = await settings.write(
        'opened',
        DateTime(2026, 10, 10),
      );
      final Result<void, SettingsFailure> nested = await settings.write(
        'theme',
        <String, Object?>{'when': DateTime(2026, 10, 10)},
      );

      expect(written, isA<Failure<void, SettingsFailure>>());
      expect(nested, isA<Failure<void, SettingsFailure>>());
      expect(File(path).readAsStringSync(), before);
      expect(valueOf(await settings.read('theme')), 'dark');
      expect(namesBeside(), <String>['preferences.json']);
    });

    test('on a first run creates no file', () async {
      final Result<void, SettingsFailure> written = await store().write(
        'opened',
        DateTime(2026, 10, 10),
      );

      expect(written, isA<Failure<void, SettingsFailure>>());
      expect(File(path).existsSync(), isFalse);
    });

    test('a number that is not one — NaN — is refused the same way', () async {
      final JsonFileSettingsImpl settings = store();
      valueOf(await settings.write('theme', 'dark'));
      final String before = File(path).readAsStringSync();

      final Result<void, SettingsFailure> written = await settings.write(
        'width',
        double.nan,
      );

      expect(written, isA<Failure<void, SettingsFailure>>());
      expect(File(path).readAsStringSync(), before);
    });
  });

  group('a broken file', () {
    for (final (String what, String text) in <(String, String)>[
      ('half an object', '{"theme": "dark",'),
      ('a JSON list', '["dark"]'),
      ('a bare string', '"dark"'),
      ('somebody\'s notes', 'theme = dark\n'),
    ]) {
      test('holding $what is not written over by a removal', () async {
        File(path)
          ..createSync(recursive: true)
          ..writeAsStringSync(text);

        final Result<void, SettingsFailure> removed = await store().remove(
          'theme',
        );

        expect(removed, isA<Failure<void, SettingsFailure>>());
        expect(File(path).readAsStringSync(), text);
        expect(namesBeside(), <String>['preferences.json']);
      });
    }
  });
}
