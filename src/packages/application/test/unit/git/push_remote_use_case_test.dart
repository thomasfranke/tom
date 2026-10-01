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
}

/// Git, answering `push` and refusing every other question.
///
/// The rest is left to `noSuchMethod`, which throws, so a use case that
/// called one fails loudly rather than passing quietly.
final class _Git implements GitRepository {
  Result<void, GitFailure>? answer;
  bool throws = false;
  int pushed = 0;

  @override
  Future<Result<void, GitFailure>> push() async {
    pushed++;
    return throws
        ? throw StateError('git fell over')
        : (answer ?? const Success<void, GitFailure>(null));
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
