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

  PullRemoteUseCase pulling() => PullRemoteUseCase(
    gitFor: (SpaceEntity space) => git,
    observability: observability,
  );

  /// What a successful [result] counted.
  int? arrived(Result<int?, AppFailure> result) =>
      (result as Success<int?, AppFailure>).value;

  test('it brings the remote commits in', () async {
    final Result<int?, AppFailure> result = await pulling().pull(docs);

    expect(result, isA<Success<int?, AppFailure>>());
    expect(git.pulled, 1);
  });

  test('the repository is built for the space it was asked about', () async {
    final List<SpaceEntity> asked = <SpaceEntity>[];

    await PullRemoteUseCase(
      gitFor: (SpaceEntity space) {
        asked.add(space);
        return git;
      },
      observability: observability,
    ).pull(docs);

    expect(asked, <SpaceEntity>[docs]);
  });

  group('what arrived', () {
    test('is counted from where HEAD was before the pull', () async {
      git
        ..before = CommitShaValueObject('a' * 40)
        ..count = 3;

      expect(arrived(await pulling().pull(docs)), 3);
      expect(git.countedSince, <CommitShaValueObject?>[
        CommitShaValueObject('a' * 40),
      ]);
      expect(git.order, <String>['head', 'pull', 'count']);
    });

    test('is 0 when the branch was already level', () async {
      git.count = 0;

      expect(arrived(await pulling().pull(docs)), 0);
    });

    test('before the first commit, is counted from nothing', () async {
      git
        ..before = null
        ..count = 2;

      expect(arrived(await pulling().pull(docs)), 2);
      expect(git.countedSince, <CommitShaValueObject?>[null]);
    });

    test('is unknown, not a failure, when git cannot count', () async {
      git.countFailure = const GitOperationFailed();

      final Result<int?, AppFailure> result = await pulling().pull(docs);

      expect(arrived(result), isNull);
      expect(git.pulled, 1);
    });

    test(
      'is unknown when HEAD could not be read; the pull still runs',
      () async {
        git.headThrows = true;

        final Result<int?, AppFailure> result = await pulling().pull(docs);

        expect(arrived(result), isNull);
        expect(git.pulled, 1);
        expect(git.countedSince, isEmpty);
        expect(observability.captured.single.layer, 'application');
      },
    );
  });

  test('a merge conflict is passed through, not reported', () async {
    git.answer = const Failure<void, GitFailure>(
      GitMergeConflict(<String>['docs/index.md']),
    );

    final Result<int?, AppFailure> result = await pulling().pull(docs);

    expect(
      (result as Failure<int?, AppFailure>).failure,
      const GitMergeConflict(<String>['docs/index.md']),
    );
    expect(git.countedSince, isEmpty);
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    git.throws = true;

    final Result<int?, AppFailure> result = await pulling().pull(docs);

    expect(
      (result as Failure<int?, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// Git, answering `head`, `pull` and the count, and refusing every other
/// question.
///
/// The rest is left to `noSuchMethod`, which throws, so a use case that
/// called one fails loudly rather than passing quietly.
final class _Git implements GitRepository {
  Result<void, GitFailure>? answer;
  bool throws = false;
  int pulled = 0;

  /// Where `HEAD` is before the pull.
  CommitShaValueObject? before = CommitShaValueObject('c' * 40);
  bool headThrows = false;

  /// What the count answers, unless [countFailure] is set.
  int count = 0;
  GitFailure? countFailure;
  final List<CommitShaValueObject?> countedSince = <CommitShaValueObject?>[];

  /// The calls, in the order they came.
  final List<String> order = <String>[];

  @override
  Future<Result<CommitShaValueObject?, GitFailure>> head() async {
    order.add('head');
    return headThrows
        ? throw StateError('git fell over')
        : Success<CommitShaValueObject?, GitFailure>(before);
  }

  @override
  Future<Result<void, GitFailure>> pull() async {
    order.add('pull');
    pulled++;
    return throws
        ? throw StateError('git fell over')
        : (answer ?? const Success<void, GitFailure>(null));
  }

  @override
  Future<Result<int, GitFailure>> upstreamCommitsSince(
    CommitShaValueObject? since,
  ) async {
    order.add('count');
    countedSince.add(since);
    return switch (countFailure) {
      final GitFailure failure => Failure<int, GitFailure>(failure),
      null => Success<int, GitFailure>(count),
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
