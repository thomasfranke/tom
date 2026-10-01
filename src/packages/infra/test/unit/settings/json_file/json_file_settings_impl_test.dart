/// [JsonFileSettingsImpl] over a filesystem that fails on command.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _Filesystem filesystem;
  late JsonFileSettingsImpl settings;

  setUp(() {
    filesystem = _Filesystem();
    settings = JsonFileSettingsImpl(
      filesystem: filesystem,
      path: '/preferences.json',
    );
  });

  /// What [result] failed with, or a failure of the test if it succeeded.
  F failureOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>() => throw StateError('expected a failure, got a success'),
    Failure<T, F>(failure: final F failure) => failure,
  };

  group('a file that cannot be read', () {
    setUp(
      () => filesystem.readFailure = const FilesystemAccessDenied(
        '/preferences.json',
      ),
    );

    test('reading answers this capability\'s own failure', () async {
      final AppFailure failure = failureOf(await settings.read('theme'));

      expect(failure, isA<SettingsUnavailable>());
      expect(failure, isNot(isA<FilesystemFailure>()));
    });

    test('writing fails too, rather than writing over what it could not '
        'read', () async {
      // The store rewrites the whole object, so writing over what it could
      // not read would drop every other preference.
      expect(
        failureOf(await settings.write('theme', 'dark')),
        isA<SettingsUnavailable>(),
      );
      expect(filesystem.written, isEmpty);
    });

    test('removing fails for the same reason', () async {
      expect(
        failureOf(await settings.remove('theme')),
        isA<SettingsUnavailable>(),
      );
    });

    test('what the machine said travels, for diagnostics', () async {
      final SettingsUnavailable failure =
          failureOf(await settings.read('theme')) as SettingsUnavailable;

      expect(failure.description, contains('/preferences.json'));
      expect(failure.description, contains('accessDenied'));
    });
  });

  group('a file that cannot be written', () {
    setUp(
      () => filesystem.writeFailure = const FilesystemOperationFailed(
        '/preferences.json',
        'ENOSPC',
      ),
    );

    test('writing reports it', () async {
      expect(
        failureOf(await settings.write('theme', 'dark')),
        isA<SettingsUnavailable>(),
      );
    });

    test('and reading still works, because the file is intact', () async {
      expect(
        await settings.read('theme'),
        isA<Success<String?, SettingsFailure>>(),
      );
    });
  });

  group('bytes that are not text', () {
    test('are this capability\'s failure, not a decoding accident', () async {
      filesystem.readFailure = const FilesystemNotUtf8('/preferences.json');

      expect(
        failureOf(await settings.read('theme')),
        isA<SettingsUnavailable>(),
      );
    });
  });
}

/// A [Filesystem] that fails where it is told to.
final class _Filesystem implements Filesystem {
  FilesystemFailure? readFailure;
  FilesystemFailure? writeFailure;
  final Map<String, String> written = <String, String>{};

  @override
  Future<Result<String, FilesystemFailure>> readFile(String path) async {
    final FilesystemFailure? failure = readFailure;
    if (failure != null) {
      return Failure<String, FilesystemFailure>(failure);
    }
    final String? content = written[path];
    return content == null
        ? Failure<String, FilesystemFailure>(FilesystemEntryNotFound(path))
        : Success<String, FilesystemFailure>(content);
  }

  @override
  Future<Result<void, FilesystemFailure>> writeFile(
    String path,
    String content,
  ) async {
    final FilesystemFailure? failure = writeFailure;
    if (failure != null) {
      return Failure<void, FilesystemFailure>(failure);
    }
    written[path] = content;
    return const Success<void, FilesystemFailure>(null);
  }

  @override
  Future<Result<List<FilesystemEntryDto>, FilesystemFailure>> listDirectory(
    String path, {
    bool recursive = false,
  }) async => throw UnimplementedError();

  @override
  Future<Result<bool, FilesystemFailure>> directoryExists(String path) async =>
      throw UnimplementedError();

  @override
  Future<Result<String, FilesystemFailure>> resolvePath(String path) async =>
      throw UnimplementedError();
}
