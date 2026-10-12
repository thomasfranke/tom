/// [DartIoGitClientImpl] committing, at the edges: a machine with no
/// identity, a hook that refuses, a merge to conclude, a message git could
/// misread — and a write that was killed.
///
/// A sibling of `dart_io_git_client_impl_test.dart` (decision T3). Git runs
/// under [GitWorld]'s empty configuration; a test writes what it needs.
library;

// Arranging a repository is a run of statements on one world.
// ignore_for_file: cascade_invocations

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

import '../../../support/git_world.dart';

void main() {
  late GitWorld world;
  late DartIoGitClientImpl client;

  setUp(() {
    world = GitWorld()..seed();
    client = world.client();
  });

  tearDown(() => world.dispose());

  String head() =>
      world.run(<String>['rev-parse', '--verify', '--quiet', 'HEAD']).stdout
          as String;

  String message() =>
      world.git(<String>['log', '-1', '--format=%B']).stdout as String;

  void stageNew(String path, [String content = 'new\n']) {
    world.write(path, content);
    world.git(<String>['add', '--', path]);
  }

  const String posixOnly =
      'the hooks are shell scripts, and /bin/sh is not there';
  final Object skipOnWindows = Platform.isWindows ? posixOnly : false;

  group('a person with no identity', () {
    setUp(() {
      // `useConfigOnly` is what makes the answer the same on every machine:
      // without it git guesses a name from the user and the host.
      world.init('${world.base}/anon', identity: false);
      world.configure('[user]\n\tuseConfigOnly = true\n');
      world.write('a.md', '# A\n', inside: '${world.base}/anon');
      world.git(<String>['add', 'a.md'], inside: '${world.base}/anon');
      client = world.client(inside: '${world.base}/anon');
    });

    test(
      'is refused by git in its own words, and nothing is committed',
      () async {
        final GitClientFailure failure = failureOf(
          await client.commit('First'),
        );

        expect(failure, isA<GitClientCommandFailed>());
        expect(
          (failure as GitClientCommandFailed).stderr,
          matches(RegExp('identity unknown|auto-detection is disabled')),
        );
        expect(
          world.run(<String>[
            'rev-parse',
            '--verify',
            '--quiet',
            'HEAD',
          ], inside: '${world.base}/anon').exitCode,
          isNot(0),
        );
        expect(
          world.git(<String>[
            'status',
            '--short',
          ], inside: '${world.base}/anon').stdout,
          'A  a.md\n',
          reason: 'the index is as it was',
        );
      },
    );

    test('and reads both halves of the identity as empty', () async {
      expect(valueOf(await client.identity()), GitClient.unitSeparator);
    });

    test('commits once the person\'s own config names them', () async {
      world.configure('[user]\n\tname = Ana\n\temail = ana@example.com\n');

      expect(
        await client.commit('First'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(
        world.git(<String>[
          'log',
          '-1',
          '--format=%an <%ae>',
        ], inside: '${world.base}/anon').stdout,
        'Ana <ana@example.com>\n',
      );
    });
  });

  group('a hook that refuses', () {
    test(
      'pre-commit keeps the commit from happening, and says why',
      () async {
        world.hook('pre-commit', 'echo "front matter is missing" >&2\nexit 1');
        stageNew('b.md');
        final String before = head();

        final GitClientFailure failure = failureOf(
          await client.commit('Add B'),
        );

        expect(failure, isA<GitClientCommandFailed>());
        expect(
          (failure as GitClientCommandFailed).stderr,
          contains('front matter is missing'),
        );
        expect(head(), before);
        expect(world.git(<String>['status', '--short']).stdout, 'A  b.md\n');
      },
      skip: skipOnWindows,
    );

    test('commit-msg can refuse the message', () async {
      world.hook('commit-msg', 'echo "no ticket in the subject" >&2\nexit 1');
      stageNew('b.md');
      final String before = head();

      final GitClientFailure failure = failureOf(await client.commit('Add B'));

      expect(
        (failure as GitClientCommandFailed).stderr,
        contains('no ticket in the subject'),
      );
      expect(head(), before);
    }, skip: skipOnWindows);

    test('a hook that approves lets it through', () async {
      world.hook('pre-commit', 'exit 0');
      stageNew('b.md');

      expect(
        await client.commit('Add B'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(message().trim(), 'Add B');
    }, skip: skipOnWindows);

    test(
      'one the person\'s own core.hooksPath names refuses too',
      () async {
        final Directory hooks = Directory('${world.base}/their-hooks')
          ..createSync();
        File(
          '${hooks.path}/pre-commit',
        ).writeAsStringSync('#!/bin/sh\necho "house rules" >&2\nexit 1\n');
        Process.runSync('chmod', <String>['755', '${hooks.path}/pre-commit']);
        world.configure('[core]\n\thooksPath = ${hooks.path}\n');
        stageNew('b.md');

        final GitClientFailure failure = failureOf(
          await client.commit('Add B'),
        );

        expect(
          (failure as GitClientCommandFailed).stderr,
          contains('house rules'),
        );
      },
      skip: skipOnWindows,
    );
  });

  group('signing the person asked for', () {
    test(
      'commit.gpgsign with a signer that fails commits nothing',
      () async {
        world.configure(
          '[commit]\n\tgpgsign = true\n[gpg]\n\tprogram = /usr/bin/false\n',
        );
        stageNew('b.md');
        final String before = head();

        expect(
          failureOf(await client.commit('Add B')),
          isA<GitClientCommandFailed>(),
        );

        expect(head(), before);
        expect(world.git(<String>['status', '--short']).stdout, 'A  b.md\n');
      },
      skip: Platform.isWindows || !File('/usr/bin/false').existsSync()
          ? 'no /usr/bin/false'
          : false,
    );
  });

  group('a merge', () {
    test(
      'with unmerged paths cannot be committed, and stays a merge',
      () async {
        world.conflict();
        final String before = head();

        final GitClientFailure failure = failureOf(
          await client.commit('Merge'),
        );

        expect(failure, isA<GitClientCommandFailed>());
        expect(
          (failure as GitClientCommandFailed).stderr,
          contains('unmerged'),
        );
        expect(head(), before);
        expect(valueOf(await client.mergeInProgress()), isTrue);
      },
    );

    test(
      'is concluded by the commit that follows staging the resolution',
      () async {
        world.conflict();
        world.write('a.md', '# A, resolved\n');
        await client.stage(<String>['a.md']);
        final String draft = valueOf(await client.mergeMessage());

        expect(
          await client.commit(draft.trim()),
          isA<Success<void, GitClientFailure>>(),
        );

        expect(valueOf(await client.mergeInProgress()), isFalse);
        final String parents =
            world.git(<String>[
                  'rev-list',
                  '--parents',
                  '-n',
                  '1',
                  'HEAD',
                ]).stdout
                as String;
        expect(
          parents.trim().split(' '),
          hasLength(3),
          reason: 'itself and two parents',
        );
        expect(message(), contains("Merge branch 'topic'"));
        expect(
          world.git(<String>['show', 'HEAD:a.md']).stdout,
          '# A, resolved\n',
        );
      },
    );
  });

  group('the message', () {
    test('an empty one is refused, and nothing is committed', () async {
      stageNew('b.md');
      final String before = head();

      final GitClientFailure failure = failureOf(await client.commit(''));

      expect(failure, isA<GitClientCommandFailed>());
      expect(
        (failure as GitClientCommandFailed).stderr,
        contains('empty commit message'),
      );
      expect(head(), before);
    });

    test('one of only blanks is refused too', () async {
      stageNew('b.md');

      expect(
        failureOf(await client.commit('  \n \n')),
        isA<GitClientCommandFailed>(),
      );
    });

    test('a leading dash is the message, not an option', () async {
      stageNew('b.md');

      expect(
        await client.commit('--amend is not a flag'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(message().trim(), '--amend is not a flag');
      expect(world.git(<String>['rev-list', '--count', 'HEAD']).stdout, '2\n');
    });

    test('a markdown heading is not stripped as a comment', () async {
      stageNew('b.md');

      await client.commit('# Title\n\nBody with `code` and "quotes"');

      expect(message().trim(), '# Title\n\nBody with `code` and "quotes"');
    });

    test('keeps letters outside ASCII and several lines', () async {
      stageNew('b.md');

      await client.commit('Revisão da seção 日本語\n\nSegunda linha\n\nTerceira');

      expect(
        message().trim(),
        'Revisão da seção 日本語\n\nSegunda linha\n\nTerceira',
      );
    });
  });

  group('where HEAD is', () {
    test(
      'a detached one takes the commit — the refusal is the use case\'s',
      () async {
        world.git(<String>['switch', '--quiet', '--detach']);
        stageNew('b.md');

        expect(
          await client.commit('Add B'),
          isA<Success<void, GitClientFailure>>(),
        );

        expect(valueOf(await client.currentBranch()), isEmpty);
        expect(message().trim(), 'Add B');
      },
    );

    test('an unborn branch gets its first commit, with no parent', () async {
      final String fresh = '${world.base}/fresh';
      world.init(fresh);
      world.write('a.md', '# A\n', inside: fresh);
      world.git(<String>['add', 'a.md'], inside: fresh);
      final DartIoGitClientImpl first = world.client(inside: fresh);

      expect(
        await first.commit('First'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(valueOf(await first.commitCount()), 1);
      expect(
        world
            .git(<String>[
              'rev-list',
              '--parents',
              '-n',
              '1',
              'HEAD',
            ], inside: fresh)
            .stdout
            .toString()
            .trim()
            .split(' '),
        hasLength(1),
      );
    });

    test('with only untracked files, nothing is committed', () async {
      world.write('loose.md', '# Loose\n');

      expect(
        failureOf(await client.commit('Nothing')),
        isA<GitClientCommandFailed>(),
      );
    });
  });

  // `index.lock` is what a write holds while it runs; a client that kills the
  // write on its timeout must not leave the repository unable to write again.
  group('a write that was killed', () {
    late DartIoGitClientImpl impatient;

    setUp(() {
      // The hook outlives the kill: it replaces itself so no child is left
      // holding the pipes for long.
      world.hook('pre-commit', 'exec sleep 4');
      stageNew('b.md');
      impatient = world.client(timeout: const Duration(milliseconds: 600));
    });

    test(
      'fails with GitClientTimedOut, and the index is still the staged one',
      () async {
        expect(
          failureOf(await impatient.commit('Add B')),
          isA<GitClientTimedOut>(),
        );

        expect(world.git(<String>['status', '--short']).stdout, 'A  b.md\n');
      },
      skip: skipOnWindows,
    );

    test('does not leave a lock that stops the next write', () async {
      await impatient.commit('Add B');
      File('${world.repo}/.git/hooks/pre-commit').deleteSync();

      final File lock = File('${world.repo}/.git/index.lock');
      expect(
        await client.commit('Add B again'),
        isA<Success<void, GitClientFailure>>(),
        reason: 'a leftover lock: ${lock.existsSync()}',
      );

      expect(message().trim(), 'Add B again');
    }, skip: skipOnWindows);

    test('does not stop the next read', () async {
      await impatient.commit('Add B');

      expect(await client.status(), isA<Success<String, GitClientFailure>>());
    }, skip: skipOnWindows);
  });
}
