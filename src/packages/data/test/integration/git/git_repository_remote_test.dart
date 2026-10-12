/// [GitRepositoryImpl] against a remote: what fetch, pull, push and publish
/// do to the numbers `status` reads, and every refusal a remote gives,
/// provoked from a real bare repository, a hook or a loopback server.
@TestOn('!windows')
library;

// Arranging a repository is a run of statements on one world.
// ignore_for_file: cascade_invocations

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

import '../../support/git_world.dart';

void main() {
  late GitWorld world;
  late String remote;
  late String work;
  late String colleague;

  setUp(() {
    world = GitWorld();
    final ({String remote, String work}) made = world.remoteWithClone(
      file: 'docs/a.md',
      content: '# A\n',
    );
    remote = made.remote;
    work = made.work;
    colleague = world.colleague(remote);
  });

  tearDown(() => world.dispose());

  /// The colleague publishes [content] at [path].
  void colleaguePushes(String path, String content) {
    world.commitFile(colleague, path, content, message: 'Theirs: $path');
    world.git(<String>['push', '--quiet', 'origin', 'main'], inside: colleague);
  }

  for (final String below in const <String>['', 'docs']) {
    group('against a remote, the client in ${_where(below)}', () {
      late GitRepositoryImpl repository;

      setUp(() {
        repository = world.repository(below.isEmpty ? work : '$work/$below');
      });

      test('fetch shows what is behind, and leaves the tree alone', () async {
        colleaguePushes('docs/b.md', '# B\n');
        expect(valueOf(await repository.status()).behind, 0);

        valueOf(await repository.fetch());

        final GitStatusValueObject status = valueOf(await repository.status());
        expect(status.behind, 1);
        expect(status.ahead, 0);
        expect(status.upstream, branch('origin/main'));
        expect(File('$work/docs/b.md').existsSync(), isFalse);
      });

      test('a commit of the person\'s own shows as ahead', () async {
        world.commitFile(work, 'docs/c.md', '# C\n');
        colleaguePushes('docs/b.md', '# B\n');
        valueOf(await repository.fetch());

        final GitStatusValueObject status = valueOf(await repository.status());

        expect(status.ahead, 1);
        expect(status.behind, 1);
      });

      test('pull fast-forwards, and the arrival is counted from the head '
          'before it', () async {
        colleaguePushes('docs/b.md', '# B\n');
        colleaguePushes('docs/c.md', '# C\n');
        final CommitShaValueObject? before = valueOf(await repository.head());
        expect(before, isNotNull);

        valueOf(await repository.pull());

        expect(world.read(work, 'docs/c.md'), '# C\n');
        expect(valueOf(await repository.head()), isNot(before));
        expect(valueOf(await repository.upstreamCommitsSince(before)), 2);
        expect(valueOf(await repository.status()).behind, 0);
      });

      test('pull merges a diverged branch on an unconfigured machine, and '
          'the merge commit is not an arrival', () async {
        world.commitFile(work, 'docs/mine.md', '# Mine\n', message: 'Mine');
        colleaguePushes('docs/b.md', '# B\n');
        final CommitShaValueObject? before = valueOf(await repository.head());

        valueOf(await repository.pull());

        expect(world.read(work, 'docs/b.md'), '# B\n');
        expect(world.read(work, 'docs/mine.md'), '# Mine\n');
        expect(
          world
              .git(<String>[
                'rev-list',
                '--parents',
                '-n',
                '1',
                'HEAD',
              ], inside: work)
              .split(' '),
          hasLength(3),
        );
        expect(valueOf(await repository.upstreamCommitsSince(before)), 1);
        expect(valueOf(await repository.status()).behind, 0);
      });

      test('nothing is waiting when the head is the upstream\'s', () async {
        final CommitShaValueObject? head = valueOf(await repository.head());

        expect(valueOf(await repository.upstreamCommitsSince(head)), 0);
      });

      test('push puts the commit on the remote', () async {
        world.commitFile(work, 'docs/mine.md', '# Mine\n', message: 'Mine');

        valueOf(await repository.push());

        expect(
          world.git(<String>[
            'log',
            '--format=%s',
            '-1',
            'main',
          ], inside: remote),
          'Mine',
        );
        final GitStatusValueObject status = valueOf(await repository.status());
        expect(status.ahead, 0);
        expect(status.behind, 0);
      });

      test('push is rejected when the remote moved', () async {
        colleaguePushes('docs/b.md', '# B\n');
        world.commitFile(work, 'docs/mine.md', '# Mine\n', message: 'Mine');

        expect(failureOf(await repository.push()), isA<GitPushRejected>());
        expect(
          world.git(<String>[
            'log',
            '--format=%s',
            '-1',
            'main',
          ], inside: remote),
          'Theirs: docs/b.md',
        );
      });

      test('publish sends a new branch and tracks it', () async {
        world.git(<String>['switch', '--quiet', '-c', 'feat/x'], inside: work);
        world.commitFile(work, 'docs/x.md', '# X\n', message: 'X');
        expect(valueOf(await repository.status()).upstream, isNull);

        valueOf(await repository.publish(branch('feat/x')));

        expect(
          world.git(<String>[
            'log',
            '--format=%s',
            '-1',
            'feat/x',
          ], inside: remote),
          'X',
        );
        final GitStatusValueObject status = valueOf(await repository.status());
        expect(status.upstream, branch('origin/feat/x'));
        // With no earlier head, everything the branch has is "arrived".
        expect(valueOf(await repository.upstreamCommitsSince(null)), 2);
      });

      test('publish of a name the remote has, diverged, is rejected', () async {
        world.git(<String>[
          'switch',
          '--quiet',
          '-c',
          'feat/x',
        ], inside: colleague);
        world.commitFile(colleague, 'docs/x.md', '# X, theirs\n');
        world.git(<String>[
          'push',
          '--quiet',
          'origin',
          'feat/x',
        ], inside: colleague);
        world.git(<String>['switch', '--quiet', '-c', 'feat/x'], inside: work);
        world.commitFile(work, 'docs/x.md', '# X, mine\n');

        expect(
          failureOf(await repository.publish(branch('feat/x'))),
          isA<GitPushRejected>(),
        );
      });
    });
  }

  group('a remote that answers no', () {
    late GitRepositoryImpl repository;

    setUp(() => repository = world.repository('$work/docs'));

    test('a hook that declines names the branch as protected', () async {
      File('$remote/hooks/pre-receive').writeAsStringSync(
        '#!/bin/sh\necho "protected branch main" >&2\nexit 1\n',
      );
      Process.runSync('chmod', <String>['+x', '$remote/hooks/pre-receive']);
      world.commitFile(work, 'docs/mine.md', '# Mine\n');

      expect(failureOf(await repository.push()), isA<GitBranchProtected>());
    });

    test('a hook that declines without saying why is a failure of the '
        'push, not a race', () async {
      File(
        '$remote/hooks/pre-receive',
      ).writeAsStringSync('#!/bin/sh\necho "no pushes today" >&2\nexit 1\n');
      Process.runSync('chmod', <String>['+x', '$remote/hooks/pre-receive']);
      world.commitFile(work, 'docs/mine.md', '# Mine\n');

      final GitFailure failure = failureOf(await repository.push());

      expect(failure, isA<GitOperationFailed>());
      expect(failure, isNot(isA<GitPushRejected>()));
    });

    test('a server that wants credentials it never gets is an '
        'authentication failure, promptly', () async {
      final HttpServer server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      addTearDown(() async => server.close(force: true));
      server.listen((HttpRequest request) async {
        request.response
          ..statusCode = HttpStatus.unauthorized
          ..headers.set('WWW-Authenticate', 'Basic realm="docs"');
        await request.response.close();
      });
      world.git(<String>[
        'remote',
        'set-url',
        'origin',
        'http://127.0.0.1:${server.port}/docs.git',
      ], inside: work);

      final Stopwatch clock = Stopwatch()..start();
      final GitFailure fetched = failureOf(await repository.fetch());
      final GitFailure pushed = failureOf(await repository.push());

      expect(fetched, isA<GitAuthenticationFailed>());
      expect(pushed, isA<GitAuthenticationFailed>());
      expect(clock.elapsed, lessThan(const Duration(seconds: 20)));
    });

    test('a host that does not resolve is the network', () async {
      world.git(<String>[
        'remote',
        'set-url',
        'origin',
        'https://tom.invalid/docs.git',
      ], inside: work);

      expect(failureOf(await repository.fetch()), isA<GitNetworkUnavailable>());
    });

    test('a remote that is not a repository is no remote', () async {
      world.git(<String>[
        'remote',
        'set-url',
        'origin',
        '${world.base}/not-there.git',
      ], inside: work);

      expect(failureOf(await repository.fetch()), isA<GitNoRemote>());
    });
  });

  group('a branch with nowhere to go', () {
    late GitRepositoryImpl repository;

    setUp(() => repository = world.repository('$work/docs'));

    test('with no remote at all, fetch has nothing to do', () async {
      world.git(<String>['remote', 'remove', 'origin'], inside: work);

      expect(await repository.fetch(), isA<Success<void, GitFailure>>());
    });

    test('with no remote at all, pull and push say so', () async {
      world.git(<String>['remote', 'remove', 'origin'], inside: work);

      expect(failureOf(await repository.pull()), isA<GitOperationFailed>());
      expect(failureOf(await repository.push()), isA<GitNoRemote>());
      expect(
        failureOf(await repository.publish(branch('main'))),
        isA<GitNoRemote>(),
      );
    });

    test('with a remote and no upstream, pull and push are failures', () async {
      world.git(<String>['switch', '--quiet', '-c', 'feat/x'], inside: work);

      expect(failureOf(await repository.pull()), isA<GitOperationFailed>());
      expect(failureOf(await repository.push()), isA<GitOperationFailed>());
      expect(
        failureOf(await repository.upstreamCommitsSince(null)),
        isA<GitOperationFailed>(),
      );
    });

    test('on a detached HEAD, pull and push fail and move nothing', () async {
      world.git(<String>['switch', '--quiet', '--detach'], inside: work);
      final CommitShaValueObject? head = valueOf(await repository.head());

      expect(failureOf(await repository.pull()), isA<GitOperationFailed>());
      expect(failureOf(await repository.push()), isA<GitOperationFailed>());
      expect(valueOf(await repository.head()), head);
    });

    test('an empty repository has no head and nothing waiting', () async {
      final String empty = world.init('${world.base}/empty');
      final GitRepositoryImpl unborn = world.repository(empty);

      expect(valueOf(await unborn.head()), isNull);
      expect(
        failureOf(await unborn.upstreamCommitsSince(null)),
        isA<GitOperationFailed>(),
      );
    });
  });

  group('under the person\'s own pull settings', () {
    late GitRepositoryImpl repository;

    setUp(() {
      repository = world.repository('$work/docs');
      world.commitFile(work, 'docs/mine.md', '# Mine\n', message: 'Mine');
      colleaguePushes('docs/b.md', '# B\n');
    });

    test('pull.rebase=true does not rewrite what the product merges', () async {
      world.configureMore('[pull]\n\trebase = true\n');

      valueOf(await repository.pull());

      expect(
        world
            .git(<String>[
              'rev-list',
              '--parents',
              '-n',
              '1',
              'HEAD',
            ], inside: work)
            .split(' '),
        hasLength(3),
      );
      expect(world.read(work, 'docs/b.md'), '# B\n');
    });

    // The choice of merging is the product's (the client's `--no-rebase`),
    // so a setting that forbids merging does not stop it.
    test('pull.ff=only does not forbid the merge the product chose', () async {
      world.configureMore('[pull]\n\tff = only\n');

      valueOf(await repository.pull());

      expect(world.read(work, 'docs/b.md'), '# B\n');
      expect(valueOf(await repository.mergeState()).inProgress, isFalse);
    });
  });
}

/// Where the client runs, for a group's name.
String _where(String below) => below.isEmpty ? 'the root' : '$below/';
