/// [DiscardChangeUseCase]: one row of the changes list, put back.
library;

import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;
  late _Git git;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  setUp(() {
    observability = _RecordingObservability();
    git = _Git();
  });

  DiscardChangeUseCase discarding() => DiscardChangeUseCase(
    gitFor: (SpaceEntity space) => git,
    observability: observability,
  );

  StatusEntryValueObject entry(
    FileStateEnum state, {
    bool isStaged = false,
    String? previous,
  }) => StatusEntryValueObject(
    path: RepoRelativePathValueObject('docs/a.md'),
    state: state,
    isStaged: isStaged,
    previousPath: previous == null
        ? null
        : RepoRelativePathValueObject(previous),
  );

  test('asks git for the kind the row decides', () async {
    final Result<void, AppFailure> result = await discarding().discard(
      docs,
      entry(FileStateEnum.modified, isStaged: true),
    );

    expect(result, isA<Success<void, AppFailure>>());
    expect(git.kind, DiscardKindEnum.toLastCommit);
    expect(git.paths, <RepoRelativePathValueObject>[
      RepoRelativePathValueObject('docs/a.md'),
    ]);
  });

  test('a rename takes its old name back with it', () async {
    await discarding().discard(
      docs,
      entry(FileStateEnum.renamed, isStaged: true, previous: 'docs/old.md'),
    );

    expect(git.paths, <RepoRelativePathValueObject>[
      RepoRelativePathValueObject('docs/a.md'),
      RepoRelativePathValueObject('docs/old.md'),
    ]);
  });

  test('a conflicted file is refused before git is asked', () async {
    final Result<void, AppFailure> result = await discarding().discard(
      docs,
      entry(FileStateEnum.conflicted),
    );

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<GitMergeConflict>(),
    );
    expect(git.kind, isNull);
  });

  test('a refusal is passed through, not reported', () async {
    git.failure = const GitOperationFailed();

    final Result<void, AppFailure> result = await discarding().discard(
      docs,
      entry(FileStateEnum.untracked),
    );

    expect(result, isA<Failure<void, AppFailure>>());
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes, and is reported', () async {
    git.throws = true;

    final Result<void, AppFailure> result = await discarding().discard(
      docs,
      entry(FileStateEnum.modified),
    );

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// Git, answering only the discard and throwing for everything else.
final class _Git implements GitRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  GitFailure? failure;
  bool throws = false;
  DiscardKindEnum? kind;
  List<RepoRelativePathValueObject>? paths;

  @override
  Future<Result<void, GitFailure>> discard(
    DiscardKindEnum kind,
    List<RepoRelativePathValueObject> paths,
  ) async {
    if (throws) {
      throw StateError('git fell over');
    }
    this.kind = kind;
    this.paths = paths;
    final GitFailure? refused = failure;
    return refused == null
        ? const Success<void, GitFailure>(null)
        : Failure<void, GitFailure>(refused);
  }
}

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
