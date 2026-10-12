/// [GitRepositoryImpl] against a recorded [GitClient], because a real git
/// cannot produce every failure mode on demand.
library;

import 'dart:typed_data';

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

    test('bytesAt names a revision and a path, and decodes nothing', () async {
      client.bytes = <int>[0xFF, 0x00, 0x41];

      expect(
        valueOf(
          await repository.bytesAt(
            revision: 'HEAD',
            path: RepoRelativePathValueObject('assets/logo.png'),
          ),
        ),
        <int>[0xFF, 0x00, 0x41],
      );
      expect(client.shownRevision, 'HEAD');
      expect(client.shownPath, 'assets/logo.png');
    });

    test('stagedBytes asks the index, which has no revision', () async {
      client.bytes = <int>[0x61, 0x0A];

      expect(
        valueOf(
          await repository.stagedBytes(RepoRelativePathValueObject('new.txt')),
        ),
        <int>[0x61, 0x0A],
      );
      expect(client.calls, <String>['showStagedBytes']);
      expect(client.shownPath, 'new.txt');
    });

    test('a path the index does not hold is no version, as at HEAD', () async {
      client.failure = const GitClientPathNotInRevision('', 'new.txt');

      expect(
        failureOf(
          await repository.stagedBytes(RepoRelativePathValueObject('new.txt')),
        ),
        isA<GitPathNotInRevision>(),
      );
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

    test('a pull refused over uncommitted work keeps the paths', () async {
      client.failure = const GitClientLocalChangesOverwritten(<String>[
        'docs/a.md',
      ]);

      expect(
        failureOf(await repository.pull()),
        isA<GitLocalChangesOverwritten>().having(
          (GitLocalChangesOverwritten f) => f.paths,
          'paths',
          <String>['docs/a.md'],
        ),
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

    test('a refused command is a refusal, never the fallback', () async {
      final AppFailure refused = await translationOf(
        const GitClientCommandDenied('git push'),
      );

      expect(refused, isA<GitCommandDenied>());
      expect(refused.isDenial, isTrue);
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

  group('the merge state', () {
    test('a repository at rest is no merge and no message', () async {
      client
        ..mergeIsInProgress = false
        ..text = 'a draft nobody should read';

      final MergeStateValueObject state = valueOf(
        await repository.mergeState(),
      );

      expect(state.inProgress, isFalse);
      expect(state.message, isEmpty);
      // The draft is not even asked for: MERGE_HEAD decides, and one round
      // trip is enough to answer.
      expect(client.calls, isNot(contains('mergeMessage')));
    });

    test('a merge in progress carries the draft git wrote', () async {
      client
        ..mergeIsInProgress = true
        ..text = "Merge branch 'main' into feat/rendered-diff\n";

      final MergeStateValueObject state = valueOf(
        await repository.mergeState(),
      );

      expect(state.inProgress, isTrue);
      expect(state.message, "Merge branch 'main' into feat/rendered-diff");
    });

    test('a merge whose draft cannot be read is still a merge', () async {
      client.mergeIsInProgress = true;

      // The client answers everything with this failure once it is set, so
      // mergeInProgress is asked first and answered before it applies.
      final MergeStateValueObject state = valueOf(
        await repository.mergeState(),
      );

      expect(state.inProgress, isTrue);
    });

    test('a failure reading MERGE_HEAD is reported, not swallowed', () async {
      client.failure = const GitClientExecutableNotFound();

      expect(failureOf(await repository.mergeState()), isA<GitNotInstalled>());
    });

    test('aborting asks git to abort', () async {
      await repository.abortMerge();

      expect(client.calls, contains('abortMerge'));
    });

    test('a refused abort comes back in the product vocabulary', () async {
      client.failure = const GitClientExecutableNotFound();

      expect(failureOf(await repository.abortMerge()), isA<GitNotInstalled>());
    });
  });

  group('what a pull request proposes', () {
    test('the base is read as origin has it when origin has it', () async {
      client.existing = <String>{'origin/main'};

      await repository.commitsSince(BranchNameValueObject('main'));
      expect(client.logSince, 'origin/main');

      await repository.changesSince(BranchNameValueObject('main'));
      expect(client.diffBase, 'origin/main');
    });

    test('and as the local branch when origin has none', () async {
      await repository.commitsSince(BranchNameValueObject('main'));

      expect(client.logSince, 'main');
    });

    test('no address and no default branch are nulls, not failures', () async {
      expect(valueOf(await repository.remoteAddress()), isNull);
      expect(valueOf(await repository.defaultBranch()), isNull);
    });

    test('an address and a branch come back as they were printed', () async {
      client.text = 'git@github.com:acme/docs.git';
      expect(
        valueOf(await repository.remoteAddress()),
        'git@github.com:acme/docs.git',
      );

      client.text = 'main';
      expect(
        valueOf(await repository.defaultBranch()),
        BranchNameValueObject('main'),
      );
    });

    test('a fork point that is no sha is no shared history', () async {
      expect(
        valueOf(await repository.forkPoint(BranchNameValueObject('main'))),
        isNull,
      );

      client.forkPoint = 'c' * 40;
      expect(
        valueOf(await repository.forkPoint(BranchNameValueObject('main'))),
        CommitShaValueObject('c' * 40),
      );
    });

    test('a failure on the way is git’s failure, translated', () async {
      client.failure = const GitClientTimedOut('git', Duration.zero);

      expect(
        failureOf(await repository.changesSince(BranchNameValueObject('main'))),
        isA<GitTimedOut>(),
      );
    });
  });

  group('what a pull brought', () {
    test('head is the sha git printed', () async {
      client.text = 'a' * 40;

      expect(valueOf(await repository.head()), CommitShaValueObject('a' * 40));
    });

    test('head before the first commit is null', () async {
      client.text = '';

      expect(valueOf(await repository.head()), isNull);
    });

    test('counts against the sha, or everything without one', () async {
      client.upstreamCount = 3;

      expect(
        valueOf(
          await repository.upstreamCommitsSince(CommitShaValueObject('b' * 40)),
        ),
        3,
      );
      expect(client.countedSince, 'b' * 40);

      await repository.upstreamCommitsSince(null);
      expect(client.countedSince, '');
    });
  });

  group('publishing and the git directory', () {
    test('publish sends the branch as git spells it', () async {
      await repository.publish(BranchNameValueObject('feat/notes'));

      expect(client.published, 'feat/notes');
    });

    test('a publish with no remote is GitNoRemote', () async {
      client.failure = const GitClientNoRemote('no origin');

      expect(
        failureOf(await repository.publish(BranchNameValueObject('main'))),
        isA<GitNoRemote>(),
      );
    });

    test('the git directory is passed through', () async {
      client.text = '/code/app/.git';

      expect(valueOf(await repository.gitDirectory()), '/code/app/.git');
    });
  });

  group('the clone vocabulary', () {
    test('an address with nothing there is GitRemoteNotFound', () async {
      client.failure = const GitClientRemoteNotFound('does not exist');

      expect(failureOf(await repository.pull()), isA<GitRemoteNotFound>());
    });

    test('a taken folder keeps its path', () async {
      client.failure = const GitClientDestinationTaken('/tmp/docs');

      final GitFailure failure = failureOf(await repository.pull());

      expect(failure, isA<GitCloneDestinationTaken>());
      expect((failure as GitCloneDestinationTaken).path, '/tmp/docs');
    });
  });

  group('discarding everything', () {
    test('asks the client to put the tracked files back', () async {
      // `HEAD` names a commit: before the first one nothing is put back.
      client.text = 'c' * 40;

      await repository.discardAll();

      expect(client.calls, contains('discardAll'));
    });

    test('before the first commit it asks for nothing to be written', () async {
      client.text = '';

      expect(failureOf(await repository.discardAll()), isA<GitNoCommitsYet>());
      expect(client.calls, isNot(contains('discardAll')));
    });

    test('a refusal comes back in the product vocabulary', () async {
      client.failure = const GitClientExecutableNotFound();

      expect(failureOf(await repository.discardAll()), isA<GitNotInstalled>());
    });
  });

  group('discarding one row', () {
    final List<RepoRelativePathValueObject> paths =
        <RepoRelativePathValueObject>[
          RepoRelativePathValueObject('docs/new.md'),
          RepoRelativePathValueObject('docs/old.md'),
        ];

    test('each kind reaches its own command, with every path', () async {
      for (final (DiscardKindEnum kind, String call)
          in const <(DiscardKindEnum, String)>[
            (DiscardKindEnum.toStaged, 'discardUnstaged'),
            (DiscardKindEnum.toLastCommit, 'discardSinceCommit'),
            (DiscardKindEnum.delete, 'deleteUncommitted'),
          ]) {
        await repository.discard(kind, paths);

        expect(client.calls.last, call);
        expect(client.discarded, <String>['docs/new.md', 'docs/old.md']);
      }
    });

    test('a file that turned out committed keeps its name', () async {
      client.failure = const GitClientPathCommitted(<String>['docs/old.md']);

      expect(
        failureOf(await repository.discard(DiscardKindEnum.delete, paths)),
        isA<GitPathCommitted>().having(
          (GitPathCommitted f) => f.paths,
          'paths',
          <String>['docs/old.md'],
        ),
      );
    });

    test('a refusal comes back in the product vocabulary', () async {
      client.failure = const GitClientExecutableNotFound();

      expect(
        failureOf(await repository.discard(DiscardKindEnum.delete, paths)),
        isA<GitNotInstalled>(),
      );
    });
  });

  group('the branch a branch came from', () {
    test('a recorded base reads back as a name', () async {
      await repository.recordBase(
        BranchNameValueObject('feat/notes'),
        BranchNameValueObject('develop'),
      );

      expect(client.recordedBases, <String, String>{'feat/notes': 'develop'});
      expect(
        valueOf(
          await repository.recordedBase(BranchNameValueObject('feat/notes')),
        ),
        BranchNameValueObject('develop'),
      );
    });

    test('nothing recorded is null, not a failure', () async {
      expect(
        valueOf(await repository.recordedBase(BranchNameValueObject('main'))),
        isNull,
      );
    });

    test('a standing shares history unless HEAD is all ahead of it', () async {
      client
        ..headCommits = 3
        ..text = <String>[
          <String>['refs/heads/main', '', '0 2'].join(GitClient.unitSeparator),
          <String>[
            'refs/heads/gh-pages',
            '',
            '4 3',
          ].join(GitClient.unitSeparator),
        ].map((String r) => '$r${GitClient.recordSeparator}\n').join();

      final List<BranchStandingValueObject> standings = valueOf(
        await repository.standings(),
      );

      expect(
        standings.map((BranchStandingValueObject it) => it.sharesHistory),
        <bool>[true, false],
      );
    });

    test('a refusal comes back in the product vocabulary', () async {
      client.failure = const GitClientExecutableNotFound();

      expect(failureOf(await repository.standings()), isA<GitNotInstalled>());
      expect(
        failureOf(
          await repository.recordBase(
            BranchNameValueObject('a'),
            BranchNameValueObject('b'),
          ),
        ),
        isA<GitNotInstalled>(),
      );
    });
  });

  group('who commits, and which account is used here', () {
    test('both halves of the identity come back trimmed', () async {
      client.text = 'Ada Lovelace${GitClient.unitSeparator}ada@example.com\n';

      expect(
        valueOf(await repository.commitIdentity()),
        const CommitIdentityValueObject(
          name: 'Ada Lovelace',
          email: 'ada@example.com',
        ),
      );
    });

    test('a half git has nothing for is unset, not empty', () async {
      client.text = GitClient.unitSeparator;

      final CommitIdentityValueObject identity = valueOf(
        await repository.commitIdentity(),
      );

      expect(identity.name, isNull);
      expect(identity.email, isNull);
      expect(identity.isIncomplete, isTrue);
    });

    test('a chosen account reads back, and none is null', () async {
      expect(valueOf(await repository.chosenAccount()), isNull);

      await repository.chooseAccount('octocat');

      expect(valueOf(await repository.chosenAccount()), 'octocat');
    });
  });
}

/// A [GitClient] that records what it was asked and answers what it was told
/// to.
final class _RecordingGitClient implements GitClient {
  /// What every reading command returns while [failure] is null.
  String text = '';

  /// What the two byte-level reads return while [failure] is null.
  List<int> bytes = <int>[];

  /// What every command fails with, or null to succeed.
  GitClientFailure? failure;

  /// What `MERGE_HEAD` is taken to say.
  bool mergeIsInProgress = false;

  final List<String> calls = <String>[];
  String? logPath;
  int? logLimit;
  String? logSince;
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
  Future<Result<String, GitClientFailure>> version() async =>
      _answer<String>('version', text);

  @override
  Future<Result<String, GitClientFailure>> status() async =>
      _answer<String>('status', text);

  @override
  Future<Result<String, GitClientFailure>> log({
    String? path,
    int? limit,
    String? since,
  }) async {
    logPath = path;
    logLimit = limit;
    logSince = since;
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
  Future<Result<Uint8List, GitClientFailure>> showBytes(
    String revision,
    String path,
  ) async {
    shownRevision = revision;
    shownPath = path;
    return _answer<Uint8List>('showBytes', Uint8List.fromList(bytes));
  }

  @override
  Future<Result<Uint8List, GitClientFailure>> showStagedBytes(
    String path,
  ) async {
    shownPath = path;
    return _answer<Uint8List>('showStagedBytes', Uint8List.fromList(bytes));
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

  @override
  Future<Result<bool, GitClientFailure>> mergeInProgress() async =>
      _answer<bool>('mergeInProgress', mergeIsInProgress);

  @override
  Future<Result<String, GitClientFailure>> mergeMessage() async =>
      _answer<String>('mergeMessage', text);

  @override
  Future<Result<void, GitClientFailure>> abortMerge() async =>
      _answer<void>('abortMerge', null);

  @override
  Future<Result<void, GitClientFailure>> discardAll() async =>
      _answer<void>('discardAll', null);

  /// The paths the last discard of one row was asked for.
  List<String>? discarded;

  @override
  Future<Result<void, GitClientFailure>> discardUnstaged(
    List<String> paths,
  ) async {
    discarded = paths;
    return _answer<void>('discardUnstaged', null);
  }

  @override
  Future<Result<void, GitClientFailure>> discardSinceCommit(
    List<String> paths,
  ) async {
    discarded = paths;
    return _answer<void>('discardSinceCommit', null);
  }

  @override
  Future<Result<void, GitClientFailure>> deleteUncommitted(
    List<String> paths,
  ) async {
    discarded = paths;
    return _answer<void>('deleteUncommitted', null);
  }

  /// What `diff --numstat` prints, apart from [text] because a proposal
  /// reads both diffs in one call.
  String numstat = '';

  /// What `diff --name-status` prints.
  String nameStatus = '';

  /// The base both diffs were asked against.
  String? diffBase;

  @override
  Future<Result<String, GitClientFailure>> diffNumstat(String base) async {
    diffBase = base;
    return _answer<String>('diffNumstat', numstat);
  }

  @override
  Future<Result<String, GitClientFailure>> diffNameStatus(String base) async {
    diffBase = base;
    return _answer<String>('diffNameStatus', nameStatus);
  }

  /// What `merge-base` answers.
  String forkPoint = '';

  @override
  Future<Result<String, GitClientFailure>> mergeBase(String revision) async =>
      _answer<String>('mergeBase', forkPoint);

  /// The revisions [resolves] says exist.
  Set<String> existing = <String>{};

  @override
  Future<Result<bool, GitClientFailure>> resolves(String revision) async =>
      _answer<bool>('resolves', existing.contains(revision));

  @override
  Future<Result<String, GitClientFailure>> remoteUrl() async =>
      _answer<String>('remoteUrl', text);

  @override
  Future<Result<String, GitClientFailure>> defaultBranch() async =>
      _answer<String>('defaultBranch', text);

  @override
  Future<Result<String, GitClientFailure>> currentBranch() async =>
      _answer<String>('currentBranch', text);

  /// What [upstreamCommitsSince] counts, and what it was asked about.
  int upstreamCount = 0;
  String? countedSince;

  /// The branch [publish] was handed.
  String? published;

  @override
  Future<Result<void, GitClientFailure>> clone(
    String url, {
    void Function(String line)? onProgress,
  }) async => _answer<void>('clone', null);

  @override
  Future<Result<String, GitClientFailure>> head() async =>
      _answer<String>('head', text);

  @override
  Future<Result<int, GitClientFailure>> upstreamCommitsSince(
    String since,
  ) async {
    countedSince = since;
    return _answer<int>('upstreamCommitsSince', upstreamCount);
  }

  @override
  Future<Result<void, GitClientFailure>> publish(String branch) async {
    published = branch;
    return _answer<void>('publish', null);
  }

  @override
  Future<Result<String, GitClientFailure>> gitDirectory() async =>
      _answer<String>('gitDirectory', text);

  /// How many commits [commitCount] says `HEAD` has.
  int headCommits = 0;

  /// What [recordBranchBase] was handed, as `branch → base`.
  final Map<String, String> recordedBases = <String, String>{};

  @override
  Future<Result<String, GitClientFailure>> branchStandings() async =>
      _answer<String>('branchStandings', text);

  @override
  Future<Result<int, GitClientFailure>> commitCount() async =>
      _answer<int>('commitCount', headCommits);

  @override
  Future<Result<String, GitClientFailure>> branchBase(String branch) async =>
      _answer<String>('branchBase', recordedBases[branch] ?? '');

  @override
  Future<Result<void, GitClientFailure>> recordBranchBase(
    String branch,
    String base,
  ) async {
    recordedBases[branch] = base;
    return _answer<void>('recordBranchBase', null);
  }

  /// What [recordGithubAccount] was last handed.
  String recordedAccount = '';

  @override
  Future<Result<String, GitClientFailure>> identity() async =>
      _answer<String>('identity', text);

  @override
  Future<Result<String, GitClientFailure>> githubAccount() async =>
      _answer<String>('githubAccount', recordedAccount);

  @override
  Future<Result<void, GitClientFailure>> recordGithubAccount(
    String login,
  ) async {
    recordedAccount = login;
    return _answer<void>('recordGithubAccount', null);
  }
}
