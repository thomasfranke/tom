/// [DartIoGitClient] against real repositories created by `git init`.
///
/// Integration, not unit: the contract's whole job is driving the system
/// binary, so a fake would only prove that the fake agrees with itself. This
/// is the project's confidence differentiator, and it runs on all three
/// platforms.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late String base;
  late String repoPath;
  late DartIoGitClient client;

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
    for (final List<String> setting in const <List<String>>[
      <String>['user.name', 'Test'],
      <String>['user.email', 'test@example.com'],
      <String>['commit.gpgsign', 'false'],
      <String>['pull.rebase', 'false'],
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
  String valueOf(Result<String> result) {
    expect(result, isA<Success<String>>(), reason: '$result');
    return (result as Success<String>).value;
  }

  /// The failure of a failed result, failing the test when it is not one.
  AppFailure failureOf(Result<Object?> result) {
    expect(result, isA<Failure<Object?>>(), reason: '$result');
    return (result as Failure<Object?>).failure;
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_git_client_test_');
    // Resolved, because git reports the real path: on macOS the system
    // temporary directory is a symlink, and every comparison below would be
    // against the wrong one of the two names.
    base = tempDir.resolveSymbolicLinksSync();
    repoPath = '$base/repo';
    initRepository(repoPath);
    write('a.md', '# A\n');
    git(<String>['add', 'a.md']);
    git(<String>['commit', '--quiet', '--message', 'Add A']);
    client = DartIoGitClient(workingDirectory: repoPath);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('repositoryRoot', () {
    test('reports the repository itself', () async {
      expect(valueOf(await client.repositoryRoot()), repoPath);
    });

    test('reports the repository from a folder below it', () async {
      Directory('$repoPath/docs/deep').createSync(recursive: true);
      final DartIoGitClient below = DartIoGitClient(
        workingDirectory: '$repoPath/docs/deep',
      );

      expect(valueOf(await below.repositoryRoot()), repoPath);
    });

    test('fails with GitClientNotARepository outside any repository', () async {
      final String outside = '$base/plain';
      Directory(outside).createSync();
      final DartIoGitClient loose = DartIoGitClient(workingDirectory: outside);

      expect(
        failureOf(await loose.repositoryRoot()),
        GitClientNotARepository(outside),
      );
    });

    test(
      'fails with GitClientNotARepository when the folder is gone',
      () async {
        final String gone = '$base/deleted';
        final DartIoGitClient orphan = DartIoGitClient(workingDirectory: gone);

        // The distinction the implementation has to make: a missing folder and
        // a missing binary both arrive as a ProcessException.
        expect(
          failureOf(await orphan.repositoryRoot()),
          GitClientNotARepository(gone),
        );
      },
    );
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

      expect(await client.stage(<String>['b.md']), isA<Success<void>>());
      expect(await client.commit('Add B'), isA<Success<void>>());

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

      expect(await client.unstage(<String>['b.md']), isA<Success<void>>());

      expect(valueOf(await client.status()), contains('? b.md'));
      expect(File('$repoPath/b.md').existsSync(), isTrue);
    });

    test('committing nothing fails with GitClientCommandFailed', () async {
      final AppFailure failure = failureOf(await client.commit('Empty'));

      expect(failure, isA<GitClientCommandFailed>());
      expect((failure as GitClientCommandFailed).command, contains('commit'));
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
      expect(await client.createBranch('draft'), isA<Success<void>>());

      expect(valueOf(await client.status()), contains('# branch.head draft'));
    });

    test('switching moves back', () async {
      await client.createBranch('draft');

      expect(await client.switchBranch('main'), isA<Success<void>>());

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

  group('show', () {
    test('returns the content at a revision, not the working tree', () async {
      write('a.md', '# A changed\n');

      expect(valueOf(await client.show('HEAD', 'a.md')), '# A\n');
    });

    test('a path absent from the revision fails', () async {
      expect(
        failureOf(await client.show('HEAD', 'missing.md')),
        isA<GitClientCommandFailed>(),
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

      expect(await client.push(), isA<Success<void>>());

      final ProcessResult log = git(<String>[
        'log',
        '--oneline',
      ], inside: remotePath);
      expect(log.stdout, contains('Add B'));
    });

    test('fetch reports ahead and behind without touching the tree', () async {
      pushFromElsewhere('# A from elsewhere\n', 'A elsewhere');

      expect(await client.fetch(), isA<Success<void>>());

      expect(valueOf(await client.status()), contains('# branch.ab +0 -1'));
      expect(File('$repoPath/a.md').readAsStringSync(), '# A\n');
    });

    test('pull fast-forwards the working tree', () async {
      pushFromElsewhere('# A from elsewhere\n', 'A elsewhere');

      expect(await client.pull(), isA<Success<void>>());

      expect(File('$repoPath/a.md').readAsStringSync(), '# A from elsewhere\n');
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
  });

  group('the queue', () {
    test(
      'serializes commands that would otherwise race the index lock',
      () async {
        final List<Future<Result<void>>> operations = <Future<Result<void>>>[
          for (int i = 0; i < 8; i++) ...<Future<Result<void>>>[
            () {
              write('file_$i.md', '# $i\n');
              return client.stage(<String>['file_$i.md']);
            }(),
            client.commit('Add $i'),
          ],
        ];

        final List<Result<void>> results = await Future.wait(operations);

        expect(results.whereType<Failure<void>>(), isEmpty);
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
      final DartIoGitClient impatient = DartIoGitClient(
        workingDirectory: repoPath,
        timeout: Duration.zero,
      );

      final AppFailure failure = failureOf(await impatient.status());

      expect(failure, isA<GitClientTimedOut>());
      expect((failure as GitClientTimedOut).timeout, Duration.zero);
    });

    test('one timeout does not poison the queue behind it', () async {
      final DartIoGitClient impatient = DartIoGitClient(
        workingDirectory: repoPath,
        timeout: Duration.zero,
      );

      await impatient.status();

      expect(await client.status(), isA<Success<String>>());
    });
  });
}
