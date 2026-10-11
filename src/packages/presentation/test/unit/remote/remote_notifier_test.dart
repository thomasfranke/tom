import 'dart:async';

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Git git;
  late _Preferences preferences;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  GitStatusValueObject statusOf({int ahead = 0, int behind = 0}) =>
      GitStatusValueObject(
        branch: BranchNameValueObject('main'),
        upstream: BranchNameValueObject('origin/main'),
        ahead: ahead,
        behind: behind,
        entries: const <StatusEntryValueObject>[],
        isDetached: false,
      );

  setUp(() {
    git = _Git()..reported = statusOf(ahead: 2);
    preferences = _Preferences();
    container = ProviderContainer(
      overrides: <Override>[
        readPreferencesProvider.overrideWithValue(
          ReadPreferencesUseCase(preferences: preferences),
        ),
        readGitStatusProvider.overrideWithValue(
          ReadGitStatusUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        readMergeStateProvider.overrideWithValue(
          ReadMergeStateUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        stageChangesProvider.overrideWithValue(
          StageChangesUseCase(
            gitFor: (SpaceEntity space) => git,
            documentsFor: (SpaceEntity space) => const _NoDocuments(),
            observability: const _Silent(),
          ),
        ),
        commitChangesProvider.overrideWithValue(
          CommitChangesUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        fetchRemoteProvider.overrideWithValue(
          FetchRemoteUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        pullRemoteProvider.overrideWithValue(
          PullRemoteUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        pushRemoteProvider.overrideWithValue(
          PushRemoteUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        abortPullProvider.overrideWithValue(
          AbortPullUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        // A pull writes to the working tree, so it walks the tree again —
        // which means a test that pulls needs a folder to walk.
        listSpaceEntriesProvider.overrideWithValue(
          const ListSpaceEntriesUseCase(
            spaces: _NothingInIt(),
            observability: _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts both notifiers over an open space, and lets the first read land.
  Future<void> open() async {
    container
      ..listen<RemoteState>(remoteProvider, (_, _) {})
      ..listen<ChangesState>(changesProvider, (_, _) {})
      ..read(spaceSessionProvider.notifier).open(docs);
    await Future<void>.delayed(Duration.zero);
  }

  RemoteState remote() => container.read(remoteProvider);

  /// What the whole window knows about git.
  GitStatusValueObject? observed() => container.read(spaceSessionProvider)?.git;

  test('with no space open nothing reaches git', () async {
    container.listen<RemoteState>(remoteProvider, (_, _) {});

    await container.read(remoteProvider.notifier).fetch();

    expect(git.fetched, 0);
    expect(remote(), isA<RemoteIdle>());
  });

  group('fetch', () {
    test('it asks the remote and re-reads where the branch stands', () async {
      await open();
      git.reported = statusOf(ahead: 2, behind: 3);

      await container.read(remoteProvider.notifier).fetch();

      expect(git.fetched, 1);
      expect(observed()?.behind, 3);
      expect(remote(), isA<RemoteIdle>());
    });

    test('it changes no file on disk', () async {
      await open();

      await container.read(remoteProvider.notifier).fetch();

      expect(git.pulled, 0);
    });
  });

  group('push', () {
    test('a rejection is its own state, not a failure among others', () async {
      await open();
      git.answer = const Failure<void, GitFailure>(GitPushRejected());

      await container.read(remoteProvider.notifier).push();

      expect(remote(), isA<RemoteRejected>());
    });

    test('and the counts are read again even so', () async {
      await open();
      git
        ..answer = const Failure<void, GitFailure>(GitPushRejected())
        ..reported = statusOf(ahead: 2, behind: 3);

      await container.read(remoteProvider.notifier).push();

      expect(observed()?.behind, 3);
    });

    test('anything else keeps the action it failed on', () async {
      await open();
      git.answer = const Failure<void, GitFailure>(GitAuthenticationFailed());

      await container.read(remoteProvider.notifier).push();

      final RemoteFailed failed = remote() as RemoteFailed;
      expect(failed.action, RemoteActionEnum.push);
      expect(failed.failure, const GitAuthenticationFailed());
    });

    test('a push that landed keeps how many commits it published', () async {
      await open();

      await container.read(remoteProvider.notifier).push();

      expect(remote(), const RemoteState.idle(published: 2));
    });

    test('the next action takes the news away', () async {
      await open();
      await container.read(remoteProvider.notifier).push();

      await container.read(remoteProvider.notifier).fetch();

      expect(remote(), const RemoteState.idle());
    });
  });

  group('the link', () {
    test('a healthy link says nothing', () async {
      await open();

      await container.read(remoteProvider.notifier).fetch();

      expect(remote().link, isNull);
    });

    for (final (GitFailure failure, LinkStateEnum link)
        in <(GitFailure, LinkStateEnum)>[
          (const GitNetworkUnavailable(), LinkStateEnum.noNetwork),
          (const GitAuthenticationFailed(), LinkStateEnum.credentialsRefused),
          (const GitNoRemote(), LinkStateEnum.noRemote),
          (const GitTimedOut(), LinkStateEnum.timedOut),
        ]) {
      test('${failure.runtimeType} is ${link.name}', () async {
        await open();
        git.answer = Failure<void, GitFailure>(failure);

        await container.read(remoteProvider.notifier).fetch();

        expect(remote().link, link);
      });
    }

    test('a failure about something else says nothing about the link', () {
      expect(LinkStateEnum.of(const GitOperationFailed()), isNull);
    });

    test('only a timeout leaves the buttons live', () {
      expect(
        LinkStateEnum.values.where((LinkStateEnum it) => it.isPressable),
        <LinkStateEnum>[LinkStateEnum.timedOut],
      );
    });

    test('a request that lands clears it', () async {
      await open();
      git.answer = const Failure<void, GitFailure>(GitNetworkUnavailable());
      await container.read(remoteProvider.notifier).fetch();
      git.answer = null;

      await container.read(remoteProvider.notifier).fetch();

      expect(remote().link, isNull);
    });

    test('Reload forgets it, so the buttons are offered again', () async {
      await open();
      git.answer = const Failure<void, GitFailure>(GitNetworkUnavailable());
      await container.read(remoteProvider.notifier).fetch();

      container.read(remoteProvider.notifier).recheck();

      expect(remote().link, isNull);
    });
  });

  test('pull brings the commits in and re-reads', () async {
    await open();
    git.reported = statusOf();

    await container.read(remoteProvider.notifier).pull();

    expect(git.pulled, 1);
    expect(observed()?.behind, 0);
  });

  group('a pull that worked', () {
    test('keeps how many commits arrived', () async {
      await open();
      git.arrived = 3;

      await container.read(remoteProvider.notifier).pull();

      expect(remote(), const RemoteState.idle(arrived: 3));
      expect(git.countedSince, CommitShaValueObject('a' * 40));
    });

    test('says so when the space was already level', () async {
      await open();
      git.arrived = 0;

      await container.read(remoteProvider.notifier).pull();

      expect(remote(), const RemoteState.idle(arrived: 0));
    });

    test('the news goes when the next action starts', () async {
      await open();
      await container.read(remoteProvider.notifier).pull();
      git.holdUp = true;

      final Future<void> fetching = container
          .read(remoteProvider.notifier)
          .fetch();
      expect(remote(), isA<RemoteWorking>());
      git.release();
      await fetching;

      expect(remote(), const RemoteState.idle());
    });

    test('a pull that failed keeps no count', () async {
      await open();
      git.answer = const Failure<void, GitFailure>(GitNetworkUnavailable());

      await container.read(remoteProvider.notifier).pull();

      expect(remote(), isA<RemoteFailed>());
    });

    test('a fetch or a push never carries one', () async {
      await open();

      await container.read(remoteProvider.notifier).fetch();
      expect(remote(), const RemoteState.idle());
      await container.read(remoteProvider.notifier).push();
      expect((remote() as RemoteIdle).arrived, isNull);
    });
  });

  test('one action at a time, and the state says which', () async {
    await open();
    git.holdUp = true;

    final Future<void> fetching = container
        .read(remoteProvider.notifier)
        .fetch();
    expect((remote() as RemoteWorking).action, RemoteActionEnum.fetch);
    await container.read(remoteProvider.notifier).push();
    expect(git.pushed, 0);

    git.release();
    await fetching;
    expect(remote(), isA<RemoteIdle>());
  });

  group('abort', () {
    test('with no space open nothing reaches git', () async {
      container.listen<RemoteState>(remoteProvider, (_, _) {});

      await container.read(remoteProvider.notifier).abort();

      expect(git.aborted, 0);
    });

    test('it undoes the merge and re-reads where the branch stands', () async {
      await open();
      git.reported = statusOf(behind: 3);

      await container.read(remoteProvider.notifier).abort();

      expect(git.aborted, 1);
      expect(observed()?.behind, 3);
      expect(remote(), isA<RemoteIdle>());
    });

    test('a refused abort is said as the pull failing', () async {
      await open();
      git.abortAnswer = const Failure<void, GitFailure>(GitOperationFailed());

      await container.read(remoteProvider.notifier).abort();

      final RemoteFailed failed = remote() as RemoteFailed;
      expect(failed.action, RemoteActionEnum.pull);
      expect(failed.failure, const GitOperationFailed());
    });

    test('not while a request to the remote is out', () async {
      await open();
      git.holdUp = true;
      final Future<void> fetching = container
          .read(remoteProvider.notifier)
          .fetch();

      await container.read(remoteProvider.notifier).abort();
      expect(git.aborted, 0);

      git.release();
      await fetching;
    });
  });

  test('another space starts with nothing said about the last one', () async {
    await open();
    git.answer = const Failure<void, GitFailure>(GitPushRejected());
    await container.read(remoteProvider.notifier).push();
    expect(remote(), isA<RemoteRejected>());

    git.answer = null;
    container
        .read(spaceSessionProvider.notifier)
        .open(
          SpaceEntity(
            root: '/code/other',
            repositoryRoot: '/code/other',
            name: 'other',
          ),
        );
    await Future<void>.delayed(Duration.zero);

    expect(remote(), isA<RemoteIdle>());
  });

  group('a command the person refuses', () {
    test('is not a failure: no band, and git is read again', () async {
      await open();
      git
        ..answer = const Failure<void, GitFailure>(GitCommandDenied())
        ..reported = statusOf(ahead: 3);

      await container.read(remoteProvider.notifier).push();

      expect(remote(), const RemoteState.idle());
      expect(remote().link, isNull);
      expect(observed()?.ahead, 3);
    });

    test('a refused pull keeps no count and walks no tree', () async {
      await open();
      git.answer = const Failure<void, GitFailure>(GitCommandDenied());

      await container.read(remoteProvider.notifier).pull();

      expect(remote(), const RemoteState.idle());
    });

    test('a refused abort says nothing either', () async {
      await open();
      git.abortAnswer = const Failure<void, GitFailure>(GitCommandDenied());

      await container.read(remoteProvider.notifier).abort();

      expect(remote(), isA<RemoteIdle>());
    });
  });

  group('waiting for approval', () {
    late CommandsNotifier commands;

    /// Opens the space in Manual, with git asking the gate before it pushes.
    setUp(() async {
      preferences.held = const PreferencesValueObject(
        gitApprovals: GitApprovalModeEnum.manual,
      );
      await open();
      commands = container.read(commandsProvider.notifier);
      git
        ..gate = commands
        ..holdUp = true;
      container.listen<bool>(remoteAwaitingApprovalProvider, (_, _) {});
    });

    bool awaiting() => container.read(remoteAwaitingApprovalProvider);

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('nothing waits while nothing was pressed', () {
      expect(awaiting(), isFalse);
    });

    test('the pressed control waits, and nothing is on the network', () async {
      final Future<void> pushing = container
          .read(remoteProvider.notifier)
          .push();
      await settle();

      expect(remote(), const RemoteState.working(RemoteActionEnum.push));
      expect(remote().isBusy, isTrue, reason: 'the other two are unavailable');
      expect(awaiting(), isTrue);
      expect(git.pushed, 0);
      expect(
        container.read(commandsProvider).rows.single.action,
        CommandActionEnum.push,
      );

      commands.run(container.read(commandsProvider).rows.single.id);
      await settle();

      expect(awaiting(), isFalse, reason: 'it is running now');
      expect(remote().isBusy, isTrue);
      expect(git.pushed, 1);

      git.release();
      await pushing;

      expect(remote(), isA<RemoteIdle>());
    });

    test('refused, the control is back as it was, with no band', () async {
      final Future<void> pushing = container
          .read(remoteProvider.notifier)
          .push();
      await settle();

      commands.deny(container.read(commandsProvider).rows.single.id);
      await pushing;

      expect(remote(), const RemoteState.idle());
      expect(awaiting(), isFalse);
      expect(git.pushed, 0);
    });

    test('each remote action is named for the panel', () {
      expect(RemoteActionEnum.fetch.command, CommandActionEnum.fetch);
      expect(RemoteActionEnum.pull.command, CommandActionEnum.pull);
      expect(RemoteActionEnum.push.command, CommandActionEnum.push);
    });
  });
}

/// The preferences a machine holds.
final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;

  @override
  Future<PreferencesValueObject> read() async => held;

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async {
    held = preferences;
    return const Success<void, AppFailure>(null);
  }
}

/// Git, answering what the test set and remembering what it was asked.
final class _Git implements GitRepository {
  /// What a push asks before it starts, when a test gives it one.
  CommandGate? gate;

  GitStatusValueObject? reported;
  Result<void, GitFailure>? answer;

  /// What undoing the merge answers; success when left out.
  Result<void, GitFailure>? abortAnswer;

  int fetched = 0;
  int pulled = 0;
  int pushed = 0;
  int aborted = 0;

  /// Whether a remote action should wait to be let go.
  bool holdUp = false;
  Completer<void>? _held;

  /// Lets whatever is waiting finish.
  void release() {
    _held?.complete();
    _held = null;
    holdUp = false;
  }

  /// Where `origin` is: fetching and pulling ask before they start.
  @override
  Future<Result<String?, GitFailure>> remoteAddress() async =>
      const Success<String?, GitFailure>('https://example.test/docs.git');

  Future<Result<void, GitFailure>> _done() async {
    if (holdUp) {
      _held = Completer<void>();
      await _held!.future;
    }
    return answer ?? const Success<void, GitFailure>(null);
  }

  @override
  Future<Result<GitStatusValueObject, GitFailure>> status() async =>
      Success<GitStatusValueObject, GitFailure>(reported!);

  @override
  Future<Result<void, GitFailure>> fetch() {
    fetched++;
    return _done();
  }

  @override
  Future<Result<void, GitFailure>> pull() {
    pulled++;
    return _done();
  }

  /// How many commits the upstream is said to have brought.
  int arrived = 1;
  CommitShaValueObject? countedSince;

  @override
  Future<Result<CommitShaValueObject?, GitFailure>> head() async =>
      Success<CommitShaValueObject?, GitFailure>(
        CommitShaValueObject('a' * 40),
      );

  @override
  Future<Result<int, GitFailure>> upstreamCommitsSince(
    CommitShaValueObject? since,
  ) async {
    countedSince = since;
    return Success<int, GitFailure>(arrived);
  }

  @override
  Future<Result<void, GitFailure>> push() async {
    // As the capability does: the gate first, and nothing runs on a no.
    final CommandVerdict? verdict = await gate?.ask(
      const CommandRequest(
        key: 'git push',
        executable: 'git',
        arguments: <String>['push'],
        isWrite: true,
      ),
    );
    if (verdict is CommandDenied) {
      return const Failure<void, GitFailure>(GitCommandDenied());
    }
    pushed++;
    final Result<void, GitFailure> done = await _done();
    if (verdict case CommandRun(:final int ticket)) {
      (gate! as CommandLog).record(
        CommandRecord.of(
          executable: 'git',
          arguments: const <String>['push'],
          startedAt: DateTime(2026, 10, 9),
          duration: Duration.zero,
          exitCode: 0,
          ticket: ticket,
        ),
      );
    }
    return done;
  }

  @override
  Future<Result<void, GitFailure>> abortMerge() async {
    aborted++;
    return abortAnswer ?? const Success<void, GitFailure>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A space that holds nothing, so the tree has nothing to draw.
final class _NothingInIt implements SpaceRepository {
  const _NothingInIt();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => const Success<List<SpaceEntryValueObject>, SpaceFailure>(
    <SpaceEntryValueObject>[],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The no-op observability, which is also the shipping default.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}

/// Documents nothing can be read from, so the marker check finds nothing to
/// refuse and staging behaves as it did before the check existed.
final class _NoDocuments implements DocumentRepository {
  const _NoDocuments();

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async =>
      Failure<DocumentEntity, DocumentFailure>(DocumentNotFound(path.value));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      throw UnimplementedError();
}
