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

  ListBranchesUseCase listing() => ListBranchesUseCase(
    gitFor: (SpaceEntity space) => git,
    observability: observability,
  );

  test('it hands back what git reported, in that order', () async {
    // The order is git's to decide: sorting here would be a second opinion
    // about a list somebody may have configured.
    git.answer = Success<List<BranchEntity>, GitFailure>(<BranchEntity>[
      BranchEntity(name: BranchNameValueObject('main'), isCurrent: true),
      BranchEntity(name: BranchNameValueObject('feat/one'), isCurrent: false),
    ]);

    final Result<List<BranchEntity>, AppFailure> result = await listing().list(
      docs,
    );

    expect(
      (result as Success<List<BranchEntity>, AppFailure>).value
          .map((BranchEntity it) => it.name.value)
          .toList(),
      <String>['main', 'feat/one'],
    );
  });

  test('the repository is built for the space it was asked about', () async {
    final List<SpaceEntity> asked = <SpaceEntity>[];

    await ListBranchesUseCase(
      gitFor: (SpaceEntity space) {
        asked.add(space);
        return git;
      },
      observability: observability,
    ).list(docs);

    expect(asked, <SpaceEntity>[docs]);
  });

  test('a failure arrives as itself', () async {
    git.answer = const Failure<List<BranchEntity>, GitFailure>(
      GitNotARepository('/code/app'),
    );

    final Result<List<BranchEntity>, AppFailure> result = await listing().list(
      docs,
    );

    expect(
      (result as Failure<List<BranchEntity>, AppFailure>).failure,
      isA<GitNotARepository>(),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    git.throws = true;

    final Result<List<BranchEntity>, AppFailure> result = await listing().list(
      docs,
    );

    expect(
      (result as Failure<List<BranchEntity>, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// Git, answering `branches` and refusing every other question.
final class _Git implements GitRepository {
  Result<List<BranchEntity>, GitFailure>? answer;
  bool throws = false;

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async => throws
      ? throw StateError('git fell over')
      : (answer ??
            const Success<List<BranchEntity>, GitFailure>(<BranchEntity>[]));

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
