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

  PushRemoteUseCase pushing() => PushRemoteUseCase(
    gitFor: (SpaceEntity space) => git,
    observability: observability,
  );

  test('it publishes the branch', () async {
    final Result<void, AppFailure> result = await pushing().push(docs);

    expect(result, isA<Success<void, AppFailure>>());
    expect(git.pushed, 1);
  });

  test('the repository is built for the space it was asked about', () async {
    final List<SpaceEntity> asked = <SpaceEntity>[];

    await PushRemoteUseCase(
      gitFor: (SpaceEntity space) {
        asked.add(space);
        return git;
      },
      observability: observability,
    ).push(docs);

    expect(asked, <SpaceEntity>[docs]);
  });

  test('a rejection arrives as itself, not as a general failure', () async {
    git.answer = const Failure<void, GitFailure>(GitPushRejected());

    final Result<void, AppFailure> result = await pushing().push(docs);

    expect(
      (result as Failure<void, AppFailure>).failure,
      const GitPushRejected(),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    git.throws = true;

    final Result<void, AppFailure> result = await pushing().push(docs);

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });

  group('a branch that tracks nothing', () {
    test('is published under its own name, not pushed', () async {
      git.upstream = null;

      final Result<void, AppFailure> result = await pushing().push(docs);

      expect(result, isA<Success<void, AppFailure>>());
      expect(git.published, <BranchNameValueObject>[
        BranchNameValueObject('feat/notes'),
      ]);
      expect(git.pushed, 0);
    });

    test('a detached HEAD is left to git to refuse', () async {
      git
        ..upstream = null
        ..detached = true;

      await pushing().push(docs);

      expect(git.published, isEmpty);
      expect(git.pushed, 1);
    });
  });

  test('a status git will not give stops the push before it starts', () async {
    git.statusFailure = const GitNotARepository('/code/app');

    final Result<void, AppFailure> result = await pushing().push(docs);

    expect(
      (result as Failure<void, AppFailure>).failure,
      const GitNotARepository('/code/app'),
    );
    expect(git.pushed, 0);
    expect(git.published, isEmpty);
  });
}

/// Git, answering `status`, `push` and `publish` and refusing every other
/// question.
///
/// The rest is left to `noSuchMethod`, which throws, so a use case that
/// called one fails loudly rather than passing quietly.
final class _Git implements GitRepository {
  Result<void, GitFailure>? answer;
  bool throws = false;
  int pushed = 0;
  final List<BranchNameValueObject> published = <BranchNameValueObject>[];

  /// What the status says the branch tracks; null is nothing.
  BranchNameValueObject? upstream = BranchNameValueObject('origin/feat/notes');
  bool detached = false;
  GitFailure? statusFailure;

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async =>
      switch (statusFailure) {
        final GitFailure failure => Failure<GitStatusValueObject, GitFailure>(
          failure,
        ),
        null => Success<GitStatusValueObject, GitFailure>(
          GitStatusValueObject(
            branch: detached ? null : BranchNameValueObject('feat/notes'),
            upstream: upstream,
            ahead: 1,
            behind: 0,
            entries: const <StatusEntryValueObject>[],
            isDetached: detached,
          ),
        ),
      };

  @override
  Future<Result<void, GitFailure>> push() async {
    pushed++;
    return throws
        ? throw StateError('git fell over')
        : (answer ?? const Success<void, GitFailure>(null));
  }

  @override
  Future<Result<void, GitFailure>> publish(BranchNameValueObject branch) async {
    published.add(branch);
    return answer ?? const Success<void, GitFailure>(null);
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
