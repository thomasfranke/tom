/// The diff's base follows the branch, read by a real use case over a
/// recorded repository.
library;

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Git git;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  GitStatusValueObject on(String? branch, {int ahead = 0}) =>
      GitStatusValueObject(
        branch: branch == null ? null : BranchNameValueObject(branch),
        upstream: null,
        ahead: ahead,
        behind: 0,
        entries: const <StatusEntryValueObject>[],
        isDetached: branch == null,
      );

  BranchRefValueObject local(String name) =>
      BranchRefValueObject(name: BranchNameValueObject(name));

  setUp(() {
    git = _Git();
    container = ProviderContainer(
      overrides: <Override>[
        readDiffBaseProvider.overrideWithValue(
          ReadDiffBaseUseCase(
            gitFor: (SpaceEntity _) => git,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    // What the shell does: make it exist, and keep it.
    container.listen<void>(diffBaseProvider, (_, _) {});
  });

  /// Everything scheduled, run.
  Future<void> settle() async {
    for (int i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  SpaceSessionNotifier session() =>
      container.read(spaceSessionProvider.notifier);

  BranchRefValueObject? base() =>
      container.read(spaceSessionProvider)?.comparingAgainst?.branch;

  CommitShaValueObject? fork() =>
      container.read(spaceSessionProvider)?.comparingAgainst?.forkPoint;

  test('nothing is read before git says where HEAD is', () async {
    session().open(docs);
    await settle();

    expect(git.reads, 0);
    expect(base(), isNull);
  });

  test('the first git reading brings the base', () async {
    git.current = 'feat/glossary';
    session()
      ..open(docs)
      ..observe(on('feat/glossary'));
    await settle();

    expect(base(), local('develop'));
    expect(fork(), CommitShaValueObject(_Git.firstFork));
    expect(git.forkAskedAbout, BranchNameValueObject('develop'));
  });

  test('a switch reads it again, onto the new branch\'s', () async {
    git.current = 'feat/glossary';
    session()
      ..open(docs)
      ..observe(on('feat/glossary'));
    await settle();

    git.current = 'develop';
    session().observe(on('develop'));
    await settle();

    expect(base(), local('main'));
  });

  test('switching onto the default branch compares against HEAD', () async {
    git.current = 'feat/glossary';
    session()
      ..open(docs)
      ..observe(on('feat/glossary'));
    await settle();

    git.current = 'main';
    session().observe(on('main'));
    await settle();

    expect(base(), isNull);
  });

  test('a branch started here is read with what it recorded', () async {
    git.current = 'develop';
    session()
      ..open(docs)
      ..observe(on('develop'));
    await settle();

    // What `SwitchBranchUseCase.create` leaves behind, then the re-read.
    git
      ..current = 'feat/new'
      ..recorded['feat/new'] = 'develop';
    session().observe(on('feat/new'));
    await settle();

    expect(base(), local('develop'));
  });

  test(
    'another reading of the same branch only moves the fork point',
    () async {
      git.current = 'feat/glossary';
      session()
        ..open(docs)
        ..observe(on('feat/glossary'));
      await settle();
      final int reads = git.reads;

      // A merge of develop into the branch: the status again, the branch the
      // same, and the point it left develop at is now later.
      git.fork = _Git.laterFork;
      session().observe(on('feat/glossary', ahead: 2));
      await settle();

      expect(git.reads, reads, reason: 'the whole base was read again');
      expect(base(), local('develop'));
      expect(fork(), CommitShaValueObject(_Git.laterFork));
    },
  );

  test('detached compares against HEAD', () async {
    git.current = 'feat/glossary';
    session()
      ..open(docs)
      ..observe(on('feat/glossary'));
    await settle();

    git.current = null;
    session().observe(on(null));
    await settle();

    expect(base(), isNull);
  });

  test('a failure to read is HEAD, never a stale base', () async {
    git.current = 'feat/glossary';
    session()
      ..open(docs)
      ..observe(on('feat/glossary'));
    await settle();

    git
      ..current = 'feat/other'
      ..fails = true;
    session().observe(on('feat/other'));
    await settle();

    expect(base(), isNull);
  });

  test('a reading the person refused keeps the base that was there', () async {
    git.current = 'feat/glossary';
    session()
      ..open(docs)
      ..observe(on('feat/glossary'));
    await settle();

    git
      ..current = 'feat/other'
      ..refuses = true;
    session().observe(on('feat/other'));
    await settle();

    expect(base(), local('develop'), reason: 'out of date, and left alone');
    expect(fork(), CommitShaValueObject(_Git.firstFork));
  });

  test('and it is asked again the next time git is read', () async {
    git
      ..current = 'feat/glossary'
      ..refuses = true;
    session()
      ..open(docs)
      ..observe(on('feat/glossary'));
    await settle();
    final int asked = git.reads;

    await settle();
    expect(git.reads, asked, reason: 'nothing asks on its own');

    git.refuses = false;
    session().observe(on('feat/glossary', ahead: 1));
    await settle();

    expect(base(), local('develop'));
  });

  test('another space starts with no base and reads its own', () async {
    git.current = 'feat/glossary';
    session()
      ..open(docs)
      ..observe(on('feat/glossary'));
    await settle();

    session().open(
      SpaceEntity(root: '/elsewhere', repositoryRoot: '/elsewhere', name: 'x'),
    );
    expect(base(), isNull);
    session().observe(on('feat/glossary'));
    await settle();

    expect(base(), local('develop'));
  });
}

/// A repository with `main`, `develop` off it, and branches off `develop`;
/// [current] is the one checked out, null for detached.
final class _Git implements GitRepository {
  static const String firstFork = 'abc1234def5678901234567890abcdef12345678';
  static const String laterFork = 'fedcba9876543210fedcba9876543210fedcba98';

  String? current;
  bool fails = false;

  /// Whether the person says no to the reading.
  bool refuses = false;
  int reads = 0;
  final Map<String, String> recorded = <String, String>{};

  /// Where `HEAD` left the base, and the base it was asked about.
  String fork = firstFork;
  BranchNameValueObject? forkAskedAbout;

  @override
  Future<Result<CommitShaValueObject?, GitFailure>> forkPoint(
    BranchNameValueObject base,
  ) async {
    forkAskedAbout = base;
    return Success<CommitShaValueObject?, GitFailure>(
      CommitShaValueObject(fork),
    );
  }

  /// How far `HEAD` has come since each branch, by where [current] is.
  static const Map<String, Map<String, int>> _behind =
      <String, Map<String, int>>{
        'main': <String, int>{'main': 0, 'develop': 0},
        'develop': <String, int>{'main': 1, 'develop': 0},
        'feat/glossary': <String, int>{'main': 2, 'develop': 1},
        'feat/other': <String, int>{'main': 2, 'develop': 1},
        'feat/new': <String, int>{'main': 1, 'develop': 0},
      };

  @override
  Future<Result<List<BranchEntity>, GitFailure>> branches() async {
    reads += 1;
    if (refuses) {
      return const Failure<List<BranchEntity>, GitFailure>(GitCommandDenied());
    }
    if (fails) {
      return const Failure<List<BranchEntity>, GitFailure>(
        GitOperationFailed(),
      );
    }
    return Success<List<BranchEntity>, GitFailure>(<BranchEntity>[
      if (current case final String name)
        BranchEntity(name: BranchNameValueObject(name), isCurrent: true),
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
  ) async => Success<BranchNameValueObject?, GitFailure>(
    BranchNameValueObject.tryParse(recorded[branch.value] ?? ''),
  );

  @override
  Future<Result<List<BranchStandingValueObject>, GitFailure>>
  standings() async => Success<List<BranchStandingValueObject>, GitFailure>(
    <BranchStandingValueObject>[
      for (final MapEntry<String, int> it
          in (_behind[current] ?? const <String, int>{}).entries)
        BranchStandingValueObject(
          branch: BranchRefValueObject(name: BranchNameValueObject(it.key)),
          ahead: 0,
          behind: it.value,
          sharesHistory: true,
        ),
    ],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Observability that drops everything.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
