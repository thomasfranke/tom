/// [DartIoGitClientImpl] against remotes in every state a person's has: none,
/// a missing one, one with no commits, one that moved, one that diverged.
@TestOn('!windows')
library;

// Arranging a repository is a list of commands, not one object configured.
// ignore_for_file: cascade_invocations

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

import '../../../support/git_remote_world.dart';

void main() {
  late GitRemoteWorld world;
  late String work;
  late DartIoGitClientImpl client;

  AppFailure failureOf(Result<Object?, GitClientFailure> result) {
    expect(
      result,
      isA<Failure<Object?, GitClientFailure>>(),
      reason: '$result',
    );
    return (result as Failure<Object?, GitClientFailure>).failure;
  }

  T valueOf<T>(Result<T, GitClientFailure> result) {
    expect(result, isA<Success<T, GitClientFailure>>(), reason: '$result');
    return (result as Success<T, GitClientFailure>).value;
  }

  setUp(() {
    world = GitRemoteWorld();
    work = '${world.base}/work';
  });

  tearDown(() {
    world.dispose();
  });

  /// A repository with one commit and no remote at all.
  void aloneWithOneCommit() {
    world.init(work);
    world.write(work, 'a.md', '# A\n');
    world.commitAll(work, 'Add A');
    client = world.clientIn(work);
  }

  group('with no remote configured', () {
    setUp(aloneWithOneCommit);

    test('fetch has nothing to do and succeeds, as git does', () async {
      expect(await client.fetch(), isA<Success<void, GitClientFailure>>());
    });

    test('pull is git\'s own refusal, not a remote to name', () async {
      final AppFailure failure = failureOf(await client.pull());

      expect(failure, isA<GitClientCommandFailed>());
      expect(
        (failure as GitClientCommandFailed).stderr,
        contains('no tracking information'),
      );
    });

    test('push and publish are GitClientNoRemote', () async {
      expect(failureOf(await client.push()), isA<GitClientNoRemote>());
      expect(failureOf(await client.publish('main')), isA<GitClientNoRemote>());
    });

    test('there is no upstream to count against', () async {
      expect(
        failureOf(await client.upstreamCommitsSince('')),
        isA<GitClientCommandFailed>(),
      );
    });

    test('the questions about a remote are answers, not failures', () async {
      expect(valueOf(await client.remoteUrl()), isEmpty);
      expect(valueOf(await client.defaultBranch()), isEmpty);
    });
  });

  group('with a remote that does not exist', () {
    setUp(() {
      aloneWithOneCommit();
      world.git(<String>[
        'remote',
        'add',
        'origin',
        '${world.base}/nowhere.git',
      ], inside: work);
      world.git(<String>[
        'config',
        'branch.main.remote',
        'origin',
      ], inside: work);
      world.git(<String>[
        'config',
        'branch.main.merge',
        'refs/heads/main',
      ], inside: work);
    });

    test('fetch, pull, push and publish are GitClientNoRemote', () async {
      expect(failureOf(await client.fetch()), isA<GitClientNoRemote>());
      expect(failureOf(await client.pull()), isA<GitClientNoRemote>());
      expect(failureOf(await client.push()), isA<GitClientNoRemote>());
      expect(failureOf(await client.publish('main')), isA<GitClientNoRemote>());
    });

    test('the address is still readable, so it can be shown', () async {
      expect(valueOf(await client.remoteUrl()), '${world.base}/nowhere.git');
    });
  });

  group('with a remote and no upstream', () {
    late String remote;

    setUp(() {
      aloneWithOneCommit();
      remote = '${world.base}/remote.git';
      world.init(remote, bare: true);
      world.git(<String>['remote', 'add', 'origin', remote], inside: work);
    });

    test('push says there is no upstream, which is not "no remote"', () async {
      final AppFailure failure = failureOf(await client.push());

      expect(failure, isA<GitClientCommandFailed>());
      expect(
        (failure as GitClientCommandFailed).stderr,
        contains('no upstream branch'),
      );
    });

    test('pull says there is no tracking information', () async {
      final AppFailure failure = failureOf(await client.pull());

      expect(failure, isA<GitClientCommandFailed>());
      expect((failure as GitClientCommandFailed).stderr, contains('tracking'));
    });

    test('publish makes the branch tracked, and then push works', () async {
      expect(
        await client.publish('main'),
        isA<Success<void, GitClientFailure>>(),
      );

      world.write(work, 'b.md', '# B\n');
      world.commitAll(work, 'Add B');
      expect(await client.push(), isA<Success<void, GitClientFailure>>());
      expect(
        world.say(<String>['log', '--format=%s', '-1', 'main'], inside: remote),
        'Add B',
      );
    });

    test(
      'a remote branch of that name that diverged is a rejected publish',
      () async {
        world.git(<String>['push', '--quiet', 'origin', 'main'], inside: work);
        final String peer = world.peerOf(remote, '${world.base}/peer');
        world.git(<String>[
          'switch',
          '--quiet',
          '--create',
          'draft',
        ], inside: peer);
        world.write(peer, 'p.md', '# Peer\n');
        world.commitAll(peer, 'Peer draft');
        world.git(<String>['push', '--quiet', 'origin', 'draft'], inside: peer);
        world.git(<String>[
          'switch',
          '--quiet',
          '--create',
          'draft',
        ], inside: work);
        world.write(work, 'w.md', '# Mine\n');
        world.commitAll(work, 'My draft');

        final AppFailure failure = failureOf(await client.publish('draft'));

        expect(failure, isA<GitClientPushRejected>());
        // Nothing was claimed: the branch has no upstream yet.
        expect(
          world
              .git(
                <String>['config', '--get', 'branch.draft.remote'],
                inside: work,
                mayFail: true,
              )
              .exitCode,
          isNot(0),
        );
      },
    );

    test('a detached HEAD cannot be pushed', () async {
      world.git(<String>[
        'push',
        '--quiet',
        '-u',
        'origin',
        'main',
      ], inside: work);
      world.git(<String>['switch', '--quiet', '--detach'], inside: work);

      final AppFailure failure = failureOf(await client.push());

      expect(failure, isA<GitClientCommandFailed>());
      expect(
        (failure as GitClientCommandFailed).stderr,
        contains('not currently on a branch'),
      );
    });
  });

  group('with a tracked remote', () {
    late String remote;

    setUp(() {
      remote = world.remoteWithClone(work);
      client = world.clientIn(work);
    });

    test('a detached HEAD can fetch and cannot pull', () async {
      world.git(<String>['switch', '--quiet', '--detach'], inside: work);

      expect(await client.fetch(), isA<Success<void, GitClientFailure>>());
      final AppFailure failure = failureOf(await client.pull());
      expect(failure, isA<GitClientCommandFailed>());
      expect(
        (failure as GitClientCommandFailed).stderr,
        contains('not currently on a branch'),
      );
    });

    test('a pull into an unborn branch brings the remote\'s files', () async {
      final String fresh = '${world.base}/fresh';
      world.init(fresh);
      world.git(<String>['remote', 'add', 'origin', remote], inside: fresh);
      world.git(<String>[
        'config',
        'branch.main.remote',
        'origin',
      ], inside: fresh);
      world.git(<String>[
        'config',
        'branch.main.merge',
        'refs/heads/main',
      ], inside: fresh);
      final DartIoGitClientImpl onFresh = world.clientIn(fresh);

      expect(valueOf(await onFresh.head()), isEmpty);
      expect(await onFresh.pull(), isA<Success<void, GitClientFailure>>());

      expect(File('$fresh/a.md').readAsStringSync(), '# A\n');
      expect(valueOf(await onFresh.head()), isNotEmpty);
    });

    test(
      'upstreamCommitsSince counts what a fetch brought, merged or not',
      () async {
        final String before = valueOf(await client.head());
        final String peer = world.peerOf(remote, '${world.base}/peer');
        world.write(peer, 'p1.md', '# P1\n');
        world.commitAll(peer, 'Peer one');
        world.write(peer, 'p2.md', '# P2\n');
        world.commitAll(peer, 'Peer two');
        world.git(<String>['push', '--quiet'], inside: peer);

        expect(valueOf(await client.upstreamCommitsSince(before)), 0);
        await client.fetch();

        expect(valueOf(await client.upstreamCommitsSince(before)), 2);
        // Nothing was merged by counting.
        expect(File('$work/p1.md').existsSync(), isFalse);
      },
    );

    test(
      'push after the remote moved is rejected and the commit stays',
      () async {
        final String peer = world.peerOf(remote, '${world.base}/peer');
        world.write(peer, 'p.md', '# Peer\n');
        world.commitAll(peer, 'Peer');
        world.git(<String>['push', '--quiet'], inside: peer);
        world.write(work, 'w.md', '# Mine\n');
        world.commitAll(work, 'Mine');

        expect(failureOf(await client.push()), isA<GitClientPushRejected>());
        // The way out the product offers is a pull, then a push.
        expect(await client.pull(), isA<Success<void, GitClientFailure>>());
        expect(await client.push(), isA<Success<void, GitClientFailure>>());
      },
    );
  });

  group('remoteUrl', () {
    setUp(aloneWithOneCommit);

    test('is the address after insteadOf, as git would use it', () async {
      world.writeGlobalConfig(
        '[url "${world.base}/real/"]\n\tinsteadOf = short:\n',
      );
      world.git(<String>[
        'remote',
        'add',
        'origin',
        'short:docs.git',
      ], inside: work);

      expect(valueOf(await client.remoteUrl()), '${world.base}/real/docs.git');
    });

    test('is the fetch address when a push address is set apart', () async {
      world.git(<String>[
        'remote',
        'add',
        'origin',
        'https://example.com/docs.git',
      ], inside: work);
      world.git(<String>[
        'config',
        'remote.origin.pushurl',
        '${world.base}/push.git',
      ], inside: work);

      expect(valueOf(await client.remoteUrl()), 'https://example.com/docs.git');
    });

    test('a remote not called origin is not the one asked about', () async {
      world.git(<String>[
        'remote',
        'add',
        'upstream',
        'https://example.com/docs.git',
      ], inside: work);

      expect(valueOf(await client.remoteUrl()), isEmpty);
    });
  });

  group('defaultBranch', () {
    late String remote;

    setUp(() {
      aloneWithOneCommit();
      remote = '${world.base}/remote.git';
      world.init(remote, bare: true);
      world.git(<String>['remote', 'add', 'origin', remote], inside: work);
    });

    /// Publishes [branch] from the work copy, then forgets `origin/HEAD`.
    void remoteHas(String branch) {
      world.git(<String>[
        'push',
        '--quiet',
        'origin',
        'main:refs/heads/$branch',
      ], inside: work);
      world.git(<String>['fetch', '--quiet'], inside: work);
    }

    test('guesses master when only master exists', () async {
      remoteHas('master');

      expect(valueOf(await client.defaultBranch()), 'master');
    });

    test('prefers main when both exist', () async {
      remoteHas('master');
      remoteHas('main');

      expect(valueOf(await client.defaultBranch()), 'main');
    });

    test('says nothing when the remote has neither', () async {
      remoteHas('trunk');

      expect(valueOf(await client.defaultBranch()), isEmpty);
    });

    test('reads origin/HEAD over any guess, slash and all', () async {
      remoteHas('main');
      remoteHas('release/1.0');
      world.git(<String>[
        'remote',
        'set-head',
        'origin',
        'release/1.0',
      ], inside: work);

      expect(valueOf(await client.defaultBranch()), 'release/1.0');
    });
  });

  group('mergeBase and resolves', () {
    setUp(() {
      aloneWithOneCommit();
      client = world.clientIn(work);
    });

    test('a tag is a revision like any other', () async {
      world.git(<String>[
        'tag',
        '--annotate',
        '--message',
        'one',
        'v1',
      ], inside: work);
      world.write(work, 'b.md', '# B\n');
      world.commitAll(work, 'Add B');
      final String first = world.say(<String>[
        'rev-parse',
        'v1^{commit}',
      ], inside: work);

      expect(valueOf(await client.resolves('v1')), isTrue);
      expect(valueOf(await client.mergeBase('v1')), first);
    });

    test('a blob is not a revision, and is a failure to merge-base', () async {
      final String blob = world.say(<String>[
        'rev-parse',
        'HEAD:a.md',
      ], inside: work);

      expect(valueOf(await client.resolves(blob)), isFalse);
      expect(
        failureOf(await client.mergeBase(blob)),
        isA<GitClientCommandFailed>(),
      );
    });

    test('an unborn HEAD resolves nothing and has no base', () async {
      final String fresh = '${world.base}/fresh';
      world.init(fresh);
      final DartIoGitClientImpl onFresh = world.clientIn(fresh);

      expect(valueOf(await onFresh.resolves('HEAD')), isFalse);
      expect(valueOf(await onFresh.resolves('main')), isFalse);
      expect(
        failureOf(await onFresh.mergeBase('main')),
        isA<GitClientFailure>(),
      );
    });

    test('a name that is nothing is not a revision', () async {
      expect(valueOf(await client.resolves('nope')), isFalse);
      expect(
        failureOf(await client.mergeBase('nope')),
        isA<GitClientCommandFailed>(),
      );
    });
  });

  group('clone, when it works', () {
    late String remote;

    setUp(() {
      remote = world.remoteWithClone(work);
    });

    test('fills an existing empty folder', () async {
      final String target = '${world.base}/empty';
      Directory(target).createSync();

      expect(
        await world.clientIn(target).clone(remote),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(File('$target/a.md').readAsStringSync(), '# A\n');
    });

    test('goes into a folder whose name has a space', () async {
      final String target = '${world.base}/my docs';

      expect(
        await world.clientIn(target).clone(remote),
        isA<Success<void, GitClientFailure>>(),
      );

      final DartIoGitClientImpl cloned = world.clientIn(target);
      expect(valueOf(await cloned.repositoryRoot()), target);
      expect(valueOf(await cloned.currentBranch()), 'main');
    });

    test(
      'takes a remote with no commits and leaves an unborn branch',
      () async {
        final String empty = '${world.base}/nothing.git';
        world.init(empty, bare: true);
        final String target = '${world.base}/cloned-nothing';
        final KeptCommandLog log = KeptCommandLog();

        expect(
          await world.clientIn(target, commandLog: log).clone(empty),
          isA<Success<void, GitClientFailure>>(),
        );

        final DartIoGitClientImpl cloned = world.clientIn(target);
        expect(valueOf(await cloned.head()), isEmpty);
        expect(valueOf(await cloned.commitCount()), 0);
        expect(log.records.single.exitCode, 0);
      },
    );

    test('a destination that is a file is a taken destination', () async {
      final String target = '${world.base}/a-file';
      File(target).writeAsStringSync('not a folder');

      final AppFailure failure = failureOf(
        await world.clientIn(target).clone(remote),
      );

      expect(failure, isA<GitClientDestinationTaken>());
      expect(File(target).readAsStringSync(), 'not a folder');
    });
  });

  group('two clients on one repository', () {
    test(
      'a burst of stage and commit from two of them never meets the lock',
      () async {
        world.remoteWithClone(work);
        final List<DartIoGitClientImpl> clients = <DartIoGitClientImpl>[
          world.clientIn(work),
          world.clientIn(work),
        ];
        final List<Future<Result<void, GitClientFailure>>> operations =
            <Future<Result<void, GitClientFailure>>>[];
        for (int i = 0; i < 20; i++) {
          world.write(work, 'file_$i.md', '# $i\n');
          final DartIoGitClientImpl client = clients[i % 2];
          operations
            ..add(client.stage(<String>['file_$i.md']))
            ..add(client.commit('Add $i'));
        }

        final List<Result<void, GitClientFailure>> results = await Future.wait(
          operations,
        );

        // `docs/technical/runtime/git.md` promises one serialized queue per
        // space; two instances over one repository are what the composition
        // root builds when each use case asks for its own client.
        expect(results.whereType<Failure<void, GitClientFailure>>(), isEmpty);
      },
    );
  });
}
