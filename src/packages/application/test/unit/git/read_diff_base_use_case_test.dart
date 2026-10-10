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

  BranchRefValueObject local(String name) =>
      BranchRefValueObject(name: BranchNameValueObject(name));

  setUp(() {
    observability = _RecordingObservability();
    git = _Git();
  });

  ReadDiffBaseUseCase useCase() => ReadDiffBaseUseCase(
    gitFor: (SpaceEntity space) => git,
    observability: observability,
  );

  Future<Result<DiffBaseValueObject?, AppFailure>> read() =>
      useCase().read(docs);

  DiffBaseValueObject? baseOf(Result<DiffBaseValueObject?, AppFailure> r) =>
      (r as Success<DiffBaseValueObject?, AppFailure>).value;

  test('asks git and lets the rule decide', () async {
    expect(baseOf(await read())?.branch, local('develop'));
  });

  test('the diff is read where HEAD left the base, not at its tip', () async {
    // What the base did since the branch left it is not this branch's
    // change (`docs/product/diff/branch-diff/doc.md`).
    expect(baseOf(await read())?.forkPoint, _Git.fork);
    expect(git.forkAskedAbout, BranchNameValueObject('develop'));
  });

  test('a base sharing no history is HEAD', () async {
    git.forkAnswer = const Success<CommitShaValueObject?, GitFailure>(null);

    expect(baseOf(await read()), isNull);
  });

  test('what was recorded is handed to the rule', () async {
    git.recorded = BranchNameValueObject('main');

    expect(baseOf(await read())?.branch, local('main'));
    expect(git.askedAbout, BranchNameValueObject('feat/glossary'));
  });

  test('detached is HEAD, without asking anything else', () async {
    git.current = null;

    expect(baseOf(await read()), isNull);
    expect(git.standingsRead, isFalse);
  });

  test('a refresh asks only where HEAD left the branch', () async {
    final DiffBaseValueObject? base = baseOf(
      await useCase().refresh(docs, local('develop')),
    );

    expect(
      base,
      DiffBaseValueObject(branch: local('develop'), forkPoint: _Git.fork),
    );
    expect(git.standingsRead, isFalse);
  });

  test('a refusal arrives as itself', () async {
    git.standingsAnswer =
        const Failure<List<BranchStandingValueObject>, GitFailure>(
          GitOperationFailed(),
        );

    final Result<DiffBaseValueObject?, AppFailure> result = await read();

    expect(
      (result as Failure<DiffBaseValueObject?, AppFailure>).failure,
      isA<GitOperationFailed>(),
    );
  });

  test('an exception never escapes the use case, and is reported', () async {
    git.throws = true;

    final Result<DiffBaseValueObject?, AppFailure> result = await read();

    expect(
      (result as Failure<DiffBaseValueObject?, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// Git on `feat/glossary`, started from `develop` off `main`.
final class _Git implements GitRepository {
  static final CommitShaValueObject fork = CommitShaValueObject(
    'abc1234def5678901234567890abcdef12345678',
  );

  BranchNameValueObject? current = BranchNameValueObject('feat/glossary');
  BranchNameValueObject? recorded;
  BranchNameValueObject? askedAbout;
  BranchNameValueObject? forkAskedAbout;
  bool standingsRead = false;
  bool throws = false;

  Result<List<BranchStandingValueObject>, GitFailure>? standingsAnswer;
  Result<CommitShaValueObject?, GitFailure>? forkAnswer;

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async {
    if (throws) {
      throw StateError('git fell over');
    }
    return Success<List<BranchEntity>, GitFailure>(<BranchEntity>[
      BranchEntity(name: BranchNameValueObject('main'), isCurrent: false),
      if (current case final BranchNameValueObject name)
        BranchEntity(name: name, isCurrent: true),
    ]);
  }

  @override
  Future<Result<BranchNameValueObject?, GitFailure>> defaultBranch() async =>
      Success<BranchNameValueObject?, GitFailure>(
        BranchNameValueObject('main'),
      );

  @override
  Future<Result<BranchNameValueObject?, GitFailure>> recordedBase(
    BranchNameValueObject branch,
  ) async {
    askedAbout = branch;
    return Success<BranchNameValueObject?, GitFailure>(recorded);
  }

  @override
  Future<Result<CommitShaValueObject?, GitFailure>> forkPoint(
    BranchNameValueObject base,
  ) async {
    forkAskedAbout = base;
    return forkAnswer ?? Success<CommitShaValueObject?, GitFailure>(fork);
  }

  @override
  Future<Result<List<BranchStandingValueObject>, GitFailure>>
  standings() async {
    standingsRead = true;
    return standingsAnswer ??
        Success<List<BranchStandingValueObject>, GitFailure>(
          <BranchStandingValueObject>[
            for (final (String name, int behind) in const <(String, int)>[
              ('main', 2),
              ('develop', 1),
              ('feat/glossary', 0),
            ])
              BranchStandingValueObject(
                branch: BranchRefValueObject(name: BranchNameValueObject(name)),
                ahead: 0,
                behind: behind,
                sharesHistory: true,
              ),
          ],
        );
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
