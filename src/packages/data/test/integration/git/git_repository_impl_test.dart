/// [GitRepositoryImpl] over a real [DartIoGitClient] and a real repository.
///
/// The unit test beside this one proves the translation in isolation, with a
/// client that answers whatever it is told to. This one proves the stack
/// agrees with git itself: the text a real `git status` writes, read by the
/// real parser, into the entity the application will switch over. A mismatch
/// between what the capability promises and what the parser expects can only
/// show up here.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late String repoPath;
  late GitRepositoryImpl repository;

  /// Runs git directly, to arrange what the repository is then asked about.
  void git(List<String> arguments, {String? inside}) {
    final ProcessResult result = Process.runSync(
      'git',
      arguments,
      workingDirectory: inside ?? repoPath,
      environment: const <String, String>{'LC_ALL': 'C'},
    );
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
  }

  void write(String relativePath, String content) {
    File('$repoPath/$relativePath')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_git_repository_');
    repoPath = '${tempDir.path}/repo';
    Directory(repoPath).createSync(recursive: true);
    git(<String>['init', '--quiet', '.']);
    // `symbolic-ref` rather than `init --initial-branch`: the latter needs
    // git 2.28, and the tests should not be stricter than the client is.
    git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main']);
    for (final List<String> setting in const <List<String>>[
      <String>['user.name', 'Test'],
      <String>['user.email', 'test@example.com'],
      <String>['commit.gpgsign', 'false'],
    ]) {
      git(<String>['config', ...setting]);
    }
    repository = GitRepositoryImpl(
      client: DartIoGitClient(workingDirectory: repoPath),
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('a repository with nothing in it yet', () {
    test('has an empty history rather than a failure', () async {
      // A space opened on a fresh `git init` is a normal state.
      expect(valueOf(await repository.history()), isEmpty);
    });

    test('reports its branch and a clean tree', () async {
      final GitStatus status = valueOf(await repository.status());

      expect(status.branch, BranchName('main'));
      expect(status.isClean, isTrue);
      expect(status.isDetached, isFalse);
      expect(status.upstream, isNull);
    });
  });

  group('a file the user has not staged', () {
    setUp(() => write('guide.md', '# Guide\n'));

    test('shows up as untracked, unstaged', () async {
      final GitStatus status = valueOf(await repository.status());

      expect(status.isClean, isFalse);
      expect(status.entries.single.path, RepoRelativePath('guide.md'));
      expect(status.entries.single.state, FileStateEnum.untracked);
      expect(status.entries.single.isStaged, isFalse);
      expect(status.hasStagedChanges, isFalse);
    });

    test('is staged as a whole file, and git agrees', () async {
      valueOf(
        await repository.stage(<RepoRelativePath>[
          RepoRelativePath('guide.md'),
        ]),
      );

      final GitStatus status = valueOf(await repository.status());
      expect(status.entries.single.state, FileStateEnum.added);
      expect(status.entries.single.isStaged, isTrue);
      expect(status.hasStagedChanges, isTrue);
    });

    test('unstaging puts it back where it was', () async {
      valueOf(
        await repository.stage(<RepoRelativePath>[
          RepoRelativePath('guide.md'),
        ]),
      );
      valueOf(
        await repository.unstage(<RepoRelativePath>[
          RepoRelativePath('guide.md'),
        ]),
      );

      expect(
        valueOf(await repository.status()).entries.single.state,
        FileStateEnum.untracked,
      );
    });
  });

  group('after a commit', () {
    setUp(() async {
      write('docs/guide.md', '# Guide\n');
      valueOf(
        await repository.stage(<RepoRelativePath>[
          RepoRelativePath('docs/guide.md'),
        ]),
      );
      valueOf(await repository.commit('docs: add the guide'));
    });

    test('the working tree is clean again', () async {
      expect(valueOf(await repository.status()).isClean, isTrue);
    });

    test('the commit is in the history, as an entity', () async {
      final List<Commit> commits = valueOf(await repository.history());

      expect(commits, hasLength(1));
      expect(commits.single.subject, 'docs: add the guide');
      expect(commits.single.body, isEmpty);
      expect(commits.single.author.name, 'Test');
      expect(commits.single.author.email, 'test@example.com');
      expect(commits.single.sha.value, hasLength(40));
    });

    test('the author date keeps the offset git recorded', () async {
      // The reason `CommitDate` exists: a `DateTime` would have applied the
      // offset and thrown it away.
      final CommitDate date = valueOf(await repository.history()).single.date;

      expect(date.utc.isUtc, isTrue);
      expect(
        date.offset,
        DateTime.now().timeZoneOffset,
        reason: 'git records the committer machine offset',
      );
    });

    test('a history narrowed to a path sees only that path', () async {
      write('docs/other.md', '# Other\n');
      valueOf(
        await repository.stage(<RepoRelativePath>[
          RepoRelativePath('docs/other.md'),
        ]),
      );
      valueOf(await repository.commit('docs: add another'));

      final List<Commit> commits = valueOf(
        await repository.history(path: RepoRelativePath('docs/guide.md')),
      );

      expect(commits.map((Commit commit) => commit.subject), <String>[
        'docs: add the guide',
      ]);
    });

    test('a limit caps what comes back, newest first', () async {
      write('docs/other.md', '# Other\n');
      valueOf(
        await repository.stage(<RepoRelativePath>[
          RepoRelativePath('docs/other.md'),
        ]),
      );
      valueOf(await repository.commit('docs: add another'));

      final List<Commit> commits = valueOf(await repository.history(limit: 1));

      expect(commits.single.subject, 'docs: add another');
    });

    test('contentAt reads the file as it was committed', () async {
      write('docs/guide.md', '# Guide\n\nRewritten.\n');

      expect(
        valueOf(
          await repository.contentAt(
            revision: 'HEAD',
            path: RepoRelativePath('docs/guide.md'),
          ),
        ),
        '# Guide\n',
      );
    });
  });

  group('branches', () {
    setUp(() async {
      write('guide.md', '# Guide\n');
      valueOf(
        await repository.stage(<RepoRelativePath>[
          RepoRelativePath('guide.md'),
        ]),
      );
      valueOf(await repository.commit('docs: add the guide'));
    });

    test('listing says which one is current', () async {
      final List<Branch> branches = valueOf(await repository.branches());

      expect(branches.single.name, BranchName('main'));
      expect(branches.single.isCurrent, isTrue);
      expect(branches.single.upstream, isNull);
    });

    test('creating one switches to it, as the product expects', () async {
      valueOf(await repository.createBranch(BranchName('feat/rendered-diff')));

      expect(
        valueOf(await repository.status()).branch,
        BranchName('feat/rendered-diff'),
      );
    });

    test('switching back moves HEAD', () async {
      valueOf(await repository.createBranch(BranchName('feat/rendered-diff')));
      valueOf(await repository.switchBranch(BranchName('main')));

      expect(valueOf(await repository.status()).branch, BranchName('main'));
      expect(valueOf(await repository.branches()), hasLength(2));
    });

    test('a detached HEAD is reported as one', () async {
      git(<String>['checkout', '--quiet', '--detach', 'HEAD']);

      final GitStatus status = valueOf(await repository.status());
      expect(status.isDetached, isTrue);
      expect(status.branch, isNull);
    });
  });

  group('failures come back in the product vocabulary', () {
    /// What [result] failed with, or a failure of the test if it succeeded.
    F failureOf<T, F extends AppFailure>(Result<T, F> result) =>
        switch (result) {
          Success<T, F>() => throw StateError(
            'expected a failure, got a success',
          ),
          Failure<T, F>(failure: final F failure) => failure,
        };

    test('committing nothing fails, without leaking infrastructure', () async {
      final AppFailure failure = failureOf(await repository.commit('nothing'));

      expect(failure, isA<GitFailure>());
      expect(failure, isNot(isA<GitClientFailure>()));
    });

    test('a folder outside any repository names the folder', () async {
      final String outside = '${tempDir.path}/outside';
      Directory(outside).createSync();
      final GitRepositoryImpl elsewhere = GitRepositoryImpl(
        client: DartIoGitClient(workingDirectory: outside),
      );

      expect(
        failureOf(await elsewhere.status()),
        isA<GitNotARepository>().having(
          (GitNotARepository failure) => failure.path,
          'path',
          outside,
        ),
      );
    });

    test(
      'pushing with no remote fails as a command, not a rejection',
      () async {
        // The distinction matters: "the remote moved first" sends the user to
        // pull, and there is no remote to pull from here.
        expect(failureOf(await repository.push()), isA<GitOperationFailed>());
      },
    );
  });
}
