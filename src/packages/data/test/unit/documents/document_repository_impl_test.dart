/// [DocumentRepositoryImpl] against a filesystem that answers on command.
///
/// Unit, not integration: what this class does is resolve a path and
/// translate a failure. A real disk cannot be asked for `EIO` on demand, and
/// the integration test beside this one covers what a real disk *can* say.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _ScriptedFilesystem filesystem;
  late DocumentRepositoryImpl repository;

  // A space that is a folder *inside* a repository — the normal case, and
  // the one a path bug shows up in.
  final Space space = Space(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  setUp(() {
    filesystem = _ScriptedFilesystem();
    repository = DocumentRepositoryImpl(filesystem: filesystem, space: space);
  });

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T>(Result<T> result) => switch (result) {
    Success<T>(value: final T value) => value,
    Failure<T>(failure: final AppFailure failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  /// What [result] failed with, or a failure of the test if it succeeded.
  AppFailure failureOf<T>(Result<T> result) => switch (result) {
    Success<T>() => throw StateError('expected a failure, got a success'),
    Failure<T>(failure: final AppFailure failure) => failure,
  };

  group('reading', () {
    test('resolves the path against the space, not the repository', () async {
      filesystem.content = '# Guide\n';

      await repository.read(SpaceRelativePath('adr/001.md'));

      expect(filesystem.readPath, '/code/app/docs/adr/001.md');
    });

    test('hands back a document keyed by the path that was asked', () async {
      filesystem.content = '# Guide\n';

      final Document document = valueOf(
        await repository.read(SpaceRelativePath('adr/001.md')),
      );

      expect(document.path, SpaceRelativePath('adr/001.md'));
      expect(document.content, '# Guide\n');
    });

    test('keeps the bytes exactly as they were read', () async {
      // Normalizing here would produce a diff the user did not make.
      filesystem.content = '# Title\r\n\r\nBody\n\n';

      expect(
        valueOf(await repository.read(SpaceRelativePath('a.md'))).content,
        '# Title\r\n\r\nBody\n\n',
      );
    });
  });

  group('writing', () {
    test('writes the content where the document says', () async {
      await repository.write(
        Document(path: SpaceRelativePath('adr/001.md'), content: '# One\n'),
      );

      expect(filesystem.writtenPath, '/code/app/docs/adr/001.md');
      expect(filesystem.writtenContent, '# One\n');
    });

    test('a failure comes back in the product vocabulary', () async {
      filesystem.failure = const FilesystemAccessDenied(
        '/code/app/docs/adr/001.md',
      );

      expect(
        failureOf(
          await repository.write(
            Document(path: SpaceRelativePath('adr/001.md'), content: '# One\n'),
          ),
        ),
        const DocumentPermissionDenied('adr/001.md'),
      );
    });
  });

  group('translation of failures', () {
    /// The repository's answer to a filesystem that failed with [failure].
    Future<AppFailure> translationOf(FilesystemFailure failure) async {
      filesystem.failure = failure;
      return failureOf(await repository.read(SpaceRelativePath('adr/001.md')));
    }

    test('a missing file names the document, not the disk', () async {
      // The user asked for `adr/001.md`; telling them
      // `/code/app/docs/adr/001.md` is gone names a place they did not name.
      expect(
        await translationOf(
          const FilesystemEntryNotFound('/code/app/docs/adr/001.md'),
        ),
        const DocumentNotFound('adr/001.md'),
      );
    });

    test('a refused read is a permission problem', () async {
      expect(
        await translationOf(
          const FilesystemAccessDenied('/code/app/docs/adr/001.md'),
        ),
        const DocumentPermissionDenied('adr/001.md'),
      );
    });

    test('a file that is not text is refused, not decoded', () async {
      expect(
        await translationOf(
          const FilesystemNotUtf8('/code/app/docs/adr/001.md'),
        ),
        const DocumentNotUtf8('adr/001.md'),
      );
    });

    test('anything else keeps what the machine said', () async {
      expect(
        await translationOf(
          const FilesystemOperationFailed('/code/app/docs/adr/001.md', 'EIO'),
        ),
        const DocumentOperationFailed('adr/001.md', 'EIO'),
      );
    });

    test('no infrastructure failure reaches the caller', () async {
      expect(
        await translationOf(
          const FilesystemEntryNotFound('/code/app/docs/adr/001.md'),
        ),
        isNot(isA<FilesystemFailure>()),
      );
    });
  });
}

/// A [Filesystem] that answers what it was told to and remembers the call.
final class _ScriptedFilesystem implements Filesystem {
  /// What a read returns while [failure] is null.
  String content = '';

  /// What every call fails with, or null to succeed.
  FilesystemFailure? failure;

  String? readPath;
  String? writtenPath;
  String? writtenContent;

  @override
  Future<Result<String>> readFile(String path) async {
    readPath = path;
    final FilesystemFailure? pending = failure;
    return pending == null
        ? Success<String>(content)
        : Failure<String>(pending);
  }

  @override
  Future<Result<void>> writeFile(String path, String content) async {
    writtenPath = path;
    writtenContent = content;
    final FilesystemFailure? pending = failure;
    return pending == null ? const Success<void>(null) : Failure<void>(pending);
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
