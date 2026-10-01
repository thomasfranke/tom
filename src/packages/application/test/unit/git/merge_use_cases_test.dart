/// [ReadMergeStateUseCase] and [AbortPullUseCase], the two halves of the
/// state a conflicted pull leaves behind.
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

  ReadMergeStateUseCase reading() => ReadMergeStateUseCase(
    gitFor: (SpaceEntity space) => git,
    observability: observability,
  );

  AbortPullUseCase aborting() => AbortPullUseCase(
    gitFor: (SpaceEntity space) => git,
    observability: observability,
  );

  group('reading the merge state', () {
    test('hands back what git said', () async {
      git.state = const MergeStateValueObject(
        inProgress: true,
        message: "Merge branch 'main'",
      );

      final Result<MergeStateValueObject, AppFailure> result = await reading()
          .read(docs);

      final MergeStateValueObject state =
          (result as Success<MergeStateValueObject, AppFailure>).value;
      expect(state.inProgress, isTrue);
      expect(state.message, "Merge branch 'main'");
    });

    test('a repository at rest is an answer, not a failure', () async {
      final Result<MergeStateValueObject, AppFailure> result = await reading()
          .read(docs);

      expect(result, isA<Success<MergeStateValueObject, AppFailure>>());
      expect(
        (result as Success<MergeStateValueObject, AppFailure>).value.inProgress,
        isFalse,
      );
    });

    test('is asked of the space it was given', () async {
      final List<SpaceEntity> asked = <SpaceEntity>[];

      await ReadMergeStateUseCase(
        gitFor: (SpaceEntity space) {
          asked.add(space);
          return git;
        },
        observability: observability,
      ).read(docs);

      expect(asked, <SpaceEntity>[docs]);
    });

    test('a refusal is passed through, not reported', () async {
      git.failure = const GitNotInstalled();

      final Result<MergeStateValueObject, AppFailure> result = await reading()
          .read(docs);

      expect(
        (result as Failure<MergeStateValueObject, AppFailure>).failure,
        isA<GitNotInstalled>(),
      );
      expect(observability.captured, isEmpty);
    });

    test('an exception never escapes, and is reported', () async {
      git.throws = true;

      final Result<MergeStateValueObject, AppFailure> result = await reading()
          .read(docs);

      expect(
        (result as Failure<MergeStateValueObject, AppFailure>).failure,
        isA<UnexpectedFailure>(),
      );
      expect(observability.captured.single.layer, 'application');
    });
  });

  group('aborting the pull', () {
    test('asks git to abort', () async {
      final Result<void, AppFailure> result = await aborting().abort(docs);

      expect(result, isA<Success<void, AppFailure>>());
      expect(git.aborted, 1);
    });

    test('a refusal is passed through, not reported', () async {
      git.failure = const GitOperationFailed();

      final Result<void, AppFailure> result = await aborting().abort(docs);

      expect(
        (result as Failure<void, AppFailure>).failure,
        const GitOperationFailed(),
      );
      expect(observability.captured, isEmpty);
    });

    test('an exception never escapes, and is reported', () async {
      git.throws = true;

      final Result<void, AppFailure> result = await aborting().abort(docs);

      expect(
        (result as Failure<void, AppFailure>).failure,
        isA<UnexpectedFailure>(),
      );
      expect(observability.captured.single.layer, 'application');
    });
  });
}

/// Git, answering only about the merge and throwing for everything else, so
/// a use case that reached for another method fails loudly.
final class _Git implements GitRepository {
  MergeStateValueObject state = MergeStateValueObject.none;
  GitFailure? failure;
  bool throws = false;
  int aborted = 0;

  @override
  Future<Result<MergeStateValueObject, GitFailure>> mergeState() async {
    if (throws) {
      throw StateError('git fell over');
    }
    final GitFailure? refused = failure;
    return refused == null
        ? Success<MergeStateValueObject, GitFailure>(state)
        : Failure<MergeStateValueObject, GitFailure>(refused);
  }

  @override
  Future<Result<void, GitFailure>> abortMerge() async {
    if (throws) {
      throw StateError('git fell over');
    }
    aborted += 1;
    final GitFailure? refused = failure;
    return refused == null
        ? const Success<void, GitFailure>(null)
        : Failure<void, GitFailure>(refused);
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
  Future<Result<void, GitFailure>> stage(
    List<RepoRelativePathValueObject> paths,
  ) async => throw UnimplementedError();

  @override
  Future<Result<void, GitFailure>> unstage(
    List<RepoRelativePathValueObject> paths,
  ) async => throw UnimplementedError();

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
