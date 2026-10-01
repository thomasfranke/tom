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
  final BranchNameValueObject main = BranchNameValueObject('main');

  setUp(() {
    observability = _RecordingObservability();
    git = _Git();
  });

  SwitchBranchUseCase switching() => SwitchBranchUseCase(
    gitFor: (SpaceEntity space) => git,
    observability: observability,
  );

  test('switching checks the branch out', () async {
    final Result<void, AppFailure> result = await switching().switchTo(
      docs,
      main,
    );

    expect(result, isA<Success<void, AppFailure>>());
    expect(git.switched, <BranchNameValueObject>[main]);
    expect(git.created, isEmpty);
  });

  test('creating starts it and never merely names it', () async {
    final Result<void, AppFailure> result = await switching().create(
      docs,
      main,
    );

    expect(result, isA<Success<void, AppFailure>>());
    expect(git.created, <BranchNameValueObject>[main]);
    expect(git.switched, isEmpty);
  });

  test('the repository is built for the space it was asked about', () async {
    final List<SpaceEntity> asked = <SpaceEntity>[];

    await SwitchBranchUseCase(
      gitFor: (SpaceEntity space) {
        asked.add(space);
        return git;
      },
      observability: observability,
    ).switchTo(docs, main);

    expect(asked, <SpaceEntity>[docs]);
  });

  test('a refusal arrives as itself', () async {
    git.answer = const Failure<void, GitFailure>(GitOperationFailed());

    final Result<void, AppFailure> result = await switching().switchTo(
      docs,
      main,
    );

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<GitOperationFailed>(),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    git.throws = true;

    final Result<void, AppFailure> result = await switching().create(
      docs,
      main,
    );

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// Git, answering the two branch moves and refusing every other question.
final class _Git implements GitRepository {
  Result<void, GitFailure>? answer;
  bool throws = false;

  final List<BranchNameValueObject> switched = <BranchNameValueObject>[];
  final List<BranchNameValueObject> created = <BranchNameValueObject>[];

  Result<void, GitFailure> get _answer => throws
      ? throw StateError('git fell over')
      : (answer ?? const Success<void, GitFailure>(null));

  @override
  Future<Result<void, GitFailure>> switchBranch(
    BranchNameValueObject name,
  ) async {
    switched.add(name);
    return _answer;
  }

  @override
  Future<Result<void, GitFailure>> createBranch(
    BranchNameValueObject name,
  ) async {
    created.add(name);
    return _answer;
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
