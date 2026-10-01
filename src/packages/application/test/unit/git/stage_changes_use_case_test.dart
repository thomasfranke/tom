import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;
  late _Git git;
  late _Documents documents;

  const String conflicted =
      '# Guide\n\n<<<<<<< HEAD\nours\n=======\ntheirs\n>>>>>>> main\n';

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final RepoRelativePathValueObject writing = RepoRelativePathValueObject(
    'docs/guides/writing.md',
  );

  setUp(() {
    observability = _RecordingObservability();
    git = _Git();
    documents = _Documents();
  });

  StageChangesUseCase staging() => StageChangesUseCase(
    gitFor: (SpaceEntity space) => git,
    documentsFor: (SpaceEntity space) => documents,
    observability: observability,
  );

  test('staging puts the paths in the index', () async {
    final Result<void, AppFailure> result = await staging().stage(
      docs,
      <RepoRelativePathValueObject>[writing],
    );

    expect(result, isA<Success<void, AppFailure>>());
    expect(git.staged, <RepoRelativePathValueObject>[writing]);
    expect(git.unstaged, isEmpty);
  });

  test('unstaging takes them back out', () async {
    await staging().unstage(docs, <RepoRelativePathValueObject>[writing]);

    expect(git.unstaged, <RepoRelativePathValueObject>[writing]);
    expect(git.staged, isEmpty);
  });

  test('staging nothing is allowed and does nothing', () async {
    final Result<void, AppFailure> result = await staging().stage(
      docs,
      const <RepoRelativePathValueObject>[],
    );

    expect(result, isA<Success<void, AppFailure>>());
    expect(git.staged, isEmpty);
  });

  test('the repository is built for the space it was asked about', () async {
    final List<SpaceEntity> asked = <SpaceEntity>[];

    await StageChangesUseCase(
      gitFor: (SpaceEntity space) {
        asked.add(space);
        return git;
      },
      documentsFor: (SpaceEntity space) => documents,
      observability: observability,
    ).stage(docs, <RepoRelativePathValueObject>[writing]);

    expect(asked, <SpaceEntity>[docs]);
  });

  test('a refusal is passed through, not reported', () async {
    git.answer = const Failure<void, GitFailure>(GitOperationFailed());

    final Result<void, AppFailure> result = await staging().stage(
      docs,
      <RepoRelativePathValueObject>[writing],
    );

    expect(
      (result as Failure<void, AppFailure>).failure,
      const GitOperationFailed(),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    git.throws = true;

    final Result<void, AppFailure> result = await staging().stage(
      docs,
      <RepoRelativePathValueObject>[writing],
    );

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });

  group('a document still holding a conflict marker', () {
    test('is refused, and the refusal names it', () async {
      documents.contents['guides/writing.md'] = conflicted;

      final Result<void, AppFailure> result = await staging().stage(
        docs,
        <RepoRelativePathValueObject>[writing],
      );

      final AppFailure failure = (result as Failure<void, AppFailure>).failure;
      expect(failure, isA<GitConflictMarkersPresent>());
      expect(
        (failure as GitConflictMarkersPresent).paths,
        <String>['docs/guides/writing.md'],
      );
    });

    test('never reaches git', () async {
      documents.contents['guides/writing.md'] = conflicted;

      await staging().stage(docs, <RepoRelativePathValueObject>[writing]);

      expect(git.staged, isEmpty);
    });

    test('refuses the whole batch, naming every one that holds a marker',
        () async {
      final RepoRelativePathValueObject reading = RepoRelativePathValueObject(
        'docs/guides/reading.md',
      );
      documents.contents['guides/writing.md'] = conflicted;
      documents.contents['guides/reading.md'] = conflicted;

      final Result<void, AppFailure> result = await staging().stage(
        docs,
        <RepoRelativePathValueObject>[writing, reading],
      );

      expect(
        ((result as Failure<void, AppFailure>).failure
                as GitConflictMarkersPresent)
            .paths,
        <String>['docs/guides/writing.md', 'docs/guides/reading.md'],
      );
      expect(git.staged, isEmpty);
    });

    // The rule the check exists for: resolving happens in the buffer and
    // staging is how the resolution is declared, so a document whose markers
    // are gone must go through even though git still calls it conflicted.
    test('goes through once the markers are gone', () async {
      documents.contents['guides/writing.md'] = '# Guide\n\nours\ntheirs\n';

      final Result<void, AppFailure> result = await staging().stage(
        docs,
        <RepoRelativePathValueObject>[writing],
      );

      expect(result, isA<Success<void, AppFailure>>());
      expect(git.staged, <RepoRelativePathValueObject>[writing]);
    });

    test('is not confused by a document that merely quotes a marker', () async {
      documents.contents['guides/writing.md'] =
          '# Guide\n\nGit writes `<<<<<<< HEAD` into the file.\n';

      final Result<void, AppFailure> result = await staging().stage(
        docs,
        <RepoRelativePathValueObject>[writing],
      );

      expect(result, isA<Success<void, AppFailure>>());
    });
  });

  group('a path the space cannot read', () {
    // The changes list is the repository's, so it names files this space
    // cannot open. Refusing those would strand somebody who resolved one in
    // another editor.
    test('outside the space is staged without being read', () async {
      final RepoRelativePathValueObject readme = RepoRelativePathValueObject(
        'README.md',
      );

      final Result<void, AppFailure> result = await staging().stage(
        docs,
        <RepoRelativePathValueObject>[readme],
      );

      expect(result, isA<Success<void, AppFailure>>());
      expect(git.staged, <RepoRelativePathValueObject>[readme]);
      expect(documents.read_, isEmpty);
    });

    test('that cannot be read at all is left to git to report', () async {
      final Result<void, AppFailure> result = await staging().stage(
        docs,
        <RepoRelativePathValueObject>[writing],
      );

      expect(result, isA<Success<void, AppFailure>>());
      expect(git.staged, <RepoRelativePathValueObject>[writing]);
    });
  });

  test('unstaging is never refused, marker or not', () async {
    documents.contents['guides/writing.md'] = conflicted;

    final Result<void, AppFailure> result = await staging().unstage(
      docs,
      <RepoRelativePathValueObject>[writing],
    );

    expect(result, isA<Success<void, AppFailure>>());
    expect(git.unstaged, <RepoRelativePathValueObject>[writing]);
  });
}

/// Documents, answering from a map keyed by space-relative path; anything
/// absent reads as `DocumentNotFound`, which is what a deleted file gives.
final class _Documents implements DocumentRepository {
  final Map<String, String> contents = <String, String>{};
  final List<String> read_ = <String>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async {
    read_.add(path.value);
    final String? content = contents[path.value];
    return content == null
        ? Failure<DocumentEntity, DocumentFailure>(
            DocumentNotFound(path.value),
          )
        : Success<DocumentEntity, DocumentFailure>(
            DocumentEntity(path: path, content: content),
          );
  }

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      throw UnimplementedError();
}

/// Git, remembering what it was asked to stage and unstage and throwing for
/// everything else, so a use case that called an unasked method fails loudly.
final class _Git implements GitRepository {
  Result<void, GitFailure>? answer;
  bool throws = false;

  final List<RepoRelativePathValueObject> staged =
      <RepoRelativePathValueObject>[];
  final List<RepoRelativePathValueObject> unstaged =
      <RepoRelativePathValueObject>[];

  Result<void, GitFailure> _done() => throws
      ? throw StateError('git fell over')
      : (answer ?? const Success<void, GitFailure>(null));

  @override
  Future<Result<void, GitFailure>> stage(
    List<RepoRelativePathValueObject> paths,
  ) async {
    staged.addAll(paths);
    return _done();
  }

  @override
  Future<Result<void, GitFailure>> unstage(
    List<RepoRelativePathValueObject> paths,
  ) async {
    unstaged.addAll(paths);
    return _done();
  }

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async =>
      throw UnimplementedError();

  @override
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  }) async => throw UnimplementedError();

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async =>
      throw UnimplementedError();

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> commit(String message) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> createBranch(
    BranchNameValueObject name,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> switchBranch(
    BranchNameValueObject name,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> fetch() async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> pull() async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> push() async => throw UnimplementedError();

  @override
  Future<Result<MergeStateValueObject, GitFailure>> mergeState() async =>
      throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> abortMerge() async =>
      throw UnimplementedError();
}

/// An [Observability] that keeps what it was handed.
final class _RecordingObservability implements Observability {
  final List<({Object error, StackTrace stackTrace, String layer})> captured =
      <({Object error, StackTrace stackTrace, String layer})>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async =>
      captured.add((error: error, stackTrace: stackTrace, layer: layer));
}
