/// [DartIoGitClientImpl] against real repositories created by `git init`.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late String base;
  late String repoPath;
  late DartIoGitClientImpl client;

  /// Runs git directly, to arrange what the client is then asked about.
  ProcessResult git(List<String> arguments, {String? inside}) {
    final ProcessResult result = Process.runSync(
      'git',
      arguments,
      workingDirectory: inside ?? repoPath,
      environment: const <String, String>{'LC_ALL': 'C'},
    );
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
    return result;
  }

  /// A repository with a `main` branch and an identity, at [path].
  ///
  /// `symbolic-ref` rather than `init --initial-branch`: the latter needs git
  /// 2.28, and the tests should not be stricter than the client is.
  void initRepository(String path, {bool bare = false}) {
    Directory(path).createSync(recursive: true);
    git(<String>['init', '--quiet', if (bare) '--bare', '.'], inside: path);
    git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main'], inside: path);
    if (bare) {
      return;
    }
    // Deliberately not `pull.rebase`: setting it would hide that the client
    // has to say `--no-rebase` itself.
    for (final List<String> setting in const <List<String>>[
      <String>['user.name', 'Test'],
      <String>['user.email', 'test@example.com'],
      <String>['commit.gpgsign', 'false'],
    ]) {
      git(<String>['config', ...setting], inside: path);
    }
  }

  void write(String relativePath, String content) {
    File('$repoPath/$relativePath')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  /// The value of a successful result, failing the test when it is not one.
  String valueOf(Result<String, GitClientFailure> result) {
    expect(result, isA<Success<String, GitClientFailure>>(), reason: '$result');
    return (result as Success<String, GitClientFailure>).value;
  }

  /// The failure of a failed result, failing the test when it is not one.
  AppFailure failureOf(Result<Object?, GitClientFailure> result) {
    expect(
      result,
      isA<Failure<Object?, GitClientFailure>>(),
      reason: '$result',
    );
    return (result as Failure<Object?, GitClientFailure>).failure;
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_git_client_test_');
    // Resolved and forward-slashed, because git reports the real path in its
    // own spelling: the macOS temporary directory is a symlink, and on
    // Windows `dart:io` answers with backslashes while git answers with `/`.
    base = tempDir.resolveSymbolicLinksSync().replaceAll(r'\', '/');
    repoPath = '$base/repo';
    initRepository(repoPath);
    write('a.md', '# A\n');
    git(<String>['add', 'a.md']);
    git(<String>['commit', '--quiet', '--message', 'Add A']);
    client = DartIoGitClientImpl(workingDirectory: repoPath);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('currentBranch', () {
    test('names the branch, from a folder below the root too', () async {
      git(<String>['switch', '--quiet', '--create', 'feat/notes']);
      Directory('$repoPath/docs').createSync();

      expect(valueOf(await client.currentBranch()), 'feat/notes');
      expect(
        valueOf(
          await DartIoGitClientImpl(
            workingDirectory: '$repoPath/docs',
          ).currentBranch(),
        ),
        'feat/notes',
      );
    });

    test('names a branch with no commits yet', () async {
      final String fresh = '$base/fresh';
      initRepository(fresh);

      expect(
        valueOf(
          await DartIoGitClientImpl(workingDirectory: fresh).currentBranch(),
        ),
        'main',
      );
    });

    test('is empty on a detached HEAD', () async {
      git(<String>['switch', '--quiet', '--detach']);

      expect(valueOf(await client.currentBranch()), isEmpty);
    });

    test('fails with GitClientNotARepository outside one', () async {
      final String outside = '$base/plain';
      Directory(outside).createSync();

      expect(
        failureOf(
          await DartIoGitClientImpl(workingDirectory: outside).currentBranch(),
        ),
        isA<GitClientNotARepository>(),
      );
    });
  });

  group('repositoryRoot', () {
    test('reports the repository itself', () async {
      expect(valueOf(await client.repositoryRoot()), repoPath);
    });

    test('reports the repository from a folder below it', () async {
      Directory('$repoPath/docs/deep').createSync(recursive: true);
      final DartIoGitClientImpl below = DartIoGitClientImpl(
        workingDirectory: '$repoPath/docs/deep',
      );

      expect(valueOf(await below.repositoryRoot()), repoPath);
    });

    test('fails with GitClientNotARepository outside any repository', () async {
      final String outside = '$base/plain';
      Directory(outside).createSync();
      final DartIoGitClientImpl loose = DartIoGitClientImpl(
        workingDirectory: outside,
      );

      expect(
        failureOf(await loose.repositoryRoot()),
        GitClientNotARepository(outside),
      );
    });

    test(
      'fails with GitClientNotARepository when the folder is gone',
      () async {
        final String gone = '$base/deleted';
        final DartIoGitClientImpl orphan = DartIoGitClientImpl(
          workingDirectory: gone,
        );

        expect(
          failureOf(await orphan.repositoryRoot()),
          GitClientNotARepository(gone),
        );
      },
    );

    test(
      'fails rather than throwing when the folder cannot even be probed',
      () async {
        // Under a parent the machine will not read, the probe for the folder
        // throws too.
        final String locked = '$base/locked';
        Directory('$locked/space').createSync(recursive: true);
        Process.runSync('chmod', <String>['000', locked]);

        final Result<String, GitClientFailure> root = await DartIoGitClientImpl(
          workingDirectory: '$locked/space',
        ).repositoryRoot();

        Process.runSync('chmod', <String>['755', locked]);
        expect(failureOf(root), GitClientNotARepository('$locked/space'));
      },
      skip: Platform.isWindows
          ? 'chmod does not model POSIX permissions on Windows'
          : false,
    );
  });

  group('from a folder below the repository root', () {
    late DartIoGitClientImpl below;

    setUp(() {
      Directory('$repoPath/docs').createSync();
      below = DartIoGitClientImpl(workingDirectory: '$repoPath/docs');
    });

    test('status names paths the client can be handed straight back', () async {
      write('docs/b.md', '# B\n');

      final String path = valueOf(await below.status())
          .split('\u0000')
          .firstWhere((String entry) => entry.startsWith('? '))
          .substring(2);

      expect(path, 'docs/b.md');
      expect(
        await below.stage(<String>[path]),
        isA<Success<void, GitClientFailure>>(),
      );
      expect(valueOf(await below.status()), contains('1 A. '));
    });

    test('unstage takes the same path back out', () async {
      write('docs/b.md', '# B\n');
      await below.stage(<String>['docs/b.md']);

      expect(
        await below.unstage(<String>['docs/b.md']),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(valueOf(await below.status()), contains('? docs/b.md'));
    });

    test('log filters on the same path', () async {
      write('docs/b.md', '# B\n');
      await below.stage(<String>['docs/b.md']);
      await below.commit('Add B');

      final List<String> records = valueOf(await below.log(path: 'docs/b.md'))
          .split(GitClient.recordSeparator)
          .where((String r) => r.trim().isNotEmpty)
          .toList();

      expect(records, hasLength(1));
      expect(records.single, contains('Add B'));
    });

    test('log follows the document across a rename', () async {
      write(
        'docs/old.md',
        '# Old\n\nA paragraph long enough for git to know it again.\n'
            'And a second line, so the similarity is not in doubt.\n',
      );
      await below.stage(<String>['docs/old.md']);
      await below.commit('Write it');
      git(<String>['mv', 'docs/old.md', 'docs/new.md']);
      git(<String>['commit', '--quiet', '--message', 'Rename it']);
      write(
        'docs/new.md',
        '# Old\n\nA paragraph long enough for git to know it again.\n'
            'And a second line, so the similarity is not in doubt.\nMore.\n',
      );
      await below.stage(<String>['docs/new.md']);
      await below.commit('Extend it');

      final String log = valueOf(await below.log(path: 'docs/new.md'));

      expect(log, contains('Extend it'));
      expect(log, contains('Rename it'));
      expect(log, contains('Write it'));
    });

    test('a path git would read as a glob is taken literally', () async {
      write('docs/notes[draft].md', '# Draft\n');

      expect(
        await below.stage(<String>['docs/notes[draft].md']),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(valueOf(await below.status()), contains('docs/notes[draft].md'));
    });
  });

  group('status', () {
    test('reports the branch and nothing else when clean', () async {
      final String status = valueOf(await client.status());

      expect(status, contains('# branch.head main'));
      expect(
        status
            .split('\u0000')
            .where((String e) => e.isNotEmpty && !e.startsWith('#')),
        isEmpty,
      );
    });

    test('reports modified, untracked and deleted paths', () async {
      write('a.md', '# A changed\n');
      write('b.md', '# B\n');
      write('c.md', '# C\n');
      git(<String>['add', 'c.md']);
      git(<String>['commit', '--quiet', '--message', 'Add C']);
      File('$repoPath/c.md').deleteSync();

      final List<String> entries = valueOf(await client.status())
          .split('\u0000')
          .where((String e) => e.isNotEmpty && !e.startsWith('#'))
          .toList();

      expect(entries, hasLength(3));
      expect(
        entries.firstWhere((String e) => e.endsWith('a.md')),
        startsWith('1 .M'),
      );
      expect(
        entries.firstWhere((String e) => e.endsWith('c.md')),
        startsWith('1 .D'),
      );
      expect(entries, contains('? b.md'));
    });

    test(
      'keeps a path with a quote parseable, which is why -z is used',
      () async {
        write('my "notes".md', '# Notes\n');

        final String status = valueOf(await client.status());

        expect(status.split('\u0000'), contains('? my "notes".md'));
      },
    );
  });

  group('stage, commit and unstage', () {
    test('staging then committing leaves the tree clean', () async {
      write('b.md', '# B\n');

      expect(
        await client.stage(<String>['b.md']),
        isA<Success<void, GitClientFailure>>(),
      );
      expect(
        await client.commit('Add B'),
        isA<Success<void, GitClientFailure>>(),
      );

      final String status = valueOf(await client.status());
      expect(
        status
            .split('\u0000')
            .where((String e) => e.isNotEmpty && !e.startsWith('#')),
        isEmpty,
      );
    });

    test('staging covers a deletion', () async {
      File('$repoPath/a.md').deleteSync();

      await client.stage(<String>['a.md']);

      expect(valueOf(await client.status()), contains('1 D.'));
    });

    test('unstaging leaves the working tree alone', () async {
      write('b.md', '# B\n');
      await client.stage(<String>['b.md']);

      expect(
        await client.unstage(<String>['b.md']),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(valueOf(await client.status()), contains('? b.md'));
      expect(File('$repoPath/b.md').existsSync(), isTrue);
    });

    test('unstaging works before the first commit', () async {
      final String fresh = '$base/fresh';
      initRepository(fresh);
      File('$fresh/b.md').writeAsStringSync('# B\n');
      final DartIoGitClientImpl client = DartIoGitClientImpl(
        workingDirectory: fresh,
      );
      await client.stage(<String>['b.md']);

      expect(
        await client.unstage(<String>['b.md']),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(valueOf(await client.status()), contains('? b.md'));
      expect(File('$fresh/b.md').existsSync(), isTrue);
    });

    test('unstaging a path that was not staged is not a failure', () async {
      final String fresh = '$base/fresh-untouched';
      initRepository(fresh);
      File('$fresh/b.md').writeAsStringSync('# B\n');
      final DartIoGitClientImpl client = DartIoGitClientImpl(
        workingDirectory: fresh,
      );

      expect(
        await client.unstage(<String>['b.md']),
        isA<Success<void, GitClientFailure>>(),
      );
    });

    test('committing nothing fails with GitClientCommandFailed', () async {
      final AppFailure failure = failureOf(await client.commit('Empty'));

      expect(failure, isA<GitClientCommandFailed>());
      expect((failure as GitClientCommandFailed).command, contains('commit'));
    });
  });

  group('the link to the remote', () {
    test('a remote whose host does not resolve is no network', () async {
      // `.invalid` is reserved never to resolve (RFC 2606).
      git(<String>['remote', 'add', 'origin', 'https://tom.invalid/x.git']);

      expect(
        failureOf(await client.fetch()),
        isA<GitClientNetworkUnavailable>(),
      );
    });

    test('a repository with no remote says so', () async {
      expect(failureOf(await client.push()), isA<GitClientNoRemote>());
    });
  });

  group('without a remote', () {
    test(
      'there is no address and no default branch, and neither fails',
      () async {
        expect(valueOf(await client.remoteUrl()), '');
        expect(valueOf(await client.defaultBranch()), '');
      },
    );

    test('head names the last commit, and nothing before the first', () async {
      final String fresh = '$base/fresh';
      initRepository(fresh);

      expect(valueOf(await client.head()), matches(RegExp(r'^[0-9a-f]{40}$')));
      expect(
        valueOf(await DartIoGitClientImpl(workingDirectory: fresh).head()),
        '',
      );
    });

    test('there is no upstream to count commits against', () async {
      expect(
        failureOf(await client.upstreamCommitsSince('')),
        isA<GitClientCommandFailed>(),
      );
    });

    test('unrelated histories share no merge-base', () async {
      git(<String>['switch', '--quiet', '--orphan', 'loose']);
      write('c.md', '# C\n');
      git(<String>['add', 'c.md']);
      git(<String>['commit', '--quiet', '--message', 'Loose']);

      expect(valueOf(await client.mergeBase('main')), '');
    });
  });

  group('discardAll', () {
    test('puts a modified file back as the last commit had it', () async {
      write('a.md', '# A, changed\n');

      expect(await client.discardAll(), isA<Success<void, GitClientFailure>>());

      expect(File('$repoPath/a.md').readAsStringSync(), '# A\n');
    });

    test('brings a deleted file back, staged or not', () async {
      File('$repoPath/a.md').deleteSync();
      git(<String>['add', '--all']);

      await client.discardAll();

      expect(File('$repoPath/a.md').readAsStringSync(), '# A\n');
      expect(valueOf(await client.status()), isNot(contains('a.md')));
    });

    test('never touches an untracked file', () async {
      write('notes.md', '# Mine\n');

      await client.discardAll();

      expect(File('$repoPath/notes.md').readAsStringSync(), '# Mine\n');
    });

    // An added file was never committed, so going back would lose it: it is
    // unstaged and kept, which is what a file git never recorded is.
    test('keeps an added file, as untracked', () async {
      write('b.md', '# B\n');
      git(<String>['add', 'b.md']);

      await client.discardAll();

      expect(File('$repoPath/b.md').readAsStringSync(), '# B\n');
      expect(valueOf(await client.status()), contains('? b.md'));
    });

    test('reaches the whole repository from a folder below it', () async {
      write('docs/c.md', '# C\n');
      git(<String>['add', 'docs/c.md']);
      git(<String>['commit', '--quiet', '--message', 'Add C']);
      write('a.md', '# A, changed\n');
      final DartIoGitClientImpl below = DartIoGitClientImpl(
        workingDirectory: '$repoPath/docs',
      );

      await below.discardAll();

      expect(File('$repoPath/a.md').readAsStringSync(), '# A\n');
    });
  });

  group('discarding one file', () {
    String read(String path) => File('$repoPath/$path').readAsStringSync();

    test('discardUnstaged puts the working tree back as staged', () async {
      write('a.md', '# A, staged\n');
      git(<String>['add', 'a.md']);
      write('a.md', '# A, staged, then more\n');

      expect(
        await client.discardUnstaged(<String>['a.md']),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(read('a.md'), '# A, staged\n');
      expect(valueOf(await client.status()), contains('M. '));
    });

    test('discardUnstaged brings back a file deleted from disk', () async {
      File('$repoPath/a.md').deleteSync();

      await client.discardUnstaged(<String>['a.md']);

      expect(read('a.md'), '# A\n');
    });

    test('discardSinceCommit puts a staged file back as committed', () async {
      write('a.md', '# A, staged\n');
      git(<String>['add', 'a.md']);
      write('a.md', '# A, staged, then more\n');

      expect(
        await client.discardSinceCommit(<String>['a.md']),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(read('a.md'), '# A\n');
      expect(valueOf(await client.status()), isNot(contains('a.md')));
    });

    test('discardSinceCommit undoes a staged rename and deletion', () async {
      write('b.md', '# B\n');
      git(<String>['add', 'b.md']);
      git(<String>['commit', '--quiet', '--message', 'Add B']);
      git(<String>['mv', 'a.md', 'renamed.md']);
      git(<String>['rm', '--quiet', 'b.md']);

      await client.discardSinceCommit(<String>['renamed.md', 'a.md', 'b.md']);

      expect(read('a.md'), '# A\n');
      expect(read('b.md'), '# B\n');
      expect(File('$repoPath/renamed.md').existsSync(), isFalse);
      expect(valueOf(await client.status()), isNot(contains('.md')));
    });

    test('deleteUncommitted deletes untracked files, in new folders', () async {
      write('notes/new.md', '# New\n');
      write('loose.md', '# Loose\n');

      expect(
        await client.deleteUncommitted(<String>['notes/new.md', 'loose.md']),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(File('$repoPath/notes/new.md').existsSync(), isFalse);
      expect(File('$repoPath/loose.md').existsSync(), isFalse);
      expect(read('a.md'), '# A\n');
    });

    test('deleteUncommitted unstages an added file, then deletes it', () async {
      write('b.md', '# B\n');
      git(<String>['add', 'b.md']);
      write('b.md', '# B, edited since\n');

      await client.deleteUncommitted(<String>['b.md']);

      expect(File('$repoPath/b.md').existsSync(), isFalse);
      expect(valueOf(await client.status()), isNot(contains('b.md')));
    });

    // The caller's list can be older than the repository — a commit made in
    // the terminal meanwhile — and `clean` cannot be undone.
    group('deleteUncommitted handed a file HEAD holds', () {
      test('deletes nothing, and names it', () async {
        write('a.md', '# A, edited and not committed\n');

        final Result<void, GitClientFailure> result = await client
            .deleteUncommitted(<String>['a.md']);

        expect(
          (result as Failure<void, GitClientFailure>).failure,
          const GitClientPathCommitted(<String>['a.md']),
        );
        expect(read('a.md'), '# A, edited and not committed\n');
        expect(valueOf(await client.status()), contains('a.md'));
      });

      test('a file committed since the list was read is kept, though it '
          'was new when the row was drawn', () async {
        write('b.md', '# B\n');
        final String listedAsNew = valueOf(await client.status());
        expect(listedAsNew, contains('b.md'));
        git(<String>['add', 'b.md']);
        git(<String>['commit', '--quiet', '--message', 'Add B, elsewhere']);

        final Result<void, GitClientFailure> result = await client
            .deleteUncommitted(<String>['b.md']);

        expect(
          (result as Failure<void, GitClientFailure>).failure,
          const GitClientPathCommitted(<String>['b.md']),
        );
        expect(read('b.md'), '# B\n');
        expect(
          git(<String>['ls-files', 'b.md']).stdout.toString().trim(),
          'b.md',
        );
      });

      test('refuses the whole batch, the new files beside it kept '
          'too', () async {
        write('new.md', '# New\n');
        write('a.md', '# A, changed\n');

        final Result<void, GitClientFailure> result = await client
            .deleteUncommitted(<String>['new.md', 'a.md']);

        expect(
          (result as Failure<void, GitClientFailure>).failure,
          const GitClientPathCommitted(<String>['a.md']),
        );
        expect(File('$repoPath/new.md').existsSync(), isTrue);
        expect(read('a.md'), '# A, changed\n');
      });

      test('a committed file deleted from the disk and staged that way is '
          'still committed', () async {
        git(<String>['rm', '--quiet', 'a.md']);

        final Result<void, GitClientFailure> result = await client
            .deleteUncommitted(<String>['a.md']);

        expect(
          (result as Failure<void, GitClientFailure>).failure,
          const GitClientPathCommitted(<String>['a.md']),
        );
      });

      test('from a folder below the root, by the root\'s path', () async {
        write('docs/c.md', '# C\n');
        git(<String>['add', 'docs/c.md']);
        git(<String>['commit', '--quiet', '--message', 'Add C']);
        final DartIoGitClientImpl below = DartIoGitClientImpl(
          workingDirectory: '$repoPath/docs',
        );

        final Result<void, GitClientFailure> result = await below
            .deleteUncommitted(<String>['docs/c.md']);

        expect(
          (result as Failure<void, GitClientFailure>).failure,
          const GitClientPathCommitted(<String>['docs/c.md']),
        );
        expect(read('docs/c.md'), '# C\n');
      });

      test('a name git would read as a pattern matches only itself', () async {
        write('[a].md', '# New, with brackets\n');

        expect(
          await client.deleteUncommitted(<String>['[a].md']),
          isA<Success<void, GitClientFailure>>(),
        );
        expect(File('$repoPath/[a].md').existsSync(), isFalse);
        expect(read('a.md'), '# A\n');
      });
    });

    test('reaches the repository root from a folder below it', () async {
      write('docs/c.md', '# C\n');
      write('a.md', '# A, changed\n');
      final DartIoGitClientImpl below = DartIoGitClientImpl(
        workingDirectory: '$repoPath/docs',
      );

      await below.discardUnstaged(<String>['a.md']);
      await below.deleteUncommitted(<String>['docs/c.md']);

      expect(read('a.md'), '# A\n');
      expect(File('$repoPath/docs/c.md').existsSync(), isFalse);
    });

    group('before the first commit', () {
      late String fresh;
      late DartIoGitClientImpl unborn;

      setUp(() {
        fresh = '$base/fresh';
        initRepository(fresh);
        File('$fresh/a.md').writeAsStringSync('# A\n');
        git(<String>['add', 'a.md'], inside: fresh);
        File('$fresh/a.md').writeAsStringSync('# A, edited since\n');
        unborn = DartIoGitClientImpl(workingDirectory: fresh);
      });

      test('deleteUncommitted deletes a staged file', () async {
        expect(
          await unborn.deleteUncommitted(<String>['a.md']),
          isA<Success<void, GitClientFailure>>(),
        );

        expect(File('$fresh/a.md').existsSync(), isFalse);
        expect(valueOf(await unborn.status()), isNot(contains('a.md')));
      });

      test('discardUnstaged puts back what is staged', () async {
        await unborn.discardUnstaged(<String>['a.md']);

        expect(File('$fresh/a.md').readAsStringSync(), '# A\n');
      });

      test('discardSinceCommit fails and touches nothing', () async {
        expect(
          failureOf(await unborn.discardSinceCommit(<String>['a.md'])),
          isA<GitClientCommandFailed>(),
        );

        expect(File('$fresh/a.md').readAsStringSync(), '# A, edited since\n');
      });
    });
  });

  group('log', () {
    test('returns the six fields the contract promises, in order', () async {
      final List<String> records = valueOf(await client.log())
          .split(GitClient.recordSeparator)
          .where((String r) => r.trim().isNotEmpty)
          .toList();

      expect(records, hasLength(1));
      final List<String> fields = records.single.split(GitClient.unitSeparator);
      expect(fields, hasLength(6));
      expect(fields[0], hasLength(40));
      expect(fields[1], 'Test');
      expect(fields[2], 'test@example.com');
      expect(DateTime.parse(fields[3]).year, greaterThan(2000));
      expect(fields[4], 'Add A');
      expect(fields[5].trim(), isEmpty);
    });

    test('keeps a multi-line body in the last field', () async {
      write('b.md', '# B\n');
      await client.stage(<String>['b.md']);
      await client.commit('Add B\n\nWhy: because.\nAnd a second line.');

      final String first = valueOf(
        await client.log(limit: 1),
      ).split(GitClient.recordSeparator).first;
      final List<String> fields = first.split(GitClient.unitSeparator);

      expect(fields[4], 'Add B');
      expect(fields[5], contains('And a second line.'));
    });

    test('limit caps the number of records', () async {
      write('b.md', '# B\n');
      await client.stage(<String>['b.md']);
      await client.commit('Add B');

      final int records = valueOf(await client.log(limit: 1))
          .split(GitClient.recordSeparator)
          .where((String r) => r.trim().isNotEmpty)
          .length;

      expect(records, 1);
    });

    test(
      'a branch with no commits yet returns nothing, not a failure',
      () async {
        final String fresh = '$base/fresh';
        initRepository(fresh);

        final Result<String, GitClientFailure> log = await DartIoGitClientImpl(
          workingDirectory: fresh,
        ).log();

        expect(valueOf(log).trim(), isEmpty);
      },
    );

    test('path returns only the commits that touched it', () async {
      write('b.md', '# B\n');
      await client.stage(<String>['b.md']);
      await client.commit('Add B');

      final List<String> records = valueOf(await client.log(path: 'b.md'))
          .split(GitClient.recordSeparator)
          .where((String r) => r.trim().isNotEmpty)
          .toList();

      expect(records, hasLength(1));
      expect(records.single, contains('Add B'));
    });
  });

  test('version is the one line git prints, with a release in it', () async {
    final String line = valueOf(await client.version());

    expect(line, startsWith('git version '));
    expect(line, isNot(contains('\n')));
    expect(line, matches(RegExp(r'\d+\.\d+')));
  });

  group('branches', () {
    test('marks the current branch and leaves the rest a space', () async {
      git(<String>['branch', 'draft']);

      final List<List<String>> records = valueOf(await client.branches())
          .split(GitClient.recordSeparator)
          .where((String r) => r.trim().isNotEmpty)
          .map((String r) => r.trim().split(GitClient.unitSeparator))
          .toList();

      expect(records, hasLength(2));
      expect(records.firstWhere((List<String> r) => r.first == 'main')[1], '*');
      expect(
        records.firstWhere((List<String> r) => r.first == 'draft')[1].trim(),
        isEmpty,
      );
    });
  });

  group('createBranch and switchBranch', () {
    test('creating a branch switches to it', () async {
      expect(
        await client.createBranch('draft'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(valueOf(await client.status()), contains('# branch.head draft'));
    });

    test('switching moves back', () async {
      await client.createBranch('draft');

      expect(
        await client.switchBranch('main'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(valueOf(await client.status()), contains('# branch.head main'));
    });

    test('switching to a branch that does not exist fails', () async {
      expect(
        failureOf(await client.switchBranch('nope')),
        isA<GitClientCommandFailed>(),
      );
    });

    test('switching that would discard uncommitted work fails', () async {
      git(<String>['branch', 'draft']);
      git(<String>['switch', '--quiet', 'draft']);
      write('a.md', '# A on draft\n');
      git(<String>['add', 'a.md']);
      git(<String>['commit', '--quiet', '--message', 'A on draft']);
      git(<String>['switch', '--quiet', 'main']);
      write('a.md', '# A edited, not saved anywhere\n');

      expect(
        failureOf(await client.switchBranch('draft')),
        isA<GitClientCommandFailed>(),
      );
    });
  });

  group('the branch a branch was started from', () {
    test('is empty until somebody records it', () async {
      git(<String>['branch', 'draft']);

      expect(valueOf(await client.branchBase('draft')), '');
    });

    test('reads back what was recorded, in the repository config', () async {
      git(<String>['branch', 'feat/notes']);

      expect(
        await client.recordBranchBase('feat/notes', 'main'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(valueOf(await client.branchBase('feat/notes')), 'main');
      expect(
        (git(<String>['config', '--get', 'branch.feat/notes.tomBase']).stdout
                as String)
            .trim(),
        'main',
      );
    });

    test('goes with the branch when git deletes it', () async {
      git(<String>['branch', 'draft']);
      await client.recordBranchBase('draft', 'main');
      git(<String>['branch', '--delete', 'draft']);

      expect(valueOf(await client.branchBase('draft')), '');
    });
  });

  group('who commits, and the GitHub account chosen here', () {
    test('the identity is both halves, unit-separated', () async {
      expect(
        valueOf(await client.identity()),
        'Test${GitClient.unitSeparator}test@example.com',
      );
    });

    test('a half nobody set is empty, not a failure', () async {
      git(<String>['config', '--unset', 'user.email']);
      // The test machine's own global config must not answer for it.
      git(<String>['config', 'user.email', '']);

      expect(
        valueOf(await client.identity()),
        'Test${GitClient.unitSeparator}',
      );
    });

    test('the account is empty until chosen, then reads back', () async {
      expect(valueOf(await client.githubAccount()), '');

      expect(
        await client.recordGithubAccount('octocat'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(valueOf(await client.githubAccount()), 'octocat');
      expect(
        (git(<String>['config', '--local', '--get', 'tom.githubAccount']).stdout
                as String)
            .trim(),
        'octocat',
      );
    });
  });

  group('branchStandings', () {
    /// The records, as `ref → [symref, "ahead behind"]`.
    Map<String, List<String>> standings(String text) => <String, List<String>>{
      for (final String record in text.split(GitClient.recordSeparator))
        if (record.trim().isNotEmpty)
          record.trim().split(GitClient.unitSeparator).first: record
              .trim()
              .split(GitClient.unitSeparator)
              .sublist(1),
    };

    void commit(String message) {
      write('a.md', '# $message\n');
      git(<String>['commit', '--quiet', '--all', '--message', message]);
    }

    test('stands every branch against HEAD in one walk', () async {
      git(<String>['switch', '--quiet', '--create', 'develop']);
      commit('develop moves');
      git(<String>['switch', '--quiet', '--create', 'feat/notes']);
      commit('the feature');
      commit('the feature again');

      final Map<String, List<String>> read = standings(
        valueOf(await client.branchStandings()),
      );

      expect(read['refs/heads/main'], <String>['', '0 3']);
      expect(read['refs/heads/develop'], <String>['', '0 2']);
      expect(read['refs/heads/feat/notes'], <String>['', '0 0']);
    });

    test('a branch ahead of HEAD says so', () async {
      git(<String>['switch', '--quiet', '--create', 'feat/notes']);
      commit('the feature');
      git(<String>['switch', '--quiet', 'main']);

      final Map<String, List<String>> read = standings(
        valueOf(await client.branchStandings()),
      );

      expect(read['refs/heads/feat/notes'], <String>['', '1 0']);
    });

    test(
      'names a symbolic ref\'s target, remote-tracking refs included',
      () async {
        final String sha = (git(<String>['rev-parse', 'HEAD']).stdout as String)
            .trim();
        git(<String>['update-ref', 'refs/remotes/origin/main', sha]);
        git(<String>[
          'symbolic-ref',
          'refs/remotes/origin/HEAD',
          'refs/remotes/origin/main',
        ]);

        final Map<String, List<String>> read = standings(
          valueOf(await client.branchStandings()),
        );

        expect(read['refs/remotes/origin/main'], <String>['', '0 0']);
        expect(
          read['refs/remotes/origin/HEAD']?.first,
          'refs/remotes/origin/main',
        );
      },
    );

    test('is empty on a branch with no commits yet', () async {
      final String fresh = '$base/fresh';
      initRepository(fresh);

      expect(
        valueOf(
          await DartIoGitClientImpl(workingDirectory: fresh).branchStandings(),
        ),
        '',
      );
    });
  });

  group('commitCount', () {
    /// The count, failing the test when there is none.
    int countOf(Result<int, GitClientFailure> result) {
      expect(result, isA<Success<int, GitClientFailure>>(), reason: '$result');
      return (result as Success<int, GitClientFailure>).value;
    }

    test('counts what HEAD reaches', () async {
      write('a.md', '# A again\n');
      git(<String>['commit', '--quiet', '--all', '--message', 'Again']);

      expect(countOf(await client.commitCount()), 2);
    });

    test('is 0 on a branch with no commits yet', () async {
      final String fresh = '$base/fresh';
      initRepository(fresh);

      expect(
        countOf(
          await DartIoGitClientImpl(workingDirectory: fresh).commitCount(),
        ),
        0,
      );
    });
  });

  group('show', () {
    test('returns the content at a revision, not the working tree', () async {
      write('a.md', '# A changed\n');

      expect(valueOf(await client.show('HEAD', 'a.md')), '# A\n');
    });

    test('a path absent from the revision says so, and names both', () async {
      expect(
        failureOf(await client.show('HEAD', 'missing.md')),
        isA<GitClientPathNotInRevision>()
            .having(
              (GitClientPathNotInRevision failure) => failure.revision,
              'revision',
              'HEAD',
            )
            .having(
              (GitClientPathNotInRevision failure) => failure.path,
              'path',
              'missing.md',
            ),
      );
    });

    test('a file on disk that was never committed says the same', () async {
      write('untracked.md', '# Not committed\n');

      expect(
        failureOf(await client.show('HEAD', 'untracked.md')),
        isA<GitClientPathNotInRevision>(),
      );
    });

    test(
      'a revision that resolves to nothing is a failure, not an answer',
      () async {
        // Git says `invalid object name` for an unborn `HEAD` and for a sha it
        // cannot find alike, and only the first is "no earlier version".
        expect(
          failureOf(await client.show('deadbeef', 'a.md')),
          isA<GitClientCommandFailed>(),
        );
      },
    );

    test('a repository with no commits yet says the same', () async {
      final String freshPath = '$base/fresh';
      initRepository(freshPath);
      File('$freshPath/a.md').writeAsStringSync('# A\n');
      final DartIoGitClientImpl fresh = DartIoGitClientImpl(
        workingDirectory: freshPath,
      );

      expect(
        failureOf(await fresh.show('HEAD', 'a.md')),
        isA<GitClientPathNotInRevision>(),
      );
    });
  });

  group('showBytes', () {
    /// What a byte-level read answered, failing the test when it failed.
    List<int> bytesOf(Result<Uint8List, GitClientFailure> result) {
      expect(
        result,
        isA<Success<Uint8List, GitClientFailure>>(),
        reason: '$result',
      );
      return (result as Success<Uint8List, GitClientFailure>).value;
    }

    void writeBytes(String relativePath, List<int> bytes) =>
        File('$repoPath/$relativePath').writeAsBytesSync(bytes);

    // Not UTF-8 and with a zero in it: what a lenient decode would lose.
    const List<int> picture = <int>[0x89, 0x50, 0x4E, 0x47, 0x00, 0xFF, 0xFE];

    test('a committed binary file comes back byte for byte', () async {
      writeBytes('logo.png', picture);
      git(<String>['add', 'logo.png']);
      git(<String>['commit', '--quiet', '--message', 'Add the logo']);
      File('$repoPath/logo.png').deleteSync();

      expect(bytesOf(await client.showBytes('HEAD', 'logo.png')), picture);
    });

    test('text comes back as the bytes that were committed', () async {
      write('a.md', '# A changed\n');

      expect(
        bytesOf(await client.showBytes('HEAD', 'a.md')),
        '# A\n'.codeUnits,
      );
    });

    test('a path absent from the revision says so', () async {
      expect(
        failureOf(await client.showBytes('HEAD', 'missing.md')),
        isA<GitClientPathNotInRevision>().having(
          (GitClientPathNotInRevision failure) => failure.revision,
          'revision',
          'HEAD',
        ),
      );
    });

    test('a file staged and never committed is not in HEAD', () async {
      writeBytes('new.bin', picture);
      git(<String>['add', 'new.bin']);
      File('$repoPath/new.bin').deleteSync();

      expect(
        failureOf(await client.showBytes('HEAD', 'new.bin')),
        isA<GitClientPathNotInRevision>(),
      );
    });

    test('and the index still holds it, byte for byte', () async {
      writeBytes('new.bin', picture);
      git(<String>['add', 'new.bin']);
      File('$repoPath/new.bin').deleteSync();

      expect(bytesOf(await client.showStagedBytes('new.bin')), picture);
    });

    test('the index holds what was staged, not what was typed since', () async {
      write('a.md', '# A staged\n');
      git(<String>['add', 'a.md']);
      write('a.md', '# A typed since\n');

      expect(
        bytesOf(await client.showStagedBytes('a.md')),
        '# A staged\n'.codeUnits,
      );
    });

    test('a path the index does not hold says so, on disk or not', () async {
      write('untracked.md', '# Not staged\n');

      for (final String path in <String>['untracked.md', 'missing.md']) {
        expect(
          failureOf(await client.showStagedBytes(path)),
          isA<GitClientPathNotInRevision>()
              .having(
                (GitClientPathNotInRevision failure) => failure.revision,
                'revision',
                isEmpty,
              )
              .having(
                (GitClientPathNotInRevision failure) => failure.path,
                'path',
                path,
              ),
        );
      }
    });

    test('paths are the repository root\'s, from a folder below it', () async {
      Directory('$repoPath/docs').createSync();
      write('docs/new.txt', 'below\n');
      git(<String>['add', 'docs/new.txt']);
      final DartIoGitClientImpl below = DartIoGitClientImpl(
        workingDirectory: '$repoPath/docs',
      );

      expect(
        bytesOf(await below.showStagedBytes('docs/new.txt')),
        'below\n'.codeUnits,
      );
    });
  });

  group('against a remote', () {
    late String remotePath;
    late String otherPath;

    /// Arranges a bare remote, plus a second clone to move it from.
    setUp(() {
      remotePath = '$base/remote.git';
      otherPath = '$base/other';
      initRepository(remotePath, bare: true);
      git(<String>['remote', 'add', 'origin', remotePath]);
      git(<String>['push', '--quiet', '--set-upstream', 'origin', 'main']);
      git(<String>['clone', '--quiet', remotePath, otherPath], inside: base);
      for (final List<String> setting in const <List<String>>[
        <String>['user.name', 'Other'],
        <String>['user.email', 'other@example.com'],
        <String>['commit.gpgsign', 'false'],
      ]) {
        git(<String>['config', ...setting], inside: otherPath);
      }
    });

    /// Commits [content] to `a.md` in the second clone and pushes it.
    void pushFromElsewhere(String content, String message) {
      File('$otherPath/a.md').writeAsStringSync(content);
      git(<String>['add', 'a.md'], inside: otherPath);
      git(<String>[
        'commit',
        '--quiet',
        '--message',
        message,
      ], inside: otherPath);
      git(<String>['push', '--quiet'], inside: otherPath);
    }

    test('push publishes the branch', () async {
      write('b.md', '# B\n');
      await client.stage(<String>['b.md']);
      await client.commit('Add B');

      expect(await client.push(), isA<Success<void, GitClientFailure>>());

      final ProcessResult log = git(<String>[
        'log',
        '--oneline',
      ], inside: remotePath);
      expect(log.stdout, contains('Add B'));
    });

    test('fetch reports ahead and behind without touching the tree', () async {
      pushFromElsewhere('# A from elsewhere\n', 'A elsewhere');

      expect(await client.fetch(), isA<Success<void, GitClientFailure>>());

      expect(valueOf(await client.status()), contains('# branch.ab +0 -1'));
      expect(File('$repoPath/a.md').readAsStringSync(), '# A\n');
    });

    test('pull fast-forwards the working tree', () async {
      pushFromElsewhere('# A from elsewhere\n', 'A elsewhere');

      expect(await client.pull(), isA<Success<void, GitClientFailure>>());

      expect(File('$repoPath/a.md').readAsStringSync(), '# A from elsewhere\n');
    });

    test('pull merges divergent branches on an unconfigured machine', () async {
      // A bare `git pull` refuses divergent branches on a machine with no
      // `pull.rebase` set, which is most of them; the fixture sets none.
      pushFromElsewhere('# A from elsewhere\n', 'A elsewhere');
      write('mine.md', '# Mine\n');
      await client.stage(<String>['mine.md']);
      await client.commit('Mine here');

      expect(await client.pull(), isA<Success<void, GitClientFailure>>());

      // Merged, not rebased: the local commit is still there.
      expect(File('$repoPath/mine.md').existsSync(), isTrue);
      expect(File('$repoPath/a.md').readAsStringSync(), '# A from elsewhere\n');
    });

    test('publish sends a new branch and makes it tracked', () async {
      git(<String>['switch', '--quiet', '--create', 'feat/notes']);
      write('b.md', '# B\n');
      await client.stage(<String>['b.md']);
      await client.commit('Add B');
      expect(
        valueOf(await client.status()),
        isNot(contains('# branch.upstream')),
      );

      expect(
        await client.publish('feat/notes'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(
        valueOf(await client.status()),
        contains('# branch.upstream origin/feat/notes'),
      );
      expect(
        git(<String>[
          'branch',
          '--list',
          'feat/notes',
        ], inside: remotePath).stdout,
        contains('feat/notes'),
      );
    });

    group('what a pull brought', () {
      /// How many commits [since] lacks, failing the test on a failure.
      Future<int> arrivedSince(String since) async {
        final Result<int, GitClientFailure> counted = await client
            .upstreamCommitsSince(since);
        expect(counted, isA<Success<int, GitClientFailure>>());
        return (counted as Success<int, GitClientFailure>).value;
      }

      test('counts the commits a fast-forward brought', () async {
        final String before = valueOf(await client.head());
        pushFromElsewhere('# A, one\n', 'One');
        pushFromElsewhere('# A, two\n', 'Two');

        await client.pull();

        expect(await arrivedSince(before), 2);
        expect(valueOf(await client.head()), isNot(before));
      });

      test('leaves out the merge commit the pull made here', () async {
        pushFromElsewhere('# A from elsewhere\n', 'A elsewhere');
        write('mine.md', '# Mine\n');
        await client.stage(<String>['mine.md']);
        await client.commit('Mine here');
        final String before = valueOf(await client.head());

        await client.pull();

        expect(await arrivedSince(before), 1);
      });

      test('is nothing when the branch was already level', () async {
        final String before = valueOf(await client.head());

        await client.pull();

        expect(await arrivedSince(before), 0);
      });

      test('with no earlier commit, is everything upstream has', () async {
        expect(await arrivedSince(''), 1);
      });
    });

    test('pull fails with GitClientMergeConflict, naming the paths', () async {
      pushFromElsewhere('# A from elsewhere\n', 'A elsewhere');
      write('a.md', '# A from here\n');
      await client.stage(<String>['a.md']);
      await client.commit('A here');

      expect(
        failureOf(await client.pull()),
        const GitClientMergeConflict(<String>['a.md']),
      );
    });

    test('a conflict git words differently is still named', () async {
      // Modify/delete prints `CONFLICT (modify/delete): a.md deleted in ...`,
      // with no `Merge conflict in` line to read the path off.
      File('$otherPath/a.md').deleteSync();
      git(<String>['add', '--all'], inside: otherPath);
      git(<String>[
        'commit',
        '--quiet',
        '--message',
        'Delete A',
      ], inside: otherPath);
      git(<String>['push', '--quiet'], inside: otherPath);
      write('a.md', '# A from here\n');
      await client.stage(<String>['a.md']);
      await client.commit('A here');

      expect(
        failureOf(await client.pull()),
        const GitClientMergeConflict(<String>['a.md']),
      );
    });

    test('pull refuses over uncommitted changes, naming the files', () async {
      pushFromElsewhere('# A from elsewhere\n', 'A elsewhere');
      write('a.md', '# A, not committed\n');

      expect(
        failureOf(await client.pull()),
        const GitClientLocalChangesOverwritten(<String>['a.md']),
      );
      // Refused before it started: nothing arrived and the edit is intact.
      expect(File('$repoPath/a.md').readAsStringSync(), '# A, not committed\n');
    });

    test('pull refuses over an untracked file it would create', () async {
      File('$otherPath/notes/b.md')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('# B from elsewhere\n');
      git(<String>['add', '--all'], inside: otherPath);
      git(<String>[
        'commit',
        '--quiet',
        '--message',
        'Add B',
      ], inside: otherPath);
      git(<String>['push', '--quiet'], inside: otherPath);
      write('notes/b.md', '# B, never added\n');

      expect(
        failureOf(await client.pull()),
        const GitClientLocalChangesOverwritten(<String>['notes/b.md']),
      );
    });

    test(
      'push fails with GitClientPushRejected when the remote moved',
      () async {
        pushFromElsewhere('# A from elsewhere\n', 'A elsewhere');
        write('b.md', '# B\n');
        await client.stage(<String>['b.md']);
        await client.commit('Add B');

        expect(failureOf(await client.push()), isA<GitClientPushRejected>());
      },
    );

    test('push fails with GitClientBranchProtected when the remote protects '
        'the branch, whatever else it says', () async {
      // GitHub's own wording, from a hook the bare remote really runs.
      final File hook = File('$remotePath/hooks/pre-receive')
        ..writeAsStringSync(
          '#!/bin/sh\n'
          'echo "error: GH006: Protected branch update failed for '
          'refs/heads/main." >&2\n'
          'exit 1\n',
        );
      Process.runSync('chmod', <String>['+x', hook.path]);
      write('b.md', '# B\n');
      await client.stage(<String>['b.md']);
      await client.commit('Add B');

      expect(failureOf(await client.push()), isA<GitClientBranchProtected>());
    });

    group('what a pull request proposes', () {
      /// A branch off `main` with two commits, while `main` moves on the
      /// remote — what three dots exist to leave out.
      setUp(() async {
        git(<String>['switch', '--quiet', '--create', 'feat/x']);
        write('a.md', '# A\n\nMore.\n');
        write('docs/b.md', '# B\n');
        git(<String>['add', '--all']);
        git(<String>['commit', '--quiet', '--message', 'First on x']);
        File('$repoPath/a.md').writeAsStringSync('# A\n');
        git(<String>['add', '--all']);
        git(<String>['commit', '--quiet', '--message', 'Second on x']);
        pushFromElsewhere('# A moved on main\n', 'Main moved');
        git(<String>['fetch', '--quiet']);
      });

      test('log since the base lists only the branch, newest first', () async {
        final String log = valueOf(await client.log(since: 'origin/main'));

        expect(log, contains('Second on x'));
        expect(log, contains('First on x'));
        expect(log, isNot(contains('Main moved')));
        expect(log, isNot(contains('Add A')));
        expect(log.indexOf('Second on x'), lessThan(log.indexOf('First on x')));
      });

      test('the diffs count from the fork point, not from main now', () async {
        // a.md went out and back: nothing; main's own edit is not counted.
        expect(
          valueOf(await client.diffNameStatus('origin/main')),
          'A\u0000docs/b.md\u0000',
        );
        expect(
          valueOf(await client.diffNumstat('origin/main')),
          '1\t0\tdocs/b.md\u0000',
        );
      });

      test('merge-base is where the branch left the base', () async {
        final String fork = valueOf(await client.mergeBase('origin/main'));
        final String first =
            (git(<String>['rev-list', '--max-parents=0', 'HEAD']).stdout
                    as String)
                .trim();

        expect(fork, first);
      });

      test('resolves says yes and no without failing', () async {
        expect(
          await client.resolves('origin/main'),
          const Success<bool, GitClientFailure>(true),
        );
        expect(
          await client.resolves('origin/nowhere'),
          const Success<bool, GitClientFailure>(false),
        );
      });

      test('the remote address is origin’s', () async {
        expect(valueOf(await client.remoteUrl()), remotePath);
      });

      test('the default branch is guessed when origin/HEAD is unset', () async {
        // `remote add` writes no `origin/HEAD`; a clone does.
        expect(valueOf(await client.defaultBranch()), 'main');
        expect(
          valueOf(
            await DartIoGitClientImpl(
              workingDirectory: otherPath,
            ).defaultBranch(),
          ),
          'main',
        );
      });
    });

    group('the merge a conflicted pull left', () {
      /// Pulls into a conflict, the way a user reaches this state.
      Future<void> conflict() async {
        pushFromElsewhere('# A from elsewhere\n', 'A elsewhere');
        write('a.md', '# A from here\n');
        await client.stage(<String>['a.md']);
        await client.commit('A here');
        await client.pull();
      }

      test('mergeInProgress is false in a repository at rest', () async {
        expect(
          (await client.mergeInProgress() as Success<bool, GitClientFailure>)
              .value,
          isFalse,
        );
      });

      test('mergeInProgress is true once a pull has conflicted', () async {
        await conflict();

        expect(
          (await client.mergeInProgress() as Success<bool, GitClientFailure>)
              .value,
          isTrue,
        );
      });

      test('mergeMessage is empty when there is no merge', () async {
        expect(valueOf(await client.mergeMessage()), isEmpty);
      });

      test('mergeMessage is the draft git wrote', () async {
        await conflict();

        final String message = valueOf(await client.mergeMessage());

        expect(message, contains('Merge branch'));
        expect(message, isNotEmpty);
      });

      test('abortMerge puts the working tree back', () async {
        await conflict();

        expect(
          await client.abortMerge(),
          isA<Success<void, GitClientFailure>>(),
        );
        expect(
          (await client.mergeInProgress() as Success<bool, GitClientFailure>)
              .value,
          isFalse,
        );
        // The local commit survives: aborting undoes the merge, not the work.
        expect(File('$repoPath/a.md').readAsStringSync(), '# A from here\n');
      });

      test('abortMerge fails when there is nothing to abort', () async {
        expect(failureOf(await client.abortMerge()), isA<GitClientFailure>());
      });
    });
  });

  group('gitDirectory', () {
    test('is the .git folder of an ordinary repository', () async {
      expect(valueOf(await client.gitDirectory()), '$repoPath/.git');
    });

    test('is the same, and absolute, from a folder below the root', () async {
      Directory('$repoPath/docs/deep').createSync(recursive: true);

      expect(
        valueOf(
          await DartIoGitClientImpl(
            workingDirectory: '$repoPath/docs/deep',
          ).gitDirectory(),
        ),
        '$repoPath/.git',
      );
    });

    test('from a worktree, is the one every worktree shares', () async {
      final String worktree = '$base/worktree';
      git(<String>['worktree', 'add', '--quiet', '-b', 'side', worktree]);

      expect(File('$worktree/.git').statSync().type, FileSystemEntityType.file);
      expect(
        valueOf(
          await DartIoGitClientImpl(workingDirectory: worktree).gitDirectory(),
        ),
        '$repoPath/.git',
      );
    });
  });

  group('clone', () {
    late String remotePath;

    /// A bare remote holding `a.md`, which is what a URL points at.
    setUp(() {
      remotePath = '$base/remote.git';
      initRepository(remotePath, bare: true);
      git(<String>['remote', 'add', 'origin', remotePath]);
      git(<String>['push', '--quiet', 'origin', 'main']);
    });

    test('fills the folder, and the same client then serves it', () async {
      final String destination = '$base/cloned';
      final DartIoGitClientImpl cloner = DartIoGitClientImpl(
        workingDirectory: destination,
      );

      expect(
        await cloner.clone('file://$remotePath'),
        isA<Success<void, GitClientFailure>>(),
      );

      expect(File('$destination/a.md').readAsStringSync(), '# A\n');
      expect(valueOf(await cloner.repositoryRoot()), destination);
    });

    test('hands over what git reports, a line at a time', () async {
      final List<String> lines = <String>[];

      await DartIoGitClientImpl(
        workingDirectory: '$base/cloned',
      ).clone('file://$remotePath', onProgress: lines.add);

      expect(lines, isNotEmpty);
      expect(lines.first, startsWith('Cloning into'));
      expect(lines.where((String line) => line.contains('\r')), isEmpty);
    });

    test('creates the folders above the destination', () async {
      final String destination = '$base/not/yet/there';

      await DartIoGitClientImpl(
        workingDirectory: destination,
      ).clone(remotePath);

      expect(File('$destination/a.md').existsSync(), isTrue);
    });

    test('an address with nothing there is GitClientRemoteNotFound', () async {
      final DartIoGitClientImpl cloner = DartIoGitClientImpl(
        workingDirectory: '$base/cloned',
      );

      for (final String url in <String>[
        '$base/nowhere',
        'file://$base/nowhere',
        'htps://example.com/docs.git',
        'not a url',
      ]) {
        expect(
          failureOf(await cloner.clone(url)),
          isA<GitClientRemoteNotFound>(),
          reason: url,
        );
      }
      expect(Directory('$base/cloned').existsSync(), isFalse);
    });

    test('an address that would run a command is refused, unrun', () async {
      final String marker = '$base/ran';

      final AppFailure failure = failureOf(
        await DartIoGitClientImpl(
          workingDirectory: '$base/cloned',
        ).clone('ext::sh -c touch% $marker'),
      );

      expect(failure, isA<GitClientRemoteNotFound>());
      expect(File(marker).existsSync(), isFalse);
    });

    test('an address that reads as an option is still an address', () async {
      expect(
        failureOf(
          await DartIoGitClientImpl(
            workingDirectory: '$base/cloned',
          ).clone('--upload-pack=touch $base/ran'),
        ),
        isA<GitClientRemoteNotFound>(),
      );
      expect(File('$base/ran').existsSync(), isFalse);
    });

    test(
      'a folder that holds something is GitClientDestinationTaken',
      () async {
        final AppFailure failure = failureOf(
          await DartIoGitClientImpl(
            workingDirectory: repoPath,
          ).clone(remotePath),
        );

        expect(failure, isA<GitClientDestinationTaken>());
        expect((failure as GitClientDestinationTaken).path, repoPath);
      },
    );

    test('a host that does not resolve is no network', () async {
      // `.invalid` is reserved never to resolve (RFC 2606).
      expect(
        failureOf(
          await DartIoGitClientImpl(
            workingDirectory: '$base/cloned',
          ).clone('https://tom.invalid/docs.git'),
        ),
        isA<GitClientNetworkUnavailable>(),
      );
    });

    test('a clone that goes quiet past the limit is killed', () async {
      final AppFailure failure = failureOf(
        await DartIoGitClientImpl(
          workingDirectory: '$base/cloned',
          networkTimeout: Duration.zero,
        ).clone('file://$remotePath'),
      );

      expect(failure, isA<GitClientTimedOut>());
    });
  });

  group('the queue', () {
    test(
      'serializes commands that would otherwise race the index lock',
      () async {
        final List<Future<Result<void, GitClientFailure>>> operations =
            <Future<Result<void, GitClientFailure>>>[
              for (
                int i = 0;
                i < 8;
                i++
              ) ...<Future<Result<void, GitClientFailure>>>[
                () {
                  write('file_$i.md', '# $i\n');
                  return client.stage(<String>['file_$i.md']);
                }(),
                client.commit('Add $i'),
              ],
            ];

        final List<Result<void, GitClientFailure>> results = await Future.wait(
          operations,
        );

        expect(results.whereType<Failure<void, GitClientFailure>>(), isEmpty);
        final int records = valueOf(await client.log())
            .split(GitClient.recordSeparator)
            .where((String r) => r.trim().isNotEmpty)
            .length;
        expect(records, 9);
      },
    );
  });

  group('timeout', () {
    test('kills the command and fails with GitClientTimedOut', () async {
      final DartIoGitClientImpl impatient = DartIoGitClientImpl(
        workingDirectory: repoPath,
        timeout: Duration.zero,
      );

      final AppFailure failure = failureOf(await impatient.status());

      expect(failure, isA<GitClientTimedOut>());
      expect((failure as GitClientTimedOut).timeout, Duration.zero);
    });

    test(
      'gives up on pipes a process git left behind is holding open',
      () async {
        // A hook's background child keeps its copy of the pipes after git is
        // killed. The assertion is the clock, because waiting on that child
        // reaches the same failure twenty seconds later.
        final File hook = File('$repoPath/.git/hooks/pre-commit')
          ..writeAsStringSync('#!/bin/sh\nsleep 20 &\nsleep 20\n');
        Process.runSync('chmod', <String>['755', hook.path]);
        write('b.md', '# B\n');
        await client.stage(<String>['b.md']);
        final DartIoGitClientImpl impatient = DartIoGitClientImpl(
          workingDirectory: repoPath,
          timeout: const Duration(milliseconds: 300),
        );

        final Stopwatch waited = Stopwatch()..start();
        final AppFailure failure = failureOf(await impatient.commit('Add B'));

        expect(failure, isA<GitClientTimedOut>());
        expect(waited.elapsed, lessThan(const Duration(seconds: 10)));
      },
      skip: Platform.isWindows
          ? 'the hook is a shell script, and /bin/sh is not there'
          : false,
    );

    test('one timeout does not poison the queue behind it', () async {
      final DartIoGitClientImpl impatient = DartIoGitClientImpl(
        workingDirectory: repoPath,
        timeout: Duration.zero,
      );

      await impatient.status();

      expect(await client.status(), isA<Success<String, GitClientFailure>>());
    });
  });

  group('the command log', () {
    late List<CommandRecord> written;
    late DartIoGitClientImpl logged;

    setUp(() {
      written = <CommandRecord>[];
      logged = DartIoGitClientImpl(
        workingDirectory: repoPath,
        commandLog: _Kept(written),
      );
    });

    test('every command is written down as git ran it', () async {
      write('b.md', '# B\n');
      await logged.stage(<String>['b.md']);
      await logged.commit('Add B');

      expect(
        written.map((CommandRecord it) => it.executable),
        everyElement('git'),
      );
      expect(written.last.arguments, contains('Add B'));
      expect(written.last.exitCode, 0);
      expect(written.last.output, contains('Add B'));
    });

    test('a refusal is written down with its exit code and words', () async {
      // No upstream to count against: git refuses, and says why.
      await logged.upstreamCommitsSince('');

      expect(written.last.exitCode, isNot(0));
      expect(written.last.failed, isTrue);
      expect(written.last.output, isNotEmpty);
    });

    test(
      'an exit the client reads as an answer is written down as one',
      () async {
        // Unset key, no merge, no `origin`: each a non-zero exit and an answer.
        await logged.githubAccount();
        await logged.mergeInProgress();
        await logged.remoteUrl();

        expect(written, hasLength(3));
        expect(
          written.map((CommandRecord it) => it.answered),
          everyElement(isTrue),
        );
        expect(written.any((CommandRecord it) => it.failed), isFalse);
      },
    );

    test('a command killed for its time is written down unfinished', () async {
      await DartIoGitClientImpl(
        workingDirectory: repoPath,
        timeout: Duration.zero,
        commandLog: _Kept(written),
      ).status();

      expect(written.single.exitCode, isNull);
    });
  });

  group('the gate', () {
    late List<CommandRecord> written;
    late _Gate gate;
    late DartIoGitClientImpl gated;

    setUp(() {
      written = <CommandRecord>[];
      gate = _Gate();
      gated = DartIoGitClientImpl(
        workingDirectory: repoPath,
        commandLog: _Kept(written),
        commandGate: gate,
      );
    });

    String porcelain() => '${git(<String>['status', '--porcelain']).stdout}';

    test('is asked before a command runs, by its key and its line', () async {
      write('b.md', '# B\n');

      await gated.stage(<String>['b.md']);

      final CommandRequest asked = gate.plans.single.single;
      expect(asked.key, GitCommandKeyEnum.add.template);
      expect(asked.key, 'git add -- <files>');
      expect(asked.isWrite, isTrue);
      expect(asked.commandLine, "git add -- ':(top,literal)b.md'");
      expect(porcelain(), startsWith('A  b.md'));
    });

    test('a read asks too, and says it only reads', () async {
      await gated.status();

      expect(gate.plans.single.single.key, GitCommandKeyEnum.status.template);
      expect(gate.plans.single.single.isWrite, isFalse);
    });

    test('a refused command never starts, and is nobody\'s error', () async {
      write('b.md', '# B\n');
      gate.allows = (CommandRequest _) => false;

      final AppFailure refused = failureOf(await gated.stage(<String>['b.md']));

      expect(
        refused,
        isA<GitClientCommandDenied>().having(
          (GitClientCommandDenied it) => it.command,
          'command',
          "git add -- ':(top,literal)b.md'",
        ),
      );
      expect(refused.isDenial, isTrue);
      expect(porcelain(), startsWith('?? b.md'), reason: 'nothing was staged');
      expect(written, isEmpty, reason: 'git was never started');
    });

    test('a refused answer-read is a refusal, not the answer', () async {
      gate.allows = (CommandRequest _) => false;

      // Each of these reads a non-zero exit as "there is none".
      expect(failureOf(await gated.head()), isA<GitClientCommandDenied>());
      expect(
        failureOf(await gated.mergeInProgress()),
        isA<GitClientCommandDenied>(),
      );
      expect(
        failureOf(await gated.githubAccount()),
        isA<GitClientCommandDenied>(),
      );
      expect(
        failureOf(await gated.currentBranch()),
        isA<GitClientCommandDenied>(),
      );
      expect(failureOf(await gated.remoteUrl()), isA<GitClientCommandDenied>());
      expect(
        failureOf(await gated.resolves('main')),
        isA<GitClientCommandDenied>(),
      );
    });

    test('the record carries the ticket the gate gave', () async {
      await gated.status();

      expect(written.single.ticket, gate.tickets.single);
    });

    test('the wait is not the command\'s time', () async {
      final _Gate slow = _Gate()..delay = const Duration(milliseconds: 1200);
      final DartIoGitClientImpl hurried = DartIoGitClientImpl(
        workingDirectory: repoPath,
        timeout: const Duration(seconds: 1),
        commandLog: _Kept(written),
        commandGate: slow,
      );

      valueOf(await hurried.status());

      expect(written.single.duration, lessThan(const Duration(seconds: 1)));
    });

    test('discarding everything is one plan of two, in order', () async {
      write('a.md', '# A changed\n');
      git(<String>['add', 'a.md']);

      await gated.discardAll();

      expect(gate.plans.single.map((CommandRequest it) => it.key), <String>[
        'git reset --quiet',
        'git restore --worktree -- :/',
      ]);
      expect(gate.asked, 2);
      expect(porcelain(), isEmpty);
    });

    test('refusing its first command runs neither', () async {
      write('a.md', '# A changed\n');
      git(<String>['add', 'a.md']);
      gate.allows = (CommandRequest _) => false;

      expect(
        failureOf(await gated.discardAll()),
        isA<GitClientCommandDenied>(),
      );
      expect(gate.asked, 1, reason: 'the second is never reached');
      expect(porcelain(), startsWith('M  a.md'));
      expect(written, isEmpty);
    });

    test('refusing its second leaves what the first did', () async {
      write('a.md', '# A changed\n');
      git(<String>['add', 'a.md']);
      gate.allows = (CommandRequest it) =>
          it.key == GitCommandKeyEnum.reset.template;

      expect(
        failureOf(await gated.discardAll()),
        isA<GitClientCommandDenied>(),
      );
      // Unstaged by the reset, and still changed: the restore never ran.
      expect(porcelain(), startsWith(' M a.md'));
      expect(written.single.arguments, <String>['reset', '--quiet']);
    });

    test('a command that fails closes the plan it was in', () async {
      // No such folder: the reset cannot start, so the restore must not wait.
      failureOf(
        await DartIoGitClientImpl(
          workingDirectory: '$base/nowhere',
          commandGate: gate,
        ).discardAll(),
      );

      expect(gate.closed, 1);
      expect(gate.asked, 1, reason: 'the restore was never asked about');
    });

    test('deleting a never-committed file asks HEAD, then is one plan of '
        'two', () async {
      write('b.md', '# B\n');
      git(<String>['add', 'b.md']);

      await gated.deleteUncommitted(<String>['b.md']);

      expect(
        gate.plans.first.single.key,
        GitCommandKeyEnum.committedPaths.template,
      );
      expect(gate.plans.last.map((CommandRequest it) => it.key), <String>[
        'git rm --cached -f --quiet --ignore-unmatch -- <file>',
        'git clean -f -x --quiet -- <file>',
      ]);
      expect(gate.plans, hasLength(2));
      expect(File('$repoPath/b.md').existsSync(), isFalse);
    });

    test('who commits is one question, asked as one plan', () async {
      await gated.identity();

      expect(
        gate.plans.single.map((CommandRequest it) => it.commandLine),
        <String>['git config --get user.name', 'git config --get user.email'],
      );
    });

    test('unstaging and discarding are two keys', () async {
      write('a.md', '# A changed\n');
      git(<String>['add', 'a.md']);

      await gated.unstage(<String>['a.md']);
      await gated.discardUnstaged(<String>['a.md']);

      expect(
        gate.plans.map((List<CommandRequest> it) => it.single.key),
        <String>[
          'git restore --staged -- <files>',
          'git restore --worktree -- <file>',
        ],
      );
    });
  });

  group('the executable', () {
    test(
      'is what is started, and the command is still written as git',
      () async {
        final File script = File('$base/older-git')
          ..writeAsStringSync(
            '#!/bin/sh\n'
            r'if [ "$1" = "--version" ]; then '
            'echo "git version 2.39.2"; exit 0; fi\n'
            r'exec git "$@"'
            '\n',
          );
        Process.runSync('chmod', <String>['+x', script.path]);
        final List<CommandRecord> written = <CommandRecord>[];
        final DartIoGitClientImpl older = DartIoGitClientImpl(
          workingDirectory: repoPath,
          executable: script.path,
          commandLog: _Kept(written),
        );

        expect(valueOf(await older.version()), 'git version 2.39.2');
        // Every other command goes through to the real git.
        expect(valueOf(await older.repositoryRoot()), repoPath);
        expect(written.first.commandLine, 'git --version');
      },
    );

    test('that does not exist is git missing', () async {
      final DartIoGitClientImpl missing = DartIoGitClientImpl(
        workingDirectory: repoPath,
        executable: '$base/no-such-git',
      );

      final Result<String, GitClientFailure> said = await missing.version();

      expect(
        said,
        isA<Failure<String, GitClientFailure>>().having(
          (Failure<String, GitClientFailure> it) => it.failure,
          'failure',
          isA<GitClientExecutableNotFound>(),
        ),
      );
    });
  });

  group('the keys', () {
    test('are each a git command, and no two are the same', () {
      final List<String> templates = GitCommandKeyEnum.values
          .map((GitCommandKeyEnum it) => it.template)
          .toList();

      expect(templates, everyElement(startsWith('git ')));
      expect(templates.toSet(), hasLength(templates.length));
    });

    test('every command that changes something says so', () {
      expect(
        GitCommandKeyEnum.values
            .where((GitCommandKeyEnum it) => !it.isWrite)
            .map((GitCommandKeyEnum it) => it.template.split(' ')[1]),
        everyElement(
          isIn(<String>[
            '--version',
            'rev-parse',
            'status',
            'log',
            'branch',
            'for-each-ref',
            'rev-list',
            'config',
            '-c',
            'merge-base',
            'remote',
            'symbolic-ref',
            'show',
            'ls-tree',
          ]),
        ),
      );
      expect(GitCommandKeyEnum.configLocalSet.isWrite, isTrue);
      expect(GitCommandKeyEnum.clone.isWrite, isTrue);
    });
  });
}

final class _Kept implements CommandLog {
  _Kept(this.records);

  final List<CommandRecord> records;

  @override
  void record(CommandRecord record) => records.add(record);
}

/// A gate that answers by rule and remembers everything it was asked.
final class _Gate implements CommandGate {
  /// What each plan declared, in the order the plans were made.
  final List<List<CommandRequest>> plans = <List<CommandRequest>>[];

  /// The tickets given with each `run`.
  final List<int> tickets = <int>[];

  /// Which commands may run; every one, until a test says otherwise.
  bool Function(CommandRequest request) allows = (CommandRequest _) => true;

  /// How long each verdict is thought about.
  Duration delay = Duration.zero;

  /// How many verdicts were asked for.
  int asked = 0;

  /// How many plans were closed early.
  int closed = 0;

  @override
  CommandPlan plan(List<CommandRequest> commands) {
    plans.add(commands);
    return _Plan(this, commands);
  }
}

final class _Plan implements CommandPlan {
  _Plan(this.gate, this.commands);

  final _Gate gate;
  final List<CommandRequest> commands;
  int _next = 0;

  @override
  Future<CommandVerdict> next() async {
    final CommandRequest request = commands[_next++];
    gate.asked++;
    await Future<void>.delayed(gate.delay);
    if (!gate.allows(request)) {
      return const CommandVerdict.denied();
    }
    gate.tickets.add(100 + gate.tickets.length);
    return CommandVerdict.run(ticket: gate.tickets.last);
  }

  @override
  void close() => gate.closed++;
}
