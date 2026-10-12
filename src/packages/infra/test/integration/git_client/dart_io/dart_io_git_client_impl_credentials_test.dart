/// [DartIoGitClientImpl] against a remote that wants credentials it never
/// gets, and one that refuses a push in its hook — each from the real tool.
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
  late RefusingHttpServer server;
  late String repo;

  AppFailure failureOf(Result<Object?, GitClientFailure> result) {
    expect(
      result,
      isA<Failure<Object?, GitClientFailure>>(),
      reason: '$result',
    );
    return (result as Failure<Object?, GitClientFailure>).failure;
  }

  setUp(() async {
    world = GitRemoteWorld();
    server = await RefusingHttpServer.start();
    repo = '${world.base}/repo';
    world.init(repo);
    world.write(repo, 'a.md', '# A\n');
    world.commitAll(repo, 'Add A');
  });

  tearDown(() async {
    await server.close();
    world.dispose();
  });

  group('a remote that answers 401', () {
    setUp(() {
      world.git(<String>['remote', 'add', 'origin', server.url], inside: repo);
      world.git(<String>[
        'config',
        'branch.main.remote',
        'origin',
      ], inside: repo);
      world.git(<String>[
        'config',
        'branch.main.merge',
        'refs/heads/main',
      ], inside: repo);
    });

    test('fetch is GitClientAuthenticationFailed, and promptly', () async {
      final Stopwatch clock = Stopwatch()..start();
      final AppFailure failure = failureOf(await world.clientIn(repo).fetch());

      expect(failure, isA<GitClientAuthenticationFailed>());
      // The prompt is switched off, so nobody waits for the 30 s limit.
      expect(clock.elapsed, lessThan(const Duration(seconds: 15)));
      expect(server.requests, isNotEmpty, reason: 'the refusal came from it');
    });

    test('pull is GitClientAuthenticationFailed', () async {
      expect(
        failureOf(await world.clientIn(repo).pull()),
        isA<GitClientAuthenticationFailed>(),
      );
    });

    test('push is GitClientAuthenticationFailed', () async {
      expect(
        failureOf(await world.clientIn(repo).push()),
        isA<GitClientAuthenticationFailed>(),
      );
    });

    test('publish is GitClientAuthenticationFailed', () async {
      expect(
        failureOf(await world.clientIn(repo).publish('main')),
        isA<GitClientAuthenticationFailed>(),
      );
    });

    test(
      'clone is GitClientAuthenticationFailed and leaves no folder',
      () async {
        final String target = '${world.base}/cloned';

        final AppFailure failure = failureOf(
          await world.clientIn(target).clone(server.url),
        );

        expect(failure, isA<GitClientAuthenticationFailed>());
        expect(Directory(target).existsSync(), isFalse);
      },
    );

    test('the words are git\'s, kept for the details', () async {
      final AppFailure failure = failureOf(await world.clientIn(repo).fetch());

      expect(
        (failure as GitClientAuthenticationFailed).stderr,
        contains('terminal prompts disabled'),
      );
    });

    test('an askpass program in the person\'s config is never run', () async {
      // `GIT_ASKPASS` is set empty by the client; a program named in the
      // config would otherwise be asked, and could answer for the person.
      final String marker = '${world.base}/asked';
      final File askpass = File('${world.base}/askpass')
        ..writeAsStringSync('#!/bin/sh\ntouch "$marker"\necho secret\n');
      Process.runSync('chmod', <String>['+x', askpass.path]);
      world.writeGlobalConfig('[core]\n\taskPass = ${askpass.path}\n');

      final AppFailure failure = failureOf(await world.clientIn(repo).fetch());

      expect(failure, isA<GitClientAuthenticationFailed>());
      expect(File(marker).existsSync(), isFalse);
    });

    test('is written down with git\'s own words, not a guess', () async {
      final KeptCommandLog log = KeptCommandLog();

      await world.clientIn(repo, commandLog: log).fetch();

      expect(log.records.single.exitCode, isNot(0));
      expect(log.records.single.output, contains('terminal prompts disabled'));
    });
  });

  group('a remote that refuses in its hook', () {
    late String remote;
    late String clone;

    setUp(() {
      clone = '${world.base}/work';
      remote = world.remoteWithClone(clone);
      world.write(clone, 'b.md', '# B\n');
      world.commitAll(clone, 'Add B');
    });

    test(
      'a hook that says the branch is protected is BranchProtected',
      () async {
        world.hook(
          remote,
          'pre-receive',
          'echo "GH006: Protected branch update failed" >&2\nexit 1',
        );

        final AppFailure failure = failureOf(
          await world.clientIn(clone).push(),
        );

        expect(failure, isA<GitClientBranchProtected>());
        expect(
          (failure as GitClientBranchProtected).stderr,
          contains('remote rejected'),
        );
      },
    );

    test('a hook that gives no such word is not "pull first"', () async {
      // `[remote rejected]` is not `[rejected]`: the remote did not move, so
      // pulling would not be the way out, and the fallback keeps the words.
      world.hook(remote, 'pre-receive', 'echo "no pushes today" >&2\nexit 1');

      final AppFailure failure = failureOf(await world.clientIn(clone).push());

      expect(failure, isA<GitClientCommandFailed>());
      expect(failure, isNot(isA<GitClientPushRejected>()));
      expect(
        (failure as GitClientCommandFailed).stderr,
        contains('no pushes today'),
      );
    });

    test('the refused commit stays local and the remote is unmoved', () async {
      world.hook(remote, 'pre-receive', 'exit 1');
      final String before = world.say(<String>[
        'rev-parse',
        'main',
      ], inside: remote);

      await world.clientIn(clone).push();

      expect(world.say(<String>['rev-parse', 'main'], inside: remote), before);
      expect(
        world.say(<String>['log', '--format=%s', '-1'], inside: clone),
        'Add B',
      );
    });

    test('publish of a new branch is refused the same way', () async {
      world.hook(
        remote,
        'pre-receive',
        'echo "protected branch hook declined" >&2\nexit 1',
      );
      world.git(<String>[
        'switch',
        '--quiet',
        '--create',
        'draft',
      ], inside: clone);

      expect(
        failureOf(await world.clientIn(clone).publish('draft')),
        isA<GitClientBranchProtected>(),
      );
    });
  });
}
