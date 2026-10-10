import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _Git git;
  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject path = SpaceRelativePathValueObject(
    'old/notes.txt',
  );
  const GitFailure missing = GitPathNotInRevision('docs/old/notes.txt');

  setUp(() => git = _Git());

  Future<Result<FileContentValueObject, AppFailure>> reading() =>
      ReadCommittedFileUseCase(
        gitFor: (SpaceEntity space) => git,
        observability: const _SilentObservability(),
      ).read(docs, path);

  Result<Uint8List, GitFailure> holding(List<int> bytes) =>
      Success<Uint8List, GitFailure>(Uint8List.fromList(bytes));

  test('it reads the file at HEAD, by git\'s own path', () async {
    git.committed = holding(utf8.encode('last words\n'));
    final Result<FileContentValueObject, AppFailure> result = await reading();
    expect(git.revision, 'HEAD');
    expect(git.path?.value, 'docs/old/notes.txt');
    expect(git.staged, isNull, reason: 'the index is only the fallback');
    expect(
      (result as Success<FileContentValueObject, AppFailure>).value,
      FileContentValueObject.text(
        DocumentEntity(path: path, content: 'last words\n'),
      ),
    );
  });

  test('bytes that were never text are binary, zero byte or not', () async {
    git.committed = holding(<int>[0xFF, 0xD8, 0xFF, 0xE0]);
    expect(
      ((await reading()) as Success<FileContentValueObject, AppFailure>).value,
      const FileContentValueObject.binary(),
    );

    git.committed = holding(<int>[0x89, 0x50, 0x4E, 0x47, 0x00]);
    expect(
      ((await reading()) as Success<FileContentValueObject, AppFailure>).value,
      const FileContentValueObject.binary(),
    );
  });

  test('a replacement character that was committed is text', () async {
    final String typed = 'see ${String.fromCharCode(0xFFFD)}\n';
    git.committed = holding(utf8.encode(typed));
    expect(
      ((await reading()) as Success<FileContentValueObject, AppFailure>).value,
      FileContentValueObject.text(DocumentEntity(path: path, content: typed)),
    );
  });

  test('a file HEAD never had is read from the index', () async {
    git
      ..committed = const Failure<Uint8List, GitFailure>(missing)
      ..indexed = holding(utf8.encode('staged, never committed\n'));
    final Result<FileContentValueObject, AppFailure> result = await reading();
    expect(git.staged?.value, 'docs/old/notes.txt');
    expect(
      (result as Success<FileContentValueObject, AppFailure>).value,
      FileContentValueObject.text(
        DocumentEntity(path: path, content: 'staged, never committed\n'),
      ),
    );
  });

  test('a file neither holds is passed through as git said', () async {
    git
      ..committed = const Failure<Uint8List, GitFailure>(missing)
      ..indexed = const Failure<Uint8List, GitFailure>(missing);
    expect(
      ((await reading()) as Failure<FileContentValueObject, AppFailure>)
          .failure,
      missing,
    );
  });

  test('any other failure at HEAD does not reach for the index', () async {
    git.committed = const Failure<Uint8List, GitFailure>(GitTimedOut());
    final Result<FileContentValueObject, AppFailure> result = await reading();
    expect(git.staged, isNull);
    expect(
      (result as Failure<FileContentValueObject, AppFailure>).failure,
      const GitTimedOut(),
    );
  });
}

final class _Git implements GitRepository {
  Result<Uint8List, GitFailure> committed = Success<Uint8List, GitFailure>(
    Uint8List(0),
  );
  Result<Uint8List, GitFailure> indexed = Success<Uint8List, GitFailure>(
    Uint8List(0),
  );
  String? revision;
  RepoRelativePathValueObject? path;
  RepoRelativePathValueObject? staged;

  @override
  Future<Result<Uint8List, GitFailure>> bytesAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async {
    this.revision = revision;
    this.path = path;
    return committed;
  }

  @override
  Future<Result<Uint8List, GitFailure>> stagedBytes(
    RepoRelativePathValueObject path,
  ) async {
    staged = path;
    return indexed;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _SilentObservability implements Observability {
  const _SilentObservability();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
