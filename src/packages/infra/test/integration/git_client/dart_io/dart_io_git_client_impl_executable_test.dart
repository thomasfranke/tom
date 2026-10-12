/// [DartIoGitClientImpl] when there is no git to start, and what it starts
/// git with when there is.
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
  late String repo;

  setUp(() {
    world = GitRemoteWorld();
    repo = '${world.base}/repo';
    world.init(repo);
    world.write(repo, 'a.md', '# A\n');
    world.commitAll(repo, 'Add A');
  });

  tearDown(() {
    world.dispose();
  });

  /// Every method of the contract, asked of [client] in turn.
  Map<String, Future<Result<Object?, GitClientFailure>> Function()> everyCall(
    DartIoGitClientImpl client,
  ) => <String, Future<Result<Object?, GitClientFailure>> Function()>{
    'version': client.version,
    'repositoryRoot': client.repositoryRoot,
    'status': client.status,
    'log': client.log,
    'branches': client.branches,
    'branchStandings': client.branchStandings,
    'commitCount': client.commitCount,
    'identity': client.identity,
    'githubAccount': client.githubAccount,
    'recordGithubAccount': () => client.recordGithubAccount('ana'),
    'branchBase': () => client.branchBase('main'),
    'recordBranchBase': () => client.recordBranchBase('main', 'main'),
    'diffNumstat': () => client.diffNumstat('main'),
    'diffNameStatus': () => client.diffNameStatus('main'),
    'mergeBase': () => client.mergeBase('main'),
    'resolves': () => client.resolves('main'),
    'remoteUrl': client.remoteUrl,
    'defaultBranch': client.defaultBranch,
    'currentBranch': client.currentBranch,
    'show': () => client.show('HEAD', 'a.md'),
    'showBytes': () => client.showBytes('HEAD', 'a.md'),
    'showStagedBytes': () => client.showStagedBytes('a.md'),
    'stage': () => client.stage(<String>['a.md']),
    'unstage': () => client.unstage(<String>['a.md']),
    'discardAll': client.discardAll,
    'discardUnstaged': () => client.discardUnstaged(<String>['a.md']),
    'discardSinceCommit': () => client.discardSinceCommit(<String>['a.md']),
    'deleteUncommitted': () => client.deleteUncommitted(<String>['a.md']),
    'commit': () => client.commit('Nothing'),
    'createBranch': () => client.createBranch('draft'),
    'switchBranch': () => client.switchBranch('main'),
    'fetch': client.fetch,
    'pull': client.pull,
    'head': client.head,
    'upstreamCommitsSince': () => client.upstreamCommitsSince(''),
    'push': client.push,
    'publish': () => client.publish('main'),
    'gitDirectory': client.gitDirectory,
    'mergeInProgress': client.mergeInProgress,
    'mergeMessage': client.mergeMessage,
    'abortMerge': client.abortMerge,
  };

  group('no git on the machine', () {
    test(
      'every method of the contract is GitClientExecutableNotFound',
      () async {
        final DartIoGitClientImpl client = world.clientIn(
          repo,
          executable: '${world.base}/no-such-git',
        );

        // Collected rather than asserted one by one, so a method that
        // swallows the failure is named together with every other one.
        final List<String> elsewhere = <String>[];
        for (final MapEntry<
              String,
              Future<Result<Object?, GitClientFailure>> Function()
            >
            call
            in everyCall(client).entries) {
          final Result<Object?, GitClientFailure> result = await call.value();
          if (!_saysNoGit(result)) {
            elsewhere.add('${call.key}: $result');
          }
        }

        expect(elsewhere, isEmpty);
      },
    );

    test(
      'every method but defaultBranch is GitClientExecutableNotFound',
      () async {
        final DartIoGitClientImpl client = world.clientIn(
          repo,
          executable: '${world.base}/no-such-git',
        );

        final List<String> elsewhere = <String>[];
        for (final MapEntry<
              String,
              Future<Result<Object?, GitClientFailure>> Function()
            >
            call
            in everyCall(client).entries) {
          if (call.key == 'defaultBranch') {
            continue;
          }
          final Result<Object?, GitClientFailure> result = await call.value();
          if (!_saysNoGit(result)) {
            elsewhere.add('${call.key}: $result');
          }
        }

        expect(elsewhere, isEmpty);
      },
    );

    test('clone, which runs outside any folder, says it too', () async {
      final String target = '${world.base}/cloned';

      final Result<void, GitClientFailure> result = await world
          .clientIn(target, executable: '${world.base}/no-such-git')
          .clone('${world.base}/anywhere.git');

      expect(
        (result as Failure<void, GitClientFailure>).failure,
        isA<GitClientExecutableNotFound>(),
      );
      expect(Directory(target).existsSync(), isFalse);
    });

    test('a file that is not executable is the same answer', () async {
      File('${world.base}/not-git').writeAsStringSync('#!/bin/sh\n');

      final Result<String, GitClientFailure> result = await world
          .clientIn(repo, executable: '${world.base}/not-git')
          .version();

      expect(
        (result as Failure<String, GitClientFailure>).failure,
        isA<GitClientExecutableNotFound>(),
      );
    });

    test('a folder that is gone is not "git is not installed"', () async {
      final Result<String, GitClientFailure> result = await world
          .clientIn(
            '${world.base}/gone',
            executable: '${world.base}/no-such-git',
          )
          .status();

      expect(
        (result as Failure<String, GitClientFailure>).failure,
        isA<GitClientNotARepository>(),
      );
    });

    test('each refused start is written down as one that never ran', () async {
      final KeptCommandLog log = KeptCommandLog();
      final DartIoGitClientImpl client = world.clientIn(
        repo,
        executable: '${world.base}/no-such-git',
        commandLog: log,
      );

      await client.status();
      await client.fetch();

      expect(log.records, hasLength(2));
      expect(
        log.records.map((CommandRecord it) => it.ran),
        everyElement(isFalse),
      );
      expect(log.records.first.arguments, contains('status'));
      expect(log.records.first.executable, 'git');
    });

    test('a second call after the failure still answers', () async {
      // The queue carries no failure forward, so a missing git is not a
      // wedged client.
      final DartIoGitClientImpl client = world.clientIn(
        repo,
        executable: '${world.base}/no-such-git',
      );

      await client.status();

      expect(await client.status(), isA<Failure<String, GitClientFailure>>());
    });
  });

  group('what git is started with', () {
    late String seen;
    late DartIoGitClientImpl client;

    setUp(() {
      seen = '${world.base}/environment';
      // Writes the environment it was given, then runs the real git.
      File('${world.base}/spy').writeAsStringSync(
        '#!/bin/sh\nenv > "$seen"\nexec "${world.executable}" "\$@"\n',
      );
      Process.runSync('chmod', <String>['+x', '${world.base}/spy']);
      client = world.clientIn(repo, executable: '${world.base}/spy');
    });

    Map<String, String> environment() => <String, String>{
      for (final String line in File(seen).readAsLinesSync())
        if (line.contains('='))
          line.substring(0, line.indexOf('=')): line.substring(
            line.indexOf('=') + 1,
          ),
    };

    test('no prompt of any kind can block', () async {
      await client.status();

      final Map<String, String> given = environment();
      expect(given['GIT_TERMINAL_PROMPT'], '0');
      expect(given['GIT_ASKPASS'], '');
      expect(given['SSH_ASKPASS_REQUIRE'], 'never');
    });

    test('words are git\'s English and a read takes no lock', () async {
      await client.status();

      final Map<String, String> given = environment();
      expect(given['LC_ALL'], 'C');
      expect(given['GIT_OPTIONAL_LOCKS'], '0');
    });

    test('the person\'s own PATH and home are kept', () async {
      await client.status();

      final Map<String, String> given = environment();
      expect(given['PATH'], Platform.environment['PATH']);
      expect(given['HOME'], isNotNull);
    });

    test('it runs in the folder it was given, below the root too', () async {
      Directory('$repo/docs').createSync();
      File('${world.base}/pwd-spy').writeAsStringSync(
        '#!/bin/sh\npwd -P > "${world.base}/pwd"\nexec "${world.executable}" "\$@"\n',
      );
      Process.runSync('chmod', <String>['+x', '${world.base}/pwd-spy']);

      await world
          .clientIn('$repo/docs', executable: '${world.base}/pwd-spy')
          .status();

      expect(File('${world.base}/pwd').readAsStringSync().trim(), '$repo/docs');
    });
  });
}

/// Whether [result] is the failure that says git could not be started.
bool _saysNoGit(Result<Object?, GitClientFailure> result) =>
    result is Failure<Object?, GitClientFailure> &&
    result.failure is GitClientExecutableNotFound;
