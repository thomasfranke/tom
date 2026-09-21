/// [GitRepositoryImpl] against a recorded [GitClient].
///
/// Unit, not integration: what this class does is translate — arguments one
/// way, text and failures the other. A real repository would exercise git,
/// which `tom_infra` already covers, and would make it hard to ask what
/// happens when git reports a failure mode this machine cannot produce on
/// demand.
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
    repository = GitRepositoryImpl(client: client);
  });

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T>(Result<T> result) => switch (result) {
    Success<T>(value: final T value) => value,
    Failure<T>(failure: final AppFailure failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  /// What [result] failed with, or a failure of the test if it succeeded.
  AppFailure failureOf<T>(Result<T> result) => switch (result) {
    Success<T>() => throw StateError('expected a failure, got a success'),
    Failure<T>(failure: final AppFailure failure) => failure,
  };

  group('what it asks git for', () {
    test('history sends the path as git spells it', () async {
      await repository.history(
        path: RepoRelativePath('docs/guide.md'),
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
      await repository.stage(<RepoRelativePath>[
        RepoRelativePath('a.md'),
        RepoRelativePath('docs/b.md'),
      ]);

      expect(client.staged, <String>['a.md', 'docs/b.md']);
    });

    test('unstaging unwraps every path', () async {
      await repository.unstage(<RepoRelativePath>[RepoRelativePath('a.md')]);

      expect(client.unstaged, <String>['a.md']);
    });

    test('a branch name crosses as its short form', () async {
      await repository.createBranch(BranchName('feat/rendered-diff'));
      await repository.switchBranch(BranchName('main'));

      expect(client.createdBranch, 'feat/rendered-diff');
      expect(client.switchedTo, 'main');
    });

    test('contentAt names a revision and a path', () async {
      await repository.contentAt(
        revision: 'HEAD~1',
        path: RepoRelativePath('docs/guide.md'),
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

      final GitStatus status = valueOf(await repository.status());

      expect(status.branch, BranchName('main'));
      expect(status.upstream, BranchName('origin/main'));
      expect(status.ahead, 1);
      expect(status.behind, 2);
      expect(status.entries.single.path, RepoRelativePath('docs/guide.md'));
      expect(status.isDetached, isFalse);
    });

    test('history arrives as commits', () async {
      const String separator = GitClient.unitSeparator;
      client.text =
          '${'a' * 40}${separator}Ada${separator}ada@example.com$separator'
          '2026-09-20T01:44:01-03:00${separator}docs: rewrite the intro'
          '${separator}Why: it was long.${GitClient.recordSeparator}';

      final List<Commit> commits = valueOf(await repository.history());

      expect(commits.single.subject, 'docs: rewrite the intro');
      expect(commits.single.author.name, 'Ada');
    });

    test('branches arrive as branches', () async {
      const String separator = GitClient.unitSeparator;
      client.text =
          'main$separator*${separator}origin/main'
          '${GitClient.recordSeparator}'
          'feat/diff$separator $separator${GitClient.recordSeparator}';

      final List<Branch> branches = valueOf(await repository.branches());

      expect(branches.map((Branch branch) => branch.name.value), <String>[
        'main',
        'feat/diff',
      ]);
      expect(branches.first.isCurrent, isTrue);
      expect(branches.last.upstream, isNull);
    });

    test('contentAt hands the file back byte for byte', () async {
      // Not parsed: a document rewritten on the way through would diff
      // against itself, which is the one thing this product cannot do.
      client.text = '# Title\r\n\r\nBody\n\n';

      expect(
        valueOf(
          await repository.contentAt(
            revision: 'HEAD',
            path: RepoRelativePath('a.md'),
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
        const GitNotInstalled(),
      );
    });

    test('a folder outside any repository keeps the path', () async {
      expect(
        await translationOf(const GitClientNotARepository('/tmp/notes')),
        const GitNotARepository('/tmp/notes'),
      );
    });

    test('a merge conflict keeps the conflicted paths', () async {
      expect(
        await translationOf(
          const GitClientMergeConflict(<String>['docs/a.md', 'docs/b.md']),
        ),
        const GitMergeConflict(<String>['docs/a.md', 'docs/b.md']),
      );
    });

    test('authentication drops a stderr no user can act on', () async {
      expect(
        await translationOf(
          const GitClientAuthenticationFailed('fatal: Authentication failed'),
        ),
        const GitAuthenticationFailed(),
      );
    });

    test('a rejected push is its own outcome', () async {
      expect(
        await translationOf(
          const GitClientPushRejected('! [rejected] main -> main'),
        ),
        const GitPushRejected(),
      );
    });

    test('a timeout keeps the command and drops the budget', () async {
      expect(
        await translationOf(
          const GitClientTimedOut('git pull', Duration(minutes: 2)),
        ),
        const GitTimedOut('git pull'),
      );
    });

    test('anything else keeps the command and the stderr', () async {
      expect(
        await translationOf(
          const GitClientCommandFailed('git commit', 1, 'nothing to commit'),
        ),
        const GitCommandFailed('git commit', 'nothing to commit'),
      );
    });

    test('a failure travels out of a command that returns nothing', () async {
      client.failure = const GitClientPushRejected('! [rejected]');

      expect(failureOf(await repository.push()), const GitPushRejected());
    });

    test('a failure from infrastructure never reaches the caller', () async {
      // The point of the translation: no `GitClientFailure` may cross this
      // boundary, or the UI would be switching over a package it is not
      // supposed to know.
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

  Result<T> _answer<T>(String call, T value) {
    calls.add(call);
    final GitClientFailure? pending = failure;
    return pending == null ? Success<T>(value) : Failure<T>(pending);
  }

  @override
  Future<Result<String>> repositoryRoot() async =>
      _answer<String>('repositoryRoot', text);

  @override
  Future<Result<String>> status() async => _answer<String>('status', text);

  @override
  Future<Result<String>> log({String? path, int? limit}) async {
    logPath = path;
    logLimit = limit;
    return _answer<String>('log', text);
  }

  @override
  Future<Result<String>> branches() async => _answer<String>('branches', text);

  @override
  Future<Result<String>> show(String revision, String path) async {
    shownRevision = revision;
    shownPath = path;
    return _answer<String>('show', text);
  }

  @override
  Future<Result<void>> stage(List<String> paths) async {
    staged = paths;
    return _answer<void>('stage', null);
  }

  @override
  Future<Result<void>> unstage(List<String> paths) async {
    unstaged = paths;
    return _answer<void>('unstage', null);
  }

  @override
  Future<Result<void>> commit(String message) async {
    this.message = message;
    return _answer<void>('commit', null);
  }

  @override
  Future<Result<void>> createBranch(String name) async {
    createdBranch = name;
    return _answer<void>('createBranch', null);
  }

  @override
  Future<Result<void>> switchBranch(String name) async {
    switchedTo = name;
    return _answer<void>('switchBranch', null);
  }

  @override
  Future<Result<void>> fetch() async => _answer<void>('fetch', null);

  @override
  Future<Result<void>> pull() async => _answer<void>('pull', null);

  @override
  Future<Result<void>> push() async => _answer<void>('push', null);
}
