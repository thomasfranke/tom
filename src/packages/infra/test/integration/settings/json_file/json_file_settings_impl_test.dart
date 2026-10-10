/// [JsonFileSettingsImpl] against a real file.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late String path;
  late JsonFileSettingsImpl settings;

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_settings_');
    // Deliberately inside a folder that does not exist yet: the store must
    // not require anyone to have created it.
    path = '${tempDir.path}/nested/preferences.json';
    settings = JsonFileSettingsImpl(
      filesystem: const DartIoFilesystemImpl(),
      path: path,
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('the first run', () {
    test('reads null rather than failing', () async {
      expect(valueOf(await settings.read('recent')), isNull);
    });

    test('writing creates the file and the folders above it', () async {
      valueOf(await settings.write('recent', <String>['/code/app']));

      expect(File(path).existsSync(), isTrue);
    });

    test('removing what was never there succeeds', () async {
      expect(
        await settings.remove('recent'),
        isA<Success<void, SettingsFailure>>(),
      );
    });
  });

  group('storing and reading back', () {
    test('a value survives a new store over the same file', () async {
      valueOf(await settings.write('theme', 'dark'));

      final JsonFileSettingsImpl reopened = JsonFileSettingsImpl(
        filesystem: const DartIoFilesystemImpl(),
        path: path,
      );
      expect(valueOf(await reopened.read('theme')), 'dark');
    });

    test('writing one key leaves the others alone', () async {
      valueOf(await settings.write('theme', 'dark'));
      valueOf(await settings.write('recent', <String>['/code/app']));

      expect(valueOf(await settings.read('theme')), 'dark');
      expect(valueOf(await settings.read('recent')), <String>['/code/app']);
    });

    test('an object comes back as an object, through a new store', () async {
      valueOf(
        await settings.write('app.preferences', <String, Object?>{
          'theme': 'dark',
          'showingFormattingBar': false,
        }),
      );

      final JsonFileSettingsImpl reopened = JsonFileSettingsImpl(
        filesystem: const DartIoFilesystemImpl(),
        path: path,
      );
      expect(valueOf(await reopened.read('app.preferences')), <String, Object?>{
        'theme': 'dark',
        'showingFormattingBar': false,
      });
    });

    test('writing again replaces', () async {
      valueOf(await settings.write('theme', 'dark'));
      valueOf(await settings.write('theme', 'light'));

      expect(valueOf(await settings.read('theme')), 'light');
    });

    test('removing takes one key and keeps the rest', () async {
      valueOf(await settings.write('theme', 'dark'));
      valueOf(await settings.write('recent', <String>['/code/app']));

      valueOf(await settings.remove('theme'));

      expect(valueOf(await settings.read('theme')), isNull);
      expect(valueOf(await settings.read('recent')), <String>['/code/app']);
    });

    test('a value with newlines and unicode comes back unchanged', () async {
      const String awkward = 'a "quoted" value\nwith ✅ and 中文';

      valueOf(await settings.write('awkward', awkward));

      expect(valueOf(await settings.read('awkward')), awkward);
    });

    test('what is written is a readable JSON object', () async {
      valueOf(await settings.write('theme', 'dark'));

      expect(File(path).readAsStringSync(), contains('"theme": "dark"'));
    });

    test('an object is written as JSON, never escaped in a string', () async {
      // What the tab shows is what a person would write
      // (`docs/product/preferences/where-it-is-stored/doc.md`).
      valueOf(
        await settings.write('app.preferences', <String, Object?>{
          'theme': 'dark',
        }),
      );

      expect(
        File(path).readAsStringSync(),
        '{\n'
        '  "app.preferences": {\n'
        '    "theme": "dark"\n'
        '  }\n'
        '}',
      );
    });
  });

  group('a file an earlier build wrote', () {
    // Each value a string holding JSON: `"app.preferences": "{\"theme\"…}"`.
    void writeEarlier() => File(path)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(
        '{\n'
        '  "app.preferences": "{\\"theme\\":\\"dark\\"}",\n'
        '  "spaces.recent": "[{\\"root\\":\\"/a\\"}]",\n'
        '  "plain": "a string that is not JSON"\n'
        '}',
      );

    test('reads each value as what its string holds', () async {
      writeEarlier();

      expect(valueOf(await settings.read('app.preferences')), <String, Object?>{
        'theme': 'dark',
      });
      expect(valueOf(await settings.read('spaces.recent')), <Object?>[
        <String, Object?>{'root': '/a'},
      ]);
      expect(
        valueOf(await settings.read('plain')),
        'a string that is not JSON',
      );
    });

    test('and the next write puts the whole file in today\'s shape', () async {
      writeEarlier();

      valueOf(await settings.write('theme', 'light'));

      final String text = File(path).readAsStringSync();
      expect(text, isNot(contains(r'\"')));
      expect(text, contains('"app.preferences": {'));
      expect(text, contains('"spaces.recent": ['));
      expect(text, contains('"plain": "a string that is not JSON"'));
    });
  });

  group('a file someone else wrote', () {
    test('nonsense is treated as empty, not as a reason to stop', () async {
      File(path)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('this is not json');

      expect(valueOf(await settings.read('theme')), isNull);
    });

    test('but is never written over: it is somebody\'s typing', () async {
      // The file opens in a tab and saves by hand; the next write of an
      // unrelated key must not delete what was typed there.
      File(path)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('{"theme": "dark",');

      expect(
        await settings.write('spaces.recent', <String>['/a']),
        isA<Failure<void, SettingsFailure>>(),
      );
      expect(File(path).readAsStringSync(), '{"theme": "dark",');
    });

    test('an empty file is a first run, and is written', () async {
      File(path)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('  \n');

      valueOf(await settings.write('theme', 'dark'));

      expect(valueOf(await settings.read('theme')), 'dark');
    });

    test('a JSON array is treated as empty too', () async {
      File(path)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('[1, 2, 3]');

      expect(valueOf(await settings.read('theme')), isNull);
    });

    test('a value of any JSON shape comes back as it is', () async {
      File(path)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('{"theme": 1, "spaces.recent": ["/a", "/b"]}');

      expect(valueOf(await settings.read('theme')), 1);
      expect(valueOf(await settings.read('spaces.recent')), <String>[
        '/a',
        '/b',
      ]);
    });

    test('and writing over such a value replaces it', () async {
      File(path)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('{"theme": 1}');

      valueOf(await settings.write('theme', 'dark'));

      expect(valueOf(await settings.read('theme')), 'dark');
    });
  });
}
