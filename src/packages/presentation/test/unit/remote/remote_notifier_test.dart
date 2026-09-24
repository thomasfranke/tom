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
    container = ProviderContainer(
      overrides: <Override>[
        readGitStatusProvider.overrideWithValue(
          ReadGitStatusUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        stageChangesProvider.overrideWithValue(
          StageChangesUseCase(
            gitFor: (SpaceEntity space) => git,
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
      // Fetch exists so that ahead/behind means something; not re-reading
      // would leave the counter saying what it said before.
      await open();
      git.reported = statusOf(ahead: 2, behind: 3);

      await container.read(remoteProvider.notifier).fetch();

      expect(git.fetched, 1);
      expect(observed()?.behind, 3);
      expect(remote(), isA<RemoteIdle>());
    });

    test('it changes no file on disk', () async {
      // The whole reason it is safe to offer as a plain button.
      await open();

      await container.read(remoteProvider.notifier).fetch();

      expect(git.pulled, 0);
    });
  });

  group('push', () {
    test('a rejection is its own state, not a failure among others', () async {
      // The remote moved first: the product answers it with a screen, so it
      // has to be distinguishable from anything else that can go wrong.
      await open();
      git.answer = const Failure<void, GitFailure>(GitPushRejected());

      await container.read(remoteProvider.notifier).push();

      expect(remote(), isA<RemoteRejected>());
    });

    test('and the counts are read again even so', () async {
      // `git push` can update some refs and refuse others; where the branch
      // stands afterwards is the thing the user needs.
      await open();
      git
        ..answer = const Failure<void, GitFailure>(GitPushRejected())
        ..reported = statusOf(ahead: 2, behind: 3);

      await container.read(remoteProvider.notifier).push();

      expect(observed()?.behind, 3);
    });

    test('anything else keeps the action it failed on', () async {
      // "Push failed" and "pull failed" are different sentences.
      await open();
      git.answer = const Failure<void, GitFailure>(GitAuthenticationFailed());

      await container.read(remoteProvider.notifier).push();

      final RemoteFailed failed = remote() as RemoteFailed;
      expect(failed.action, RemoteActionEnum.push);
      expect(failed.failure, const GitAuthenticationFailed());
    });

    test('a push that landed leaves nothing on screen', () async {
      await open();

      await container.read(remoteProvider.notifier).push();

      expect(remote(), isA<RemoteIdle>());
    });
  });

  test('pull brings the commits in and re-reads', () async {
    await open();
    git.reported = statusOf();

    await container.read(remoteProvider.notifier).pull();

    expect(git.pulled, 1);
    expect(observed()?.behind, 0);
  });

  test('one action at a time, and the state says which', () async {
    // Git serializes per space underneath, so a second press would only
    // queue — and a screen that let it would be lying about what is
    // happening.
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

  test('another space starts with nothing said about the last one', () async {
    // A rejection names a remote; carrying it across would be a sentence
    // about a repository nobody is looking at.
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
}

/// Git, answering what the test set and remembering what it was asked.
final class _Git implements GitRepository {
  GitStatusValueObject? reported;
  Result<void, GitFailure>? answer;

  int fetched = 0;
  int pulled = 0;
  int pushed = 0;

  /// Whether a remote action should wait to be let go.
  bool holdUp = false;
  Completer<void>? _held;

  /// Lets whatever is waiting finish.
  void release() {
    _held?.complete();
    _held = null;
    holdUp = false;
  }

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

  @override
  Future<Result<void, GitFailure>> push() {
    pushed++;
    return _done();
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
