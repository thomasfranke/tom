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
      valueOf(await settings.write('recent', '["/code/app"]'));

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
      valueOf(await settings.write('recent', '["/code/app"]'));

      expect(valueOf(await settings.read('theme')), 'dark');
      expect(valueOf(await settings.read('recent')), '["/code/app"]');
    });

    test('writing again replaces', () async {
      valueOf(await settings.write('theme', 'dark'));
      valueOf(await settings.write('theme', 'light'));

      expect(valueOf(await settings.read('theme')), 'light');
    });

    test('removing takes one key and keeps the rest', () async {
      valueOf(await settings.write('theme', 'dark'));
      valueOf(await settings.write('recent', '["/code/app"]'));

      valueOf(await settings.remove('theme'));

      expect(valueOf(await settings.read('theme')), isNull);
      expect(valueOf(await settings.read('recent')), '["/code/app"]');
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
  });

  group('a file someone else wrote', () {
    test('nonsense is treated as empty, not as a reason to stop', () async {
      File(path)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('this is not json');

      expect(valueOf(await settings.read('theme')), isNull);
    });

    test('and writing over it recovers', () async {
      File(path)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('this is not json');

      valueOf(await settings.write('theme', 'dark'));

      expect(valueOf(await settings.read('theme')), 'dark');
    });

    test('a JSON array is treated as empty too', () async {
      File(path)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('[1, 2, 3]');

      expect(valueOf(await settings.read('theme')), isNull);
    });

    test('a value that is not a string reads as nothing stored', () async {
      // Valid JSON, wrong shape — a number, or a list typed in place of the
      // encoded string; neither may throw.
      File(path)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('{"theme": 1, "spaces.recent": ["/a", "/b"]}');

      expect(valueOf(await settings.read('theme')), isNull);
      expect(valueOf(await settings.read('spaces.recent')), isNull);
    });

    test('and writing over such a value recovers it', () async {
      File(path)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('{"theme": 1}');

      valueOf(await settings.write('theme', 'dark'));

      expect(valueOf(await settings.read('theme')), 'dark');
    });
  });
}
