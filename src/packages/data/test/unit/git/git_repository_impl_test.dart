/// [GitRepositoryImpl] against a recorded [GitClient], because a real git
/// cannot produce every failure mode on demand.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _RecordingGitClient client;
  late GitRepositoryImpl repository;

  setUp(() {
    client = _RecordingGitClient();
    repository = GitRepositoryImpl(git: GitDataSource(client: client));
  });

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  /// What [result] failed with, or a failure of the test if it succeeded.
  F failureOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>() => throw StateError('expected a failure, got a success'),
    Failure<T, F>(failure: final F failure) => failure,
  };

  group('what it asks git for', () {
    test('history sends the path as git spells it', () async {
      await repository.history(
        path: RepoRelativePathValueObject('docs/guide.md'),
        limit: 20,
      );

      expect(client.logPath, 'docs/guide.md');
      expect(client.logLimit, 20);
    });

    test('history with no path asks for the whole branch', () async {
      await repository.history();

      expect(client.logPath, isNull);
      expect(client.logLimit, isNull);
    });

    test('staging unwraps every path', () async {
      await repository.stage(<RepoRelativePathValueObject>[
        RepoRelativePathValueObject('a.md'),
        RepoRelativePathValueObject('docs/b.md'),
      ]);

      expect(client.staged, <String>['a.md', 'docs/b.md']);
    });

    test('unstaging unwraps every path', () async {
      await repository.unstage(<RepoRelativePathValueObject>[
        RepoRelativePathValueObject('a.md'),
      ]);

      expect(client.unstaged, <String>['a.md']);
    });

    test('a branch name crosses as its short form', () async {
      await repository.createBranch(
        BranchNameValueObject('feat/rendered-diff'),
      );
      await repository.switchBranch(BranchNameValueObject('main'));

      expect(client.createdBranch, 'feat/rendered-diff');
      expect(client.switchedTo, 'main');
    });

    test('contentAt names a revision and a path', () async {
      await repository.contentAt(
        revision: 'HEAD~1',
        path: RepoRelativePathValueObject('docs/guide.md'),
      );

      expect(client.shownRevision, 'HEAD~1');
      expect(client.shownPath, 'docs/guide.md');
    });

    test('a message crosses untouched', () async {
      await repository.commit('docs: rewrite the intro\n\nWhy: it was long.');

      expect(client.message, 'docs: rewrite the intro\n\nWhy: it was long.');
    });

    test('the commands that take nothing reach git', () async {
      await repository.fetch();
      await repository.pull();
      await repository.push();

      expect(client.calls, containsAll(<String>['fetch', 'pull', 'push']));
    });
  });

  group('what it gives back', () {
    test('status arrives as an entity, not as text', () async {
      client.text =
          '# branch.oid abc123${GitClient.nulSeparator}'
          '# branch.head main${GitClient.nulSeparator}'
          '# branch.upstream origin/main${GitClient.nulSeparator}'
          '# branch.ab +1 -2${GitClient.nulSeparator}'
          '1 .M N... 100644 100644 100644 aaa bbb docs/guide.md'
          '${GitClient.nulSeparator}';

      final GitStatusValueObject status = valueOf(await repository.status());

      expect(status.branch, BranchNameValueObject('main'));
      expect(status.upstream, BranchNameValueObject('origin/main'));
      expect(status.ahead, 1);
      expect(status.behind, 2);
      expect(
        status.entries.single.path,
        RepoRelativePathValueObject('docs/guide.md'),
      );
      expect(status.isDetached, isFalse);
    });

    test('history arrives as commits', () async {
      const String separator = GitClient.unitSeparator;
      client.text =
          '${'a' * 40}${separator}Ada${separator}ada@example.com$separator'
          '2026-09-20T01:44:01-03:00${separator}docs: rewrite the intro'
          '${separator}Why: it was long.${GitClient.recordSeparator}';

      final List<CommitEntity> commits = valueOf(await repository.history());

      expect(commits.single.subject, 'docs: rewrite the intro');
      expect(commits.single.author.name, 'Ada');
    });

    test('branches arrive as branches', () async {
      const String separator = GitClient.unitSeparator;
      client.text =
          'main$separator*${separator}origin/main'
          '${GitClient.recordSeparator}'
          'feat/diff$separator $separator${GitClient.recordSeparator}';

      final List<BranchEntity> branches = valueOf(await repository.branches());

      expect(branches.map((BranchEntity branch) => branch.name.value), <String>[
        'main',
        'feat/diff',
      ]);
      expect(branches.first.isCurrent, isTrue);
      expect(branches.last.upstream, isNull);
    });

    test('contentAt hands the file back byte for byte', () async {
      client.text = '# Title\r\n\r\nBody\n\n';

      expect(
        valueOf(
          await repository.contentAt(
            revision: 'HEAD',
            path: RepoRelativePathValueObject('a.md'),
          ),
        ),
        '# Title\r\n\r\nBody\n\n',
      );
    });

    test('an empty history is a state, not a failure', () async {
      client.text = '';

      expect(valueOf(await repository.history()), isEmpty);
    });
  });

  group('translation of failures', () {
    /// The repository's answer to a client that failed with [failure].
    Future<AppFailure> translationOf(GitClientFailure failure) async {
      client.failure = failure;
      return failureOf(await repository.status());
    }

    test('no git on the machine', () async {
      expect(
        await translationOf(const GitClientExecutableNotFound()),
        isA<GitNotInstalled>(),
      );
    });

    test('a folder outside any repository keeps the path', () async {
      expect(
        await translationOf(const GitClientNotARepository('/tmp/notes')),
        isA<GitNotARepository>().having(
          (GitNotARepository f) => f.path,
          'path',
          '/tmp/notes',
        ),
      );
    });

    test('a merge conflict keeps the conflicted paths', () async {
      expect(
        await translationOf(
          const GitClientMergeConflict(<String>['docs/a.md', 'docs/b.md']),
        ),
        isA<GitMergeConflict>().having(
          (GitMergeConflict f) => f.conflictedFiles,
          'conflictedFiles',
          <String>['docs/a.md', 'docs/b.md'],
        ),
      );
    });

    test('authentication is a named outcome', () async {
      expect(
        await translationOf(
          const GitClientAuthenticationFailed('fatal: Authentication failed'),
        ),
        isA<GitAuthenticationFailed>(),
      );
    });

    test('a rejected push is its own outcome', () async {
      expect(
        await translationOf(
          const GitClientPushRejected('! [rejected] main -> main'),
        ),
        isA<GitPushRejected>(),
      );
    });

    test('a timeout is named and carries no command line', () async {
      expect(
        await translationOf(
          const GitClientTimedOut('git pull', Duration(minutes: 2)),
        ),
        isA<GitTimedOut>(),
      );
    });

    test('anything else lands on the fallback', () async {
      expect(
        await translationOf(
          const GitClientCommandFailed('git commit', 1, 'nothing to commit'),
        ),
        isA<GitOperationFailed>(),
      );
    });

    test('the machine\'s words travel as the cause, never in the '
        'variant', () async {
      const GitClientCommandFailed reported = GitClientCommandFailed(
        'git commit',
        1,
        'nothing to commit',
      );

      final AppFailure failure = await translationOf(reported);

      expect(failure.cause, same(reported));
      expect(failure.chain, hasLength(2));
      expect(failure.diagnostics, contains('nothing to commit'));
      // Equality against one built from the cause alone fails the moment a
      // field is added back.
      expect(failure, const GitOperationFailed(cause: reported));
    });

    test('a failure travels out of a command that returns nothing', () async {
      client.failure = const GitClientPushRejected('! [rejected]');

      expect(failureOf(await repository.push()), isA<GitPushRejected>());
    });

    test('a failure from infrastructure never reaches the caller', () async {
      expect(
        await translationOf(const GitClientExecutableNotFound()),
        isNot(isA<GitClientFailure>()),
      );
    });
  });
}

/// A [GitClient] that records what it was asked and answers what it was told
/// to.
final class _RecordingGitClient implements GitClient {
  /// What every reading command returns while [failure] is null.
  String text = '';

  /// What every command fails with, or null to succeed.
  GitClientFailure? failure;

  final List<String> calls = <String>[];
  String? logPath;
  int? logLimit;
  List<String>? staged;
  List<String>? unstaged;
  String? message;
  String? createdBranch;
  String? switchedTo;
  String? shownRevision;
  String? shownPath;

  Result<T, GitClientFailure> _answer<T>(String call, T value) {
    calls.add(call);
    final GitClientFailure? pending = failure;
    return pending == null
        ? Success<T, GitClientFailure>(value)
        : Failure<T, GitClientFailure>(pending);
  }

  @override
  Future<Result<String, GitClientFailure>> repositoryRoot() async =>
      _answer<String>('repositoryRoot', text);

  @override
  Future<Result<String, GitClientFailure>> status() async =>
      _answer<String>('status', text);

  @override
  Future<Result<String, GitClientFailure>> log({
    String? path,
    int? limit,
  }) async {
    logPath = path;
    logLimit = limit;
    return _answer<String>('log', text);
  }

  @override
  Future<Result<String, GitClientFailure>> branches() async =>
      _answer<String>('branches', text);

  @override
  Future<Result<String, GitClientFailure>> show(
    String revision,
    String path,
  ) async {
    shownRevision = revision;
    shownPath = path;
    return _answer<String>('show', text);
  }

  @override
  Future<Result<void, GitClientFailure>> stage(List<String> paths) async {
    staged = paths;
    return _answer<void>('stage', null);
  }

  @override
  Future<Result<void, GitClientFailure>> unstage(List<String> paths) async {
    unstaged = paths;
    return _answer<void>('unstage', null);
  }

  @override
  Future<Result<void, GitClientFailure>> commit(String message) async {
    this.message = message;
    return _answer<void>('commit', null);
  }

  @override
  Future<Result<void, GitClientFailure>> createBranch(String name) async {
    createdBranch = name;
    return _answer<void>('createBranch', null);
  }

  @override
  Future<Result<void, GitClientFailure>> switchBranch(String name) async {
    switchedTo = name;
    return _answer<void>('switchBranch', null);
  }

  @override
  Future<Result<void, GitClientFailure>> fetch() async =>
      _answer<void>('fetch', null);

  @override
  Future<Result<void, GitClientFailure>> pull() async =>
      _answer<void>('pull', null);

  @override
  Future<Result<void, GitClientFailure>> push() async =>
      _answer<void>('push', null);
}
