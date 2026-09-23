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
  final SpaceEntity space = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  setUp(() {
    filesystem = _ScriptedFilesystem();
    repository = DocumentRepositoryImpl(
      documents: DocumentDataSource(filesystem: filesystem),
      space: space,
    );
  });

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  /// What [result] failed with, or a failure of the test if it succeeded.
  F failureOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>() => throw StateError('expected a failure, got a success'),
    Failure<T, F>(failure: final F failure) => failure,
  };

  /// A failure of variant [T] naming [path].
  ///
  /// By variant and path rather than by equality: every translation also
  /// attaches the capability's failure as its cause, and the tests below are
  /// about which word the product uses, not about what is underneath it.
  Matcher named<T extends DocumentFailure>(String path) =>
      isA<T>().having((T failure) => (failure as dynamic).path, 'path', path);

  group('reading', () {
    test('resolves the path against the space, not the repository', () async {
      filesystem.content = '# Guide\n';

      await repository.read(SpaceRelativePathValueObject('adr/001.md'));

      expect(filesystem.readPath, '/code/app/docs/adr/001.md');
    });

    test('hands back a document keyed by the path that was asked', () async {
      filesystem.content = '# Guide\n';

      final DocumentEntity document = valueOf(
        await repository.read(SpaceRelativePathValueObject('adr/001.md')),
      );

      expect(document.path, SpaceRelativePathValueObject('adr/001.md'));
      expect(document.content, '# Guide\n');
    });

    test('keeps the bytes exactly as they were read', () async {
      // Normalizing here would produce a diff the user did not make.
      filesystem.content = '# Title\r\n\r\nBody\n\n';

      expect(
        valueOf(
          await repository.read(SpaceRelativePathValueObject('a.md')),
        ).content,
        '# Title\r\n\r\nBody\n\n',
      );
    });
  });

  group('writing', () {
    test('writes the content where the document says', () async {
      await repository.write(
        DocumentEntity(
          path: SpaceRelativePathValueObject('adr/001.md'),
          content: '# One\n',
        ),
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
            DocumentEntity(
              path: SpaceRelativePathValueObject('adr/001.md'),
              content: '# One\n',
            ),
          ),
        ),
        named<DocumentPermissionDenied>('adr/001.md'),
      );
    });
  });

  group('translation of failures', () {
    /// The repository's answer to a filesystem that failed with [failure].
    Future<AppFailure> translationOf(FilesystemFailure failure) async {
      filesystem.failure = failure;
      return failureOf(
        await repository.read(SpaceRelativePathValueObject('adr/001.md')),
      );
    }

    test('a missing file names the document, not the disk', () async {
      // The user asked for `adr/001.md`; telling them
      // `/code/app/docs/adr/001.md` is gone names a place they did not name.
      expect(
        await translationOf(
          const FilesystemEntryNotFound('/code/app/docs/adr/001.md'),
        ),
        named<DocumentNotFound>('adr/001.md'),
      );
    });

    test('a refused read is a permission problem', () async {
      expect(
        await translationOf(
          const FilesystemAccessDenied('/code/app/docs/adr/001.md'),
        ),
        named<DocumentPermissionDenied>('adr/001.md'),
      );
    });

    test('a file that is not text is refused, not decoded', () async {
      expect(
        await translationOf(
          const FilesystemNotUtf8('/code/app/docs/adr/001.md'),
        ),
        named<DocumentNotUtf8>('adr/001.md'),
      );
    });

    test('anything else lands on the fallback, naming the document', () async {
      const FilesystemOperationFailed reported = FilesystemOperationFailed(
        '/code/app/docs/adr/001.md',
        'EIO',
      );

      final AppFailure failure = await translationOf(reported);

      // The variant names the path the user opened and nothing else: what the
      // machine said, and the absolute path it said it about, are the cause.
      expect(
        failure,
        const DocumentOperationFailed('adr/001.md', cause: reported),
      );
      expect(failure.diagnostics, contains('EIO'));
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
  Future<Result<String, FilesystemFailure>> readFile(String path) async {
    readPath = path;
    final FilesystemFailure? pending = failure;
    return pending == null
        ? Success<String, FilesystemFailure>(content)
        : Failure<String, FilesystemFailure>(pending);
  }

  @override
  Future<Result<void, FilesystemFailure>> writeFile(
    String path,
    String content,
  ) async {
    writtenPath = path;
    writtenContent = content;
    final FilesystemFailure? pending = failure;
    return pending == null
        ? const Success<void, FilesystemFailure>(null)
        : Failure<void, FilesystemFailure>(pending);
  }

  @override
  Future<Result<List<FilesystemEntryDto>, FilesystemFailure>> listDirectory(
    String path, {
    bool recursive = false,
  }) async => throw UnimplementedError();

  @override
  Future<Result<bool, FilesystemFailure>> directoryExists(String path) async =>
      throw UnimplementedError();
}
