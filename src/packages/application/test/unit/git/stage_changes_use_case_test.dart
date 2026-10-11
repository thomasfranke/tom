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

  group('a document git does not call conflicted', () {
    // Outside a merge a marker line is prose — a page about resolving
    // conflicts quotes whole regions — and it must stage.
    test('is staged without being read, whole region or not', () async {
      documents.contents['guides/writing.md'] = conflicted;

      final Result<void, AppFailure> result = await staging().stage(
        docs,
        <RepoRelativePathValueObject>[writing],
      );

      expect(result, isA<Success<void, AppFailure>>());
      expect(git.staged, <RepoRelativePathValueObject>[writing]);
      expect(documents.read_, isEmpty);
    });

    test('is staged beside one that is, when that one reads clean', () async {
      final RepoRelativePathValueObject reading = RepoRelativePathValueObject(
        'docs/guides/reading.md',
      );
      git.conflicted.add(reading);
      documents.contents['guides/writing.md'] = conflicted;
      documents.contents['guides/reading.md'] = '# Resolved\n';

      final Result<void, AppFailure> result = await staging().stage(
        docs,
        <RepoRelativePathValueObject>[writing, reading],
      );

      expect(result, isA<Success<void, AppFailure>>());
      expect(documents.read_, <String>['guides/reading.md']);
    });
  });

  test('a status git will not give stages nothing', () async {
    git.reading = const Failure<GitStatusValueObject, GitFailure>(
      GitOperationFailed(),
    );

    final Result<void, AppFailure> result = await staging().stage(
      docs,
      <RepoRelativePathValueObject>[writing],
    );

    expect(
      (result as Failure<void, AppFailure>).failure,
      const GitOperationFailed(),
    );
    expect(git.staged, isEmpty);
  });

  group('a document still holding a conflict marker', () {
    setUp(() => git.conflicted.add(writing));

    // A region half resolved by hand: no longer a region, still not prose.
    for (final (String left, String text) in <(String, String)>[
      ('the opening line', '# Guide\n\n<<<<<<< HEAD\nours\n'),
      ('the separator', '# Guide\n\nours\n=======\ntheirs\n'),
      ('the closing line', '# Guide\n\ntheirs\n>>>>>>> main\n'),
      ('the base line of diff3', '# Guide\n\nours\n||||||| 1a2b3c4\nwas\n'),
    ]) {
      test('is refused with only $left left', () async {
        documents.contents['guides/writing.md'] = text;

        final Result<void, AppFailure> result = await staging().stage(
          docs,
          <RepoRelativePathValueObject>[writing],
        );

        expect(
          ((result as Failure<void, AppFailure>).failure
                  as GitConflictMarkersPresent)
              .paths,
          <String>['docs/guides/writing.md'],
        );
        expect(git.staged, isEmpty);
      });
    }

    test('is refused, and the refusal names it', () async {
      documents.contents['guides/writing.md'] = conflicted;

      final Result<void, AppFailure> result = await staging().stage(
        docs,
        <RepoRelativePathValueObject>[writing],
      );

      final AppFailure failure = (result as Failure<void, AppFailure>).failure;
      expect(failure, isA<GitConflictMarkersPresent>());
      expect((failure as GitConflictMarkersPresent).paths, <String>[
        'docs/guides/writing.md',
      ]);
    });

    test('never reaches git', () async {
      documents.contents['guides/writing.md'] = conflicted;

      await staging().stage(docs, <RepoRelativePathValueObject>[writing]);

      expect(git.staged, isEmpty);
    });

    test(
      'refuses the whole batch, naming every one that holds a marker',
      () async {
        final RepoRelativePathValueObject reading = RepoRelativePathValueObject(
          'docs/guides/reading.md',
        );
        git.conflicted.add(reading);
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
      },
    );

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

  group('a conflicted path outside the space', () {
    // The changes list is the repository's, so it names files beside the
    // space. They are read through the repository's own folder.
    final RepoRelativePathValueObject readme = RepoRelativePathValueObject(
      'README.md',
    );
    late _Documents beside;

    setUp(() {
      git.conflicted.add(readme);
      beside = _Documents();
    });

    StageChangesUseCase stagingBeside() => StageChangesUseCase(
      gitFor: (SpaceEntity space) => git,
      documentsFor: (SpaceEntity space) =>
          space.root == '/code/app' ? beside : documents,
      observability: observability,
    );

    test('is refused while it holds a marker', () async {
      beside.contents['README.md'] = conflicted;

      final Result<void, AppFailure> result = await stagingBeside().stage(
        docs,
        <RepoRelativePathValueObject>[readme],
      );

      expect(
        ((result as Failure<void, AppFailure>).failure
                as GitConflictMarkersPresent)
            .paths,
        <String>['README.md'],
      );
      expect(git.staged, isEmpty);
    });

    test(
      'is staged once it reads clean — resolved in another editor',
      () async {
        beside.contents['README.md'] = '# Resolved elsewhere\n';

        final Result<void, AppFailure> result = await stagingBeside().stage(
          docs,
          <RepoRelativePathValueObject>[readme],
        );

        expect(result, isA<Success<void, AppFailure>>());
        expect(git.staged, <RepoRelativePathValueObject>[readme]);
        expect(documents.read_, isEmpty);
      },
    );
  });

  group('a conflicted path', () {
    setUp(() => git.conflicted.add(writing));

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
        ? Failure<DocumentEntity, DocumentFailure>(DocumentNotFound(path.value))
        : Success<DocumentEntity, DocumentFailure>(
            DocumentEntity(path: path, content: content),
          );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      throw UnimplementedError();
}

/// Git, remembering what it was asked to stage and unstage and throwing for
/// everything else, so a use case that called an unasked method fails loudly.
final class _Git implements GitRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

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

  /// The paths git calls conflicted; everything else it has nothing to say
  /// about.
  final List<RepoRelativePathValueObject> conflicted =
      <RepoRelativePathValueObject>[];

  /// What the status answers when it is not [conflicted]'s.
  Result<GitStatusValueObject, GitFailure>? reading;

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async =>
      reading ??
      Success<GitStatusValueObject, GitFailure>(
        GitStatusValueObject(
          branch: BranchNameValueObject('main'),
          upstream: null,
          ahead: 0,
          behind: 0,
          entries: <StatusEntryValueObject>[
            for (final RepoRelativePathValueObject path in conflicted)
              StatusEntryValueObject(
                path: path,
                state: FileStateEnum.conflicted,
                isStaged: false,
              ),
          ],
          isDetached: false,
        ),
      );

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
  Future<Result<void, GitFailure>> discardAll() async =>
      throw UnimplementedError();

  @override
  Future<Result<List<CommitEntity>, GitFailure>> commitsSince(
    BranchNameValueObject base,
  ) async => throw UnimplementedError();

  @override
  Future<Result<List<BranchChangeValueObject>, GitFailure>> changesSince(
    BranchNameValueObject base,
  ) async => throw UnimplementedError();

  @override
  Future<Result<String?, GitFailure>> remoteAddress() async =>
      throw UnimplementedError();

  @override
  Future<Result<BranchNameValueObject?, GitFailure>> defaultBranch() async =>
      throw UnimplementedError();

  @override
  Future<Result<CommitShaValueObject?, GitFailure>> forkPoint(
    BranchNameValueObject base,
  ) async => throw UnimplementedError();

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
