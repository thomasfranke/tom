/// What the settings store does when the disk refuses.
///
/// Unit, with a filesystem that fails on command: a real disk in a temporary
/// folder does not produce `EIO` or a permission error when asked, and these
/// are exactly the paths a user hits and nobody tests.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _Filesystem filesystem;
  late JsonFileSettings settings;

  setUp(() {
    filesystem = _Filesystem();
    settings = JsonFileSettings(
      filesystem: filesystem,
      path: '/preferences.json',
    );
  });

  /// What [result] failed with, or a failure of the test if it succeeded.
  AppFailure failureOf<T>(Result<T> result) => switch (result) {
    Success<T>() => throw StateError('expected a failure, got a success'),
    Failure<T>(failure: final AppFailure failure) => failure,
  };

  group('a file that cannot be read', () {
    setUp(
      () => filesystem.readFailure = const FilesystemAccessDenied(
        '/preferences.json',
      ),
    );

    test('reading answers this capability\'s own failure', () async {
      // Never a `FilesystemFailure`: the caller deals in preferences and
      // should not have to know there is a file involved.
      final AppFailure failure = failureOf(await settings.read('theme'));

      expect(failure, isA<SettingsUnavailable>());
      expect(failure, isNot(isA<FilesystemFailure>()));
    });

    test('writing fails too, rather than writing over what it could not '
        'read', () async {
      // The store rewrites the whole object, so writing without having read
      // it first would drop every other preference.
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

      // Verbatim and never parsed — what matters is that the original
      // reaches a log, not that anything can read it back.
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
      // Nothing was written, so nothing was corrupted.
      expect(await settings.read('theme'), isA<Success<String?>>());
    });
  });

  group('bytes that are not text', () {
    test('are this capability\'s failure, not a decoding accident', () async {
      // `Filesystem` refuses a file it cannot read back losslessly rather
      // than handing over replacement characters, and that refusal has to
      // survive the trip up here.
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
  Future<Result<String>> readFile(String path) async {
    final FilesystemFailure? failure = readFailure;
    if (failure != null) {
      return Failure<String>(failure);
    }
    final String? content = written[path];
    return content == null
        ? Failure<String>(FilesystemEntryNotFound(path))
        : Success<String>(content);
  }

  @override
  Future<Result<void>> writeFile(String path, String content) async {
    final FilesystemFailure? failure = writeFailure;
    if (failure != null) {
      return Failure<void>(failure);
    }
    written[path] = content;
    return const Success<void>(null);
  }

  @override
  Future<Result<List<FilesystemEntry>>> listDirectory(
    String path, {
    bool recursive = false,
  }) async => throw UnimplementedError();

  @override
  Future<Result<bool>> directoryExists(String path) async =>
      throw UnimplementedError();
}
