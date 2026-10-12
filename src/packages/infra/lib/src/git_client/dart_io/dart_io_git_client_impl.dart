/// The `dart:io` implementation of [GitClient].
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// What starts a process: [Process.start] in production, a scripted process
/// in a unit test, so the client's own logic is proved without a real git.
typedef GitProcessStarter =
    Future<Process> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
      Map<String, String>? environment,
    });

/// Drives the system's `git` binary through [Process].
///
/// The user's own git, so credentials, SSH and config come for free
/// ([Decision
/// 2](../../../../../../../docs/technical/decisions/002-git-via-system-binary.md)).
/// One instance per space; git 2.23 or newer for `switch` and `restore`.
final class DartIoGitClientImpl implements GitClient {
  /// Creates a client running git inside [workingDirectory], which may sit
  /// below the repository root — see [_pathspec].
  ///
  /// [timeout] bounds a local command, [networkTimeout] one that reaches a
  /// remote; a hung command would stall the whole queue, not one action.
  DartIoGitClientImpl({
    required this.workingDirectory,
    this.timeout = const Duration(seconds: 30),
    this.networkTimeout = const Duration(minutes: 2),
    this.commandLog = const SilentCommandLogImpl(),
    this.commandGate = const OpenCommandGateImpl(),
    this.executable = 'git',
    this.environment = const <String, String>{},
    this.startProcess = Process.start,
  });

  /// What starts git; only a unit test hands a different one.
  final GitProcessStarter startProcess;

  /// The folder every command runs inside.
  final String workingDirectory;

  /// Variables added on top of the ones git is always run with — how a test
  /// keeps the developer's own git configuration out of a run.
  final Map<String, String> environment;

  /// What is started to run git: a name found on the `PATH`, or a path.
  ///
  /// Commands are still written down as `git …`, whatever this is.
  final String executable;

  /// Where every command is written down once it ends.
  final CommandLog commandLog;

  /// What says whether a command may start, asked before every one of them
  /// ([Decision 38](../../../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
  final CommandGate commandGate;

  /// How long a local command may take before it is killed.
  final Duration timeout;

  /// How long a command reaching a remote may take before it is killed.
  final Duration networkTimeout;

  /// The tail of each folder's serialized queue.
  ///
  /// Every operation chains onto it, so two commands cannot race for the
  /// index lock — and the queue is the folder's, not the instance's, because
  /// two clients over one folder meet at the same `index.lock`.
  static final Map<String, Future<void>> _tails = <String, Future<void>>{};

  /// Bytes to text, tolerating anything that is not valid UTF-8, so an odd
  /// file cannot throw across the boundary.
  static const Utf8Decoder _decoder = Utf8Decoder(allowMalformed: true);

  /// How long a killed process's pipes are given to close.
  ///
  /// A grandchild that inherited the pipe holds it open for as long as it
  /// lives and `dart:io` cannot kill a process group, so waiting unbounded
  /// would hang the queue the timeout exists to protect.
  static const Duration _drainGrace = Duration(seconds: 2);

  /// The `--format` of [log] and of [branches], spelling out the fields the
  /// contract promises.
  static final String _logFormat =
      <String>[
        '%H',
        '%an',
        '%ae',
        '%aI',
        '%s',
        '%b',
      ].join(GitClient.unitSeparator) +
      GitClient.recordSeparator;

  static final String _branchFormat =
      <String>[
        '%(refname:short)',
        '%(HEAD)',
        '%(upstream:short)',
      ].join(GitClient.unitSeparator) +
      GitClient.recordSeparator;

  static final String _standingFormat =
      <String>[
        '%(refname)',
        '%(symref)',
        '%(ahead-behind:HEAD)',
      ].join(GitClient.unitSeparator) +
      GitClient.recordSeparator;

  @override
  Future<Result<String, GitClientFailure>> version() async {
    final Result<String, GitClientFailure> said = await _git(
      GitCommandKeyEnum.version,
      <String>['--version'],
    );
    return switch (said) {
      Success<String, GitClientFailure>(:final String value) =>
        Success<String, GitClientFailure>(value.trim()),
      Failure<String, GitClientFailure>() => said,
    };
  }

  @override
  Future<Result<String, GitClientFailure>> repositoryRoot() async {
    final Result<String, GitClientFailure> root = await _git(
      GitCommandKeyEnum.repositoryRoot,
      <String>['rev-parse', '--show-toplevel'],
    );
    return switch (root) {
      Success<String, GitClientFailure>(:final String value) =>
        Success<String, GitClientFailure>(value.trim()),
      Failure<String, GitClientFailure>() => root,
    };
  }

  @override
  Future<Result<void, GitClientFailure>> clone(
    String url, {
    void Function(String line)? onProgress,
  }) async {
    final String destination = Directory(workingDirectory).absolute.path;
    // A pasted address is somebody else's text: `ext::` runs a command, so
    // it is refused whatever the user's config allows, and `--` keeps an
    // address that starts with `-` from reading as an option.
    final List<String> arguments = <String>[
      '-c',
      'protocol.ext.allow=never',
      'clone',
      '--progress',
      '--',
      url,
      destination,
    ];
    final Result<String, GitClientFailure> result = await _asked(
      GitCommandKeyEnum.clone,
      arguments,
      (int? ticket) => _enqueue(
        () => _run(
          arguments,
          networkTimeout,
          insideFolder: false,
          onLine: onProgress ?? (String _) {},
          ticket: ticket,
        ),
      ),
    );
    return switch (result) {
      Success<String, GitClientFailure>() =>
        const Success<void, GitClientFailure>(null),
      Failure<String, GitClientFailure>(:final GitClientFailure failure) =>
        Failure<void, GitClientFailure>(_asCloneFailure(failure, destination)),
    };
  }

  /// [failure] in a clone's terms: git words a wrong address as it words a
  /// missing remote, and a taken folder as nothing in particular.
  static GitClientFailure _asCloneFailure(
    GitClientFailure failure,
    String destination,
  ) => switch (failure) {
    GitClientCommandFailed(:final String stderr)
        when _destinationTaken.hasMatch(stderr) =>
      GitClientDestinationTaken(destination, cause: failure),
    GitClientCommandFailed(:final String stderr) ||
    GitClientNoRemote(:final String stderr)
        when _notCloneable.hasMatch(stderr) =>
      GitClientRemoteNotFound(stderr, cause: failure),
    _ => failure,
  };

  @override
  Future<Result<String, GitClientFailure>> status() =>
      _git(GitCommandKeyEnum.status, <String>[
        'status',
        '--porcelain=v2',
        '--branch',
        '--untracked-files=all',
        '-z',
      ]);

  @override
  Future<Result<String, GitClientFailure>> log({
    String? path,
    int? limit,
    String? since,
  }) async {
    final Result<String, GitClientFailure> result = await _git(
      GitCommandKeyEnum.log,
      <String>[
        'log',
        '--format=$_logFormat',
        // A document's history goes on across its renames: it is the same
        // document under another name.
        if (path != null) '--follow',
        if (limit != null) '--max-count=$limit',
        if (since != null) '$since..HEAD',
        if (path != null) ...<String>['--', _pathspec(path)],
      ],
    );
    // An unborn branch has an empty history, which is a state and not an
    // error; calling it fatal is git's convention, not the product's.
    return switch (result) {
      Failure<String, GitClientFailure>(
        failure: GitClientCommandFailed(:final String stderr),
      )
          when _unbornHead.hasMatch(stderr) =>
        const Success<String, GitClientFailure>(''),
      _ => result,
    };
  }

  @override
  Future<Result<String, GitClientFailure>> branches() => _git(
    GitCommandKeyEnum.branches,
    <String>['branch', '--format=$_branchFormat'],
  );

  @override
  Future<Result<String, GitClientFailure>> branchStandings() async {
    final Result<String, GitClientFailure> result = await _git(
      GitCommandKeyEnum.branchStandings,
      <String>[
        'for-each-ref',
        '--format=$_standingFormat',
        'refs/heads',
        'refs/remotes',
      ],
    );
    // An unborn `HEAD` is nothing to stand against, which is an answer.
    return switch (result) {
      Failure<String, GitClientFailure>(
        failure: GitClientCommandFailed(:final String stderr),
      )
          when _headNotFound.hasMatch(stderr) =>
        const Success<String, GitClientFailure>(''),
      _ => result,
    };
  }

  @override
  Future<Result<int, GitClientFailure>> commitCount() async {
    final Result<String, GitClientFailure> head = await this.head();
    if (head case Success<String, GitClientFailure>(value: '')) {
      return const Success<int, GitClientFailure>(0);
    }
    if (head case Failure<String, GitClientFailure>(
      :final GitClientFailure failure,
    )) {
      return Failure<int, GitClientFailure>(failure);
    }
    final Result<String, GitClientFailure> result = await _git(
      GitCommandKeyEnum.commitCount,
      <String>['rev-list', '--count', 'HEAD'],
    );
    return switch (result) {
      Success<String, GitClientFailure>(:final String value) =>
        switch (int.tryParse(value.trim())) {
          final int count => Success<int, GitClientFailure>(count),
          null => Failure<int, GitClientFailure>(
            GitClientCommandFailed('git rev-list --count HEAD', 0, value),
          ),
        },
      Failure<String, GitClientFailure>(:final GitClientFailure failure) =>
        Failure<int, GitClientFailure>(failure),
    };
  }

  @override
  Future<Result<String, GitClientFailure>> identity() async {
    // Two reads that are one question, so they are one plan.
    final CommandPlan plan = commandGate.plan(<CommandRequest>[
      _request(GitCommandKeyEnum.configGet, _configGet('user.name')),
      _request(GitCommandKeyEnum.configGet, _configGet('user.email')),
    ]);
    final Result<String, GitClientFailure> name = await _configValue(
      'user.name',
      plan: plan,
    );
    if (name case Failure<String, GitClientFailure>()) {
      plan.close();
      return name;
    }
    return (await _configValue('user.email', plan: plan)).map(
      (String email) => '${name.valueOrNull}${GitClient.unitSeparator}$email',
    );
  }

  @override
  Future<Result<String, GitClientFailure>> githubAccount() =>
      _configValue(_accountKey, local: true);

  @override
  Future<Result<void, GitClientFailure>> recordGithubAccount(String login) =>
      _gitVoid(GitCommandKeyEnum.configLocalSet, <String>[
        'config',
        '--local',
        _accountKey,
        login,
      ]);

  /// Where [githubAccount] is kept: the repository's own config, so the
  /// choice is per repository and goes with it.
  static const String _accountKey = 'tom.githubAccount';

  /// [key] as git resolves it, or empty when nothing sets it; with [local],
  /// only the repository's own config is read.
  Future<Result<String, GitClientFailure>> _configValue(
    String key, {
    bool local = false,
    CommandPlan? plan,
  }) async {
    final Result<String, GitClientFailure> result = await _git(
      local ? GitCommandKeyEnum.configLocalGet : GitCommandKeyEnum.configGet,
      _configGet(key, local: local),
      answers: _none,
      plan: plan,
    );
    return switch (result) {
      Success<String, GitClientFailure>(:final String value) =>
        Success<String, GitClientFailure>(value.trim()),
      // Exit 1 with nothing printed is a key nobody set: an answer.
      Failure<String, GitClientFailure>(
        failure: GitClientCommandFailed(
          :final int exitCode,
          :final String stderr,
        ),
      )
          when exitCode == 1 && stderr.trim().isEmpty =>
        const Success<String, GitClientFailure>(''),
      Failure<String, GitClientFailure>() => result,
    };
  }

  /// The arguments that read [key], from the repository's own config only
  /// with [local].
  static List<String> _configGet(String key, {bool local = false}) => <String>[
    'config',
    if (local) '--local',
    '--get',
    key,
  ];

  @override
  Future<Result<String, GitClientFailure>> branchBase(String branch) =>
      _configValue(_baseKey(branch), local: true);

  @override
  Future<Result<void, GitClientFailure>> recordBranchBase(
    String branch,
    String base,
  ) => _gitVoid(GitCommandKeyEnum.configLocalSet, <String>[
    'config',
    '--local',
    _baseKey(branch),
    base,
  ]);

  /// Where [branchBase] is kept: beside the branch's own `remote` and
  /// `merge`, so git carries it through a rename and drops it on a delete.
  static String _baseKey(String branch) => 'branch.$branch.tomBase';

  @override
  Future<Result<String, GitClientFailure>> diffNumstat(String base) =>
      _git(GitCommandKeyEnum.diffNumstat, _diffSince(base, '--numstat'));

  @override
  Future<Result<String, GitClientFailure>> diffNameStatus(String base) =>
      _git(GitCommandKeyEnum.diffNameStatus, _diffSince(base, '--name-status'));

  /// `diff` from where `HEAD` left [base], root-relative whatever the user's
  /// `diff.relative` says, as the contract requires.
  static List<String> _diffSince(String base, String format) => <String>[
    '-c',
    'diff.relative=false',
    'diff',
    format,
    '-z',
    '--no-renames',
    '$base...HEAD',
  ];

  @override
  Future<Result<String, GitClientFailure>> mergeBase(String revision) async {
    final Result<String, GitClientFailure> result = await _git(
      GitCommandKeyEnum.mergeBase,
      <String>['merge-base', revision, 'HEAD'],
      answers: _none,
    );
    return switch (result) {
      Success<String, GitClientFailure>(:final String value) =>
        Success<String, GitClientFailure>(value.trim()),
      // Exit 1 with nothing printed is unrelated histories: an answer.
      Failure<String, GitClientFailure>(
        failure: GitClientCommandFailed(:final String stderr),
      )
          when stderr.trim().isEmpty =>
        const Success<String, GitClientFailure>(''),
      Failure<String, GitClientFailure>() => result,
    };
  }

  @override
  Future<Result<bool, GitClientFailure>> resolves(String revision) async {
    final Result<String, GitClientFailure> result = await _git(
      GitCommandKeyEnum.revisionExists,
      <String>['rev-parse', '--verify', '--quiet', '$revision^{commit}'],
      answers: _none,
    );
    return switch (result) {
      Success<String, GitClientFailure>() =>
        const Success<bool, GitClientFailure>(true),
      Failure<String, GitClientFailure>(failure: GitClientCommandFailed()) =>
        const Success<bool, GitClientFailure>(false),
      Failure<String, GitClientFailure>(:final GitClientFailure failure) =>
        Failure<bool, GitClientFailure>(failure),
    };
  }

  @override
  Future<Result<String, GitClientFailure>> remoteUrl() async {
    // Exit 2 is git's "no such remote".
    final Result<String, GitClientFailure> result = await _git(
      GitCommandKeyEnum.remoteUrl,
      <String>['remote', 'get-url', 'origin'],
      answers: const <int>{2},
    );
    return switch (result) {
      Success<String, GitClientFailure>(:final String value) =>
        Success<String, GitClientFailure>(value.trim()),
      // No `origin` is an answer: `No such remote 'origin'`.
      Failure<String, GitClientFailure>(failure: GitClientNoRemote()) =>
        const Success<String, GitClientFailure>(''),
      Failure<String, GitClientFailure>() => result,
    };
  }

  @override
  Future<Result<String, GitClientFailure>> defaultBranch() async {
    final Result<String, GitClientFailure> head = await _git(
      GitCommandKeyEnum.remoteHead,
      <String>[
        'symbolic-ref',
        '--quiet',
        '--short',
        'refs/remotes/origin/HEAD',
      ],
      answers: _none,
    );
    if (head case Success<String, GitClientFailure>(:final String value)) {
      final String name = value.trim();
      return Success<String, GitClientFailure>(
        name.startsWith('origin/') ? name.substring('origin/'.length) : name,
      );
    }
    // A refusal is not "nothing says": guessing on would ask twice more.
    if (head case Failure<String, GitClientFailure>(
      failure: GitClientCommandDenied(),
    )) {
      return head;
    }
    // Only exit 1 says "nothing says"; a git that never started, or a folder
    // that is no repository, is a failure and not an empty answer.
    if (head case Failure<String, GitClientFailure>(
      failure: final GitClientFailure failure,
    ) when failure is! GitClientCommandFailed || failure.exitCode != 1) {
      return head;
    }
    for (final String guess in <String>['main', 'master']) {
      final Result<String, GitClientFailure> found = await _git(
        GitCommandKeyEnum.remoteBranchExists,
        <String>[
          'rev-parse',
          '--verify',
          '--quiet',
          'refs/remotes/origin/$guess',
        ],
        answers: _none,
      );
      if (found case Success<String, GitClientFailure>()) {
        return Success<String, GitClientFailure>(guess);
      }
      if (found case Failure<String, GitClientFailure>(
        failure: GitClientCommandDenied(),
      )) {
        return found;
      }
    }
    return const Success<String, GitClientFailure>('');
  }

  @override
  Future<Result<String, GitClientFailure>> currentBranch() async {
    final Result<String, GitClientFailure> head = await _git(
      GitCommandKeyEnum.currentBranch,
      <String>['symbolic-ref', '--quiet', '--short', 'HEAD'],
      answers: _none,
    );
    return switch (head) {
      Success<String, GitClientFailure>(:final String value) =>
        Success<String, GitClientFailure>(value.trim()),
      // `--quiet` exits 1 with nothing to say for a detached `HEAD`.
      Failure<String, GitClientFailure>(
        failure: GitClientCommandFailed(exitCode: 1),
      ) =>
        const Success<String, GitClientFailure>(''),
      Failure<String, GitClientFailure>() => head,
    };
  }

  @override
  Future<Result<String, GitClientFailure>> show(
    String revision,
    String path,
  ) async {
    final Result<String, GitClientFailure> result = await _git(
      GitCommandKeyEnum.show,
      <String>['show', '$revision:$path'],
      // "No earlier version" is an answer, so its row is not drawn as a
      // failure; git's other fatals stay red.
      answeredWhen: _pathNotInRevision,
    );
    return _orNotInRevision(result, revision, path);
  }

  @override
  Future<Result<Uint8List, GitClientFailure>> showBytes(
    String revision,
    String path,
  ) async => _orNotInRevision(
    await _gitBytes(GitCommandKeyEnum.show, <String>[
      'show',
      '$revision:$path',
    ], answeredWhen: _pathNotInRevision),
    revision,
    path,
  );

  @override
  Future<Result<Uint8List, GitClientFailure>> showStagedBytes(
    String path,
  ) async => _orNotInRevision(
    await _gitBytes(GitCommandKeyEnum.showStaged, <String>[
      'show',
      ':$path',
    ], answeredWhen: _pathNotInRevision),
    '',
    path,
  );

  /// [result], with git's "no such path" told apart from any other failure.
  ///
  /// Recognised here rather than in `_translate`, which is handed the command
  /// line and not its two halves.
  static Result<T, GitClientFailure> _orNotInRevision<T>(
    Result<T, GitClientFailure> result,
    String revision,
    String path,
  ) => switch (result) {
    Failure<T, GitClientFailure>(failure: final GitClientCommandFailed failure)
        when _pathNotInRevision.hasMatch(failure.stderr) =>
      Failure<T, GitClientFailure>(
        GitClientPathNotInRevision(revision, path, cause: failure),
      ),
    _ => result,
  };

  @override
  Future<Result<void, GitClientFailure>> stage(List<String> paths) => _gitVoid(
    GitCommandKeyEnum.add,
    <String>['add', '--', ...paths.map(_pathspec)],
  );

  @override
  Future<Result<void, GitClientFailure>> discardAll() =>
      _inOrder(<(GitCommandKeyEnum, List<String>)>[
        // The index first: `reset` makes it `HEAD` again, which turns an
        // added file back into an untracked one with its content.
        (GitCommandKeyEnum.reset, <String>['reset', '--quiet']),
        // Then the working tree from the index, from the top (`:/`) because
        // this client may run in a folder below the repository's root.
        (
          GitCommandKeyEnum.restoreWorktreeAll,
          <String>['restore', '--worktree', '--', ':/'],
        ),
      ]);

  @override
  Future<Result<void, GitClientFailure>> discardUnstaged(List<String> paths) =>
      _gitVoid(GitCommandKeyEnum.restoreWorktree, <String>[
        'restore',
        '--worktree',
        '--',
        ...paths.map(_pathspec),
      ]);

  @override
  Future<Result<void, GitClientFailure>> discardSinceCommit(
    List<String> paths,
  ) => _gitVoid(GitCommandKeyEnum.restoreFromHead, <String>[
    'restore',
    '--staged',
    '--worktree',
    '--source=HEAD',
    '--',
    ...paths.map(_pathspec),
  ]);

  @override
  Future<Result<void, GitClientFailure>> deleteUncommitted(
    List<String> paths,
  ) async {
    // Asked of `HEAD` now rather than trusted from a status read earlier:
    // `clean` cannot be undone, and a committed file would go with the rest.
    final Result<String, GitClientFailure> held = await _git(
      GitCommandKeyEnum.committedPaths,
      // `--full-tree` for the reason [_pathspec] says `top`; `ls-tree` takes
      // plain paths, with no glob to escape.
      <String>[
        'ls-tree',
        '--full-tree',
        '--name-only',
        '-z',
        'HEAD',
        '--',
        ...paths,
      ],
      answers: _noSuchObject,
    );
    switch (held) {
      case Success<String, GitClientFailure>(:final String value):
        final List<String> committed = value
            .split(GitClient.nulSeparator)
            .where((String path) => path.isNotEmpty)
            .toList(growable: false);
        if (committed.isNotEmpty) {
          return Failure<void, GitClientFailure>(
            GitClientPathCommitted(committed),
          );
        }
      // No `HEAD` at all is nothing committed, which is the answer wanted.
      case Failure<String, GitClientFailure>(
            failure: GitClientCommandFailed(:final String stderr),
          )
          when _noHead.hasMatch(stderr):
        break;
      case Failure<String, GitClientFailure>(:final GitClientFailure failure):
        return Failure<void, GitClientFailure>(failure);
    }
    return _deleteNeverCommitted(paths);
  }

  /// Takes [paths] out of the index and off the disk, [deleteUncommitted]
  /// having found none of them in `HEAD`.
  Future<Result<void, GitClientFailure>> _deleteNeverCommitted(
    List<String> paths,
  ) => _inOrder(<(GitCommandKeyEnum, List<String>)>[
    // Out of the index first, which works on an unborn `HEAD` too; `-f`
    // because a staged file edited since differs from both sides, and
    // `--ignore-unmatch` because an untracked one was never in it.
    (
      GitCommandKeyEnum.removeFromIndexForced,
      <String>[
        'rm',
        '--cached',
        '-f',
        '--quiet',
        '--ignore-unmatch',
        '--',
        ...paths.map(_pathspec),
      ],
    ),
    // `-x` for a file that was added over `.gitignore`, which is ignored
    // again once out of the index; the pathspecs are literal, so nothing
    // but the named files can match.
    (
      GitCommandKeyEnum.clean,
      <String>['clean', '-f', '-x', '--quiet', '--', ...paths.map(_pathspec)],
    ),
  ]);

  @override
  Future<Result<void, GitClientFailure>> unstage(List<String> paths) async {
    // Nothing to take out is nothing to ask git, which exits 128 on an empty
    // pathspec list (`stage` of none succeeds the same way).
    if (paths.isEmpty) {
      return const Success<void, GitClientFailure>(null);
    }
    final Result<void, GitClientFailure> result = await _gitVoid(
      GitCommandKeyEnum.restoreStaged,
      <String>['restore', '--staged', '--', ...paths.map(_pathspec)],
    );
    // `restore --staged` rebuilds the index from `HEAD`, which is fatal before
    // the first commit; every staged path is an addition there, so taking it
    // back out of the index is what unstaging means. `--ignore-unmatch` keeps
    // both branches succeeding on a path that was not staged.
    return switch (result) {
      Failure<void, GitClientFailure>(
        failure: GitClientCommandFailed(:final String stderr),
      )
          when _unbornHead.hasMatch(stderr) =>
        _gitVoid(GitCommandKeyEnum.removeFromIndex, <String>[
          'rm',
          '--cached',
          '--quiet',
          '-r',
          '--ignore-unmatch',
          '--',
          ...paths.map(_pathspec),
        ]),
      _ => result,
    };
  }

  @override
  Future<Result<void, GitClientFailure>> commit(String message) => _gitVoid(
    GitCommandKeyEnum.commit,
    // `whitespace`, because the person's `commit.cleanup=strip` would take a
    // markdown heading out of the message as a comment.
    <String>['commit', '--cleanup=whitespace', '--message', message],
  );

  @override
  Future<Result<void, GitClientFailure>> createBranch(String name) => _gitVoid(
    GitCommandKeyEnum.switchCreate,
    <String>['switch', '--create', name],
  );

  @override
  Future<Result<void, GitClientFailure>> switchBranch(String name) async {
    // Git forbids a branch name that starts with a dash, and `switch` reads
    // even `-- -` as "the previous branch"; so none is asked.
    if (name.startsWith('-')) {
      return Failure<void, GitClientFailure>(
        GitClientCommandFailed(
          'git switch -- $name',
          128,
          "fatal: '$name' is not a valid branch name",
        ),
      );
    }
    // `--` so nothing after it can be read as an option.
    return _gitVoid(GitCommandKeyEnum.switchBranch, <String>[
      'switch',
      '--',
      name,
    ]);
  }

  @override
  Future<Result<void, GitClientFailure>> fetch() => _gitVoid(
    GitCommandKeyEnum.fetch,
    <String>['fetch'],
    limit: networkTimeout,
  );

  @override
  Future<Result<void, GitClientFailure>> pull() =>
      // `--no-rebase`: a bare `git pull` fails on divergent branches unless
      // `pull.rebase` or `pull.ff` is set, and the choice is the product's.
      // Merge, because the app promises that nothing committed is lost and a
      // rebase can stop halfway
      // (`docs/product/git-workflow/push-pull/what-each-does/doc.md`).
      _gitVoid(GitCommandKeyEnum.pull, <String>[
        'pull',
        '--no-rebase',
      ], limit: networkTimeout);

  @override
  Future<Result<String, GitClientFailure>> head() async {
    final Result<String, GitClientFailure> result = await _git(
      GitCommandKeyEnum.head,
      <String>['rev-parse', '--verify', '--quiet', 'HEAD'],
      answers: _none,
    );
    return switch (result) {
      Success<String, GitClientFailure>(:final String value) =>
        Success<String, GitClientFailure>(value.trim()),
      // `--quiet` fails with nothing printed on an unborn branch: an answer.
      Failure<String, GitClientFailure>(
        failure: GitClientCommandFailed(:final String stderr),
      )
          when stderr.trim().isEmpty =>
        const Success<String, GitClientFailure>(''),
      Failure<String, GitClientFailure>() => result,
    };
  }

  @override
  Future<Result<int, GitClientFailure>> upstreamCommitsSince(
    String since,
  ) async {
    final String range = since.isEmpty ? '@{upstream}' : '$since..@{upstream}';
    final Result<String, GitClientFailure> result = await _git(
      GitCommandKeyEnum.upstreamCommitCount,
      <String>['rev-list', '--count', range],
    );
    return switch (result) {
      Success<String, GitClientFailure>(:final String value) =>
        switch (int.tryParse(value.trim())) {
          final int count => Success<int, GitClientFailure>(count),
          null => Failure<int, GitClientFailure>(
            GitClientCommandFailed('git rev-list --count $range', 0, value),
          ),
        },
      Failure<String, GitClientFailure>(:final GitClientFailure failure) =>
        Failure<int, GitClientFailure>(failure),
    };
  }

  @override
  Future<Result<void, GitClientFailure>> push() =>
      _gitVoid(GitCommandKeyEnum.push, <String>['push'], limit: networkTimeout);

  @override
  Future<Result<void, GitClientFailure>> publish(String branch) => _gitVoid(
    GitCommandKeyEnum.pushSetUpstream,
    // No `--` before the name: git refuses a branch that starts with `-`.
    <String>['push', '--set-upstream', 'origin', branch],
    limit: networkTimeout,
  );

  @override
  Future<Result<String, GitClientFailure>> gitDirectory() async {
    // Not `--path-format=absolute`, which needs git 2.31: a relative answer
    // is relative to the folder git ran in, and resolving it here keeps 2.23.
    final Result<String, GitClientFailure> result = await _git(
      GitCommandKeyEnum.gitDirectory,
      <String>['rev-parse', '--git-common-dir'],
    );
    return switch (result) {
      Success<String, GitClientFailure>(:final String value) =>
        Success<String, GitClientFailure>(_absolute(value.trim())),
      Failure<String, GitClientFailure>() => result,
    };
  }

  /// [path] as git printed it, resolved against [workingDirectory] when it
  /// is relative, with no trailing separator.
  String _absolute(String path) {
    final bool windows = Platform.isWindows;
    final Uri folder = Uri.directory(workingDirectory, windows: windows);
    final String resolved = Uri.file(path, windows: windows).isAbsolute
        ? path
        : folder.resolve(path).toFilePath(windows: windows);
    return resolved.length > 1 &&
            (resolved.endsWith('/') || resolved.endsWith(r'\'))
        ? resolved.substring(0, resolved.length - 1)
        : resolved;
  }

  @override
  Future<Result<bool, GitClientFailure>> mergeInProgress() async {
    // `--verify --quiet` exits non-zero with no output when the ref is
    // absent, which is the ordinary answer rather than a failure to report.
    final Result<String, GitClientFailure> result = await _git(
      GitCommandKeyEnum.mergeHead,
      <String>['rev-parse', '--verify', '--quiet', 'MERGE_HEAD'],
      answers: _none,
    );
    return switch (result) {
      Success<String, GitClientFailure>(value: final String sha) =>
        Success<bool, GitClientFailure>(sha.trim().isNotEmpty),
      Failure<String, GitClientFailure>(failure: GitClientCommandFailed()) =>
        const Success<bool, GitClientFailure>(false),
      Failure<String, GitClientFailure>(:final GitClientFailure failure) =>
        Failure<bool, GitClientFailure>(failure),
    };
  }

  @override
  Future<Result<String, GitClientFailure>> mergeMessage() async {
    // `--git-path` rather than `.git/MERGE_MSG`: it answers correctly in a
    // worktree and a submodule, where `.git` is a file and not a folder.
    final Result<String, GitClientFailure> located = await _git(
      GitCommandKeyEnum.mergeMessagePath,
      <String>['rev-parse', '--git-path', 'MERGE_MSG'],
    );
    if (located case Failure<String, GitClientFailure>(
      failure: final GitClientFailure failure,
    )) {
      return Failure<String, GitClientFailure>(failure);
    }
    final String path = (located as Success<String, GitClientFailure>).value
        .trim();
    final File file = File(
      path.startsWith('/') ? path : '$workingDirectory/$path',
    );
    // No file is no merge, which is an answer; only a file that exists and
    // cannot be read is worth reporting, and git is about to report it too.
    try {
      return file.existsSync()
          ? Success<String, GitClientFailure>(
              _decoder.convert(file.readAsBytesSync()),
            )
          : const Success<String, GitClientFailure>('');
    } on FileSystemException {
      return const Success<String, GitClientFailure>('');
    }
  }

  @override
  Future<Result<void, GitClientFailure>> abortMerge() =>
      _gitVoid(GitCommandKeyEnum.mergeAbort, <String>['merge', '--abort']);

  /// [path], as a pathspec git resolves from the repository root.
  ///
  /// A bare pathspec resolves against [workingDirectory], which is the root
  /// only by accident; `top` keeps a path read from [status] usable in
  /// [stage]. `literal` because git reads `[` in a pathspec as a glob.
  static String _pathspec(String path) => ':(top,literal)$path';

  /// Runs a command whose output the caller does not need.
  Future<Result<void, GitClientFailure>> _gitVoid(
    GitCommandKeyEnum key,
    List<String> arguments, {
    Duration? limit,
    CommandPlan? plan,
  }) async {
    final Result<String, GitClientFailure> result = await _git(
      key,
      arguments,
      limit: limit,
      plan: plan,
    );
    return result.map((_) {});
  }

  /// Runs [commands] one after the other, declared to the gate together so
  /// they are one plan: a refusal or a failure stops it there, and what was
  /// still to run is cancelled rather than left waiting.
  Future<Result<void, GitClientFailure>> _inOrder(
    List<(GitCommandKeyEnum, List<String>)> commands,
  ) async {
    final CommandPlan plan = commandGate.plan(<CommandRequest>[
      for (final (GitCommandKeyEnum key, List<String> arguments) in commands)
        _request(key, arguments),
    ]);
    for (final (GitCommandKeyEnum key, List<String> arguments) in commands) {
      final Result<void, GitClientFailure> done = await _gitVoid(
        key,
        arguments,
        plan: plan,
      );
      if (done is Failure<void, GitClientFailure>) {
        plan.close();
        return done;
      }
    }
    return const Success<void, GitClientFailure>(null);
  }

  /// Asks the gate, then queues [arguments] and hands back stdout, or a
  /// typed failure.
  ///
  /// [answers] are the exits the caller reads as an answer rather than an
  /// error, so the command log draws them neither red nor green.
  Future<Result<String, GitClientFailure>> _git(
    GitCommandKeyEnum key,
    List<String> arguments, {
    Duration? limit,
    Set<int> answers = const <int>{},
    RegExp? answeredWhen,
    CommandPlan? plan,
  }) => _asked(
    key,
    arguments,
    (int? ticket) => _enqueue(
      () => _run(
        arguments,
        limit ?? timeout,
        answers: answers,
        answeredWhen: answeredWhen,
        ticket: ticket,
      ),
    ),
    plan: plan,
  );

  /// [_git], with what git printed left as bytes.
  Future<Result<Uint8List, GitClientFailure>> _gitBytes(
    GitCommandKeyEnum key,
    List<String> arguments, {
    RegExp? answeredWhen,
  }) => _asked(
    key,
    arguments,
    (int? ticket) => _enqueue(
      () => _runBytes(
        arguments,
        timeout,
        answeredWhen: answeredWhen,
        ticket: ticket,
      ),
    ),
  );

  /// What the gate is told about running [arguments] as [key].
  static CommandRequest _request(
    GitCommandKeyEnum key,
    List<String> arguments,
  ) => CommandRequest.of(key: key, executable: 'git', arguments: arguments);

  /// Asks the gate about [arguments] — or takes the next verdict of [plan],
  /// which declared them already — and [start]s the command when it may run.
  ///
  /// **Before the queue and before any timer**, so a command somebody is
  /// still reading holds no slot and counts toward no timeout.
  Future<Result<T, GitClientFailure>> _asked<T>(
    GitCommandKeyEnum key,
    List<String> arguments,
    Future<Result<T, GitClientFailure>> Function(int? ticket) start, {
    CommandPlan? plan,
  }) async {
    final CommandRequest request = _request(key, arguments);
    final CommandVerdict verdict =
        await (plan ?? commandGate.plan(<CommandRequest>[request])).next();
    return switch (verdict) {
      CommandRun(:final int? ticket) => await start(ticket),
      CommandDenied() => Failure<T, GitClientFailure>(
        GitClientCommandDenied(request.commandLine),
      ),
    };
  }

  /// The exit `--verify --quiet`, `config --get`, `symbolic-ref --quiet` and
  /// `merge-base` give for "there is none", which every caller reads as an
  /// answer.
  static const Set<int> _none = <int>{1};

  /// Chains [operation] onto the queue.
  ///
  /// The queue never carries a failure forward, so one operation that threw
  /// cannot stop every later command in the space.
  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final String folder = Directory(workingDirectory).absolute.path;
    final Future<void> tail = _tails[folder] ?? Future<void>.value();
    final Future<T> result = tail.then((void _) => operation());
    final Future<void> next = result
        .then<void>((T _) {})
        .catchError((Object _) {});
    _tails[folder] = next;
    // An idle folder leaves no entry behind.
    unawaited(
      next.then((void _) {
        if (identical(_tails[folder], next)) {
          _tails.remove(folder)?.ignore();
        }
      }),
    );
    return result;
  }

  /// [_runBytes], with what git printed decoded leniently.
  Future<Result<String, GitClientFailure>> _run(
    List<String> arguments,
    Duration limit, {
    bool insideFolder = true,
    void Function(String line)? onLine,
    Set<int> answers = const <int>{},
    RegExp? answeredWhen,
    int? ticket,
  }) async => (await _runBytes(
    arguments,
    limit,
    insideFolder: insideFolder,
    onLine: onLine,
    answers: answers,
    answeredWhen: answeredWhen,
    ticket: ticket,
  )).map(_decoder.convert);

  /// Starts git, collects both streams, and kills it if it outlives [limit].
  ///
  /// With [onLine], stderr is also handed over a line at a time and [limit]
  /// bounds the *silence* instead: a large clone takes as long as it takes,
  /// a remote that stops answering does not. [insideFolder] false runs git
  /// from wherever the app is, for the command that creates the folder.
  Future<Result<Uint8List, GitClientFailure>> _runBytes(
    List<String> arguments,
    Duration limit, {
    bool insideFolder = true,
    void Function(String line)? onLine,
    Set<int> answers = const <int>{},
    RegExp? answeredWhen,
    int? ticket,
  }) async {
    final String command = 'git ${arguments.join(' ')}';
    // A copy the run may add to: the log keeps the set it was handed, and
    // [answeredWhen] is only known once stderr is.
    final Set<int> answered = <int>{...answers};
    final CommandEnded ended = commandLog.started(
      'git',
      arguments,
      answers: answered,
      ticket: ticket,
    );
    final Process process;
    try {
      process = await startProcess(
        executable,
        arguments,
        workingDirectory: insideFolder ? workingDirectory : null,
        environment: <String, String>{..._environment, ...environment},
      );
    } on ProcessException catch (error) {
      ended(null, stderr: error.message, ran: false);
      return Failure<Uint8List, GitClientFailure>(
        insideFolder
            ? await _startFailure()
            : const GitClientExecutableNotFound(),
      );
    }

    final Completer<void> stalled = Completer<void>();
    Timer? silence;
    void heard() {
      silence?.cancel();
      silence = Timer(limit, () {
        if (!stalled.isCompleted) {
          stalled.complete();
        }
      });
    }

    final Future<Uint8List> out = process.stdout
        .fold(BytesBuilder(copy: false), _collected)
        .then((BytesBuilder all) => all.takeBytes());
    final Future<String> err = onLine == null
        ? process.stderr.transform(_decoder).join()
        : process.stderr
              .transform(_decoder)
              .transform(const LineSplitter())
              .map((String line) {
                heard();
                if (line.trim().isNotEmpty) {
                  onLine(line);
                }
                return line;
              })
              .join('\n');

    final int exitCode;
    try {
      if (onLine == null) {
        exitCode = await process.exitCode.timeout(limit);
      } else {
        heard();
        exitCode =
            await Future.any<int?>(<Future<int?>>[
              process.exitCode,
              stalled.future.then((void _) => null),
            ]) ??
            (throw TimeoutException(command, limit));
      }
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      await _drain(out, err);
      ended(null);
      return Failure<Uint8List, GitClientFailure>(
        GitClientTimedOut(command, limit),
      );
    } finally {
      silence?.cancel();
    }

    final Uint8List printed = await out;
    final String stdout = _decoder.convert(printed);
    final String stderr = await err;
    if (exitCode != 0 && (answeredWhen?.hasMatch(stderr) ?? false)) {
      answered.add(exitCode);
    }
    ended(exitCode, stdout: stdout, stderr: stderr);
    if (exitCode == 0) {
      return Success<Uint8List, GitClientFailure>(printed);
    }
    final GitClientFailure failure = _translate(
      command,
      exitCode,
      stdout,
      stderr,
    );
    return Failure<Uint8List, GitClientFailure>(
      failure is GitClientMergeConflict ? await _named(failure) : failure,
    );
  }

  /// One more chunk of a stream onto what was read of it so far.
  static BytesBuilder _collected(BytesBuilder all, List<int> chunk) =>
      all..add(chunk);

  /// Why [Process.start] refused, without letting the probe throw.
  ///
  /// A `ProcessException` is either no `git` on the PATH or a working
  /// directory git could not enter, and the second must not read as "git is
  /// not installed". A probe the machine refuses is still a folder TOM cannot
  /// open, never a missing binary, and never a leaked `FileSystemException`.
  Future<GitClientFailure> _startFailure() async {
    bool reachable;
    try {
      // A space folder can sit on a network mount, and the synchronous probe
      // would block the isolate for as long as a stale one takes to answer.
      // ignore: avoid_slow_async_io
      reachable = await Directory(workingDirectory).exists();
    } on FileSystemException {
      reachable = false;
    }
    return reachable
        ? const GitClientExecutableNotFound()
        : GitClientNotARepository(workingDirectory);
  }

  /// Waits for both pipes to close, giving up after [_drainGrace].
  ///
  /// Both futures keep their handlers either way, so a pipe that dies with
  /// the process cannot surface later as an unhandled asynchronous error.
  static Future<void> _drain(Future<Object> out, Future<Object> err) {
    final Future<void> closed = Future.wait<Object>(<Future<Object>>[
      out,
      err,
    ]).then<void>((List<Object> _) {}).catchError((Object _) {});
    return closed.timeout(_drainGrace, onTimeout: () {});
  }

  /// [conflict] carrying the paths git's index reports, when it can be asked.
  ///
  /// The `CONFLICT (...)` lines have a shape per kind and reading them misses
  /// most; `--diff-filter=U` is every path left conflicted whatever produced
  /// it. What the message gave stands only if asking fails.
  Future<GitClientFailure> _named(GitClientMergeConflict conflict) async {
    final List<String> unmerged = await _unmergedPaths();
    return unmerged.isEmpty ? conflict : GitClientMergeConflict(unmerged);
  }

  /// Every path git left unmerged, relative to the repository root.
  ///
  /// Runs outside the queue, because the caller holds the slot it would wait
  /// for. `diff.relative` is forced off so a user who set it still gets
  /// root-relative paths, as the contract requires. Asked at the gate like
  /// any command; refused, the paths the message gave stand.
  Future<List<String>> _unmergedPaths() async {
    const List<String> arguments = <String>[
      '-c',
      'diff.relative=false',
      'diff',
      '--name-only',
      '--diff-filter=U',
      '-z',
    ];
    final Result<String, GitClientFailure> unmerged = await _asked(
      GitCommandKeyEnum.diffUnmerged,
      arguments,
      (int? ticket) => _run(arguments, timeout, ticket: ticket),
    );
    return switch (unmerged) {
      Success<String, GitClientFailure>(:final String value) =>
        value
            .split(GitClient.nulSeparator)
            .where((String path) => path.isNotEmpty)
            .toList(growable: false),
      Failure<String, GitClientFailure>() => const <String>[],
    };
  }

  /// What git is run with, on top of the user's own environment.
  ///
  /// The parent environment stays: PATH, agent and credential helper are the
  /// user's. Suppressing the prompt takes all three prompt variables, because
  /// git falls through from the terminal to `GIT_ASKPASS` to ssh's own
  /// `SSH_ASKPASS`, and one left reachable blocks for the whole
  /// [networkTimeout] instead of failing as [GitClientAuthenticationFailed].
  /// `GIT_OPTIONAL_LOCKS=0` because TOM reads far more often than a person;
  /// `LC_ALL=C` so the patterns below are not a bet on the locale.
  /// `GIT_SSH_COMMAND` stays unset: it would override `core.sshCommand`.
  /// `i18n.logOutputEncoding` is pinned to UTF-8 through `GIT_CONFIG_*`:
  /// every read decodes UTF-8, whatever the person's own setting says.
  static const Map<String, String> _environment = <String, String>{
    'GIT_CONFIG_COUNT': '1',
    'GIT_CONFIG_KEY_0': 'i18n.logOutputEncoding',
    'GIT_CONFIG_VALUE_0': 'UTF-8',
    'GIT_TERMINAL_PROMPT': '0',
    'GIT_ASKPASS': '',
    'SSH_ASKPASS_REQUIRE': 'never',
    'GIT_OPTIONAL_LOCKS': '0',
    'LC_ALL': 'C',
  };

  /// Maps what the command reported to a [GitClientFailure].
  ///
  /// By message, since exit codes are 1 or 128 for nearly everything: wording
  /// git has kept stable, `LC_ALL=C` fixing the language, and anything else
  /// [GitClientCommandFailed]. Both streams are read because a conflict's
  /// `CONFLICT` lines land on stdout and `Automatic merge failed` on stderr.
  GitClientFailure _translate(
    String command,
    int exitCode,
    String stdout,
    String stderr,
  ) {
    final String output = '$stdout\n$stderr';
    if (_notARepository.hasMatch(stderr)) {
      return GitClientNotARepository(workingDirectory);
    }
    if (_authenticationFailed.hasMatch(stderr)) {
      return GitClientAuthenticationFailed(stderr);
    }
    // After the credentials: an `unable to access` line carries both kinds.
    if (_networkUnavailable.hasMatch(stderr)) {
      return GitClientNetworkUnavailable(stderr);
    }
    if (_noRemote.hasMatch(stderr)) {
      return GitClientNoRemote(stderr);
    }
    // Before the race: a protected branch is refused with `[remote
    // rejected]` too, and pulling would not be the way out.
    if (_branchProtected.hasMatch(output)) {
      return GitClientBranchProtected(stderr);
    }
    if (_pushRejected.hasMatch(output)) {
      return GitClientPushRejected(stderr);
    }
    // Git lists the paths under the sentence, one per line, behind a tab.
    if (_wouldOverwrite.hasMatch(stderr)) {
      return GitClientLocalChangesOverwritten(<String>[
        for (final String line in const LineSplitter().convert(stderr))
          if (line.startsWith('\t') && line.trim().isNotEmpty) line.trim(),
      ]);
    }
    if (_mergeConflict.hasMatch(output)) {
      return GitClientMergeConflict(<String>[
        for (final RegExpMatch match in _conflictedPath.allMatches(output))
          match.group(1)!.trim(),
      ]);
    }
    return GitClientCommandFailed(command, exitCode, stderr);
  }

  /// A clone's address names nothing git can clone: no repository there, or
  /// a transport git does not speak or will not use.
  static final RegExp _notCloneable = RegExp(
    r"repository '[^']*' (?:does not exist|not found)|"
    'does not appear to be a git repository|repository not found|'
    "remote helper|is not a git command|transport '[^']*' not allowed|"
    "protocol '[^']*' is not supported",
    caseSensitive: false,
  );

  /// The folder a clone was to create already holds something.
  static final RegExp _destinationTaken = RegExp(
    'already exists and is not an empty directory',
    caseSensitive: false,
  );

  /// The folder is outside any repository — or holds one with no working
  /// tree (a bare repository), or is asked for `--local` config outside one.
  static final RegExp _notARepository = RegExp(
    'not a git repository'
    '|can only be used inside a git repository'
    '|must be run in a work tree',
    caseSensitive: false,
  );

  /// Git needed credentials and did not get usable ones.
  static final RegExp _authenticationFailed = RegExp(
    'authentication failed|could not read username|could not read password|'
    r'permission denied \(publickey|terminal prompts disabled|'
    'invalid username or password',
    caseSensitive: false,
  );

  /// The remote's host could not be reached.
  static final RegExp _networkUnavailable = RegExp(
    'could not resolve host|could not resolve hostname|'
    'temporary failure in name resolution|network is unreachable|'
    'no route to host|connection refused|failed to connect to|'
    'connection timed out|operation timed out',
    caseSensitive: false,
  );

  /// Nothing to talk to: no remote by that name, or none at all.
  ///
  /// Not *there is no tracking information*: `pull` says that when a remote
  /// exists and the branch has no upstream, which is not this.
  static final RegExp _noRemote = RegExp(
    'does not appear to be a git repository|no configured push destination|'
    'no remote repository specified|no such remote',
    caseSensitive: false,
  );

  /// A push refused because the remote protects the branch: GitHub's
  /// `GH006`/`GH013` and GitLab's `protected branch` wording.
  static final RegExp _branchProtected = RegExp(
    r'protected branch|GH006|GH013',
    caseSensitive: false,
  );

  /// A push lost the race to the remote.
  static final RegExp _pushRejected = RegExp(
    r'\[rejected\]|non-fast-forward|updates were rejected',
    caseSensitive: false,
  );

  /// A merge refused to start over uncommitted work: tracked files changed,
  /// or untracked ones the merge would create.
  static final RegExp _wouldOverwrite = RegExp(
    'would be overwritten by merge',
    caseSensitive: false,
  );

  /// A merge, rebase or pull stopped on conflicts.
  static final RegExp _mergeConflict = RegExp(
    'automatic merge failed|could not apply|^CONFLICT ',
    caseSensitive: false,
    multiLine: true,
  );

  /// The path named by one `CONFLICT (...): Merge conflict in <path>` line —
  /// the fallback behind [_unmergedPaths], recognising content conflicts only.
  static final RegExp _conflictedPath = RegExp(
    r'^CONFLICT \([^)]*\): Merge conflict in (.+)$',
    multiLine: true,
  );

  /// The revision holds no such path, in git's three phrasings — the third
  /// being an unborn `HEAD`.
  ///
  /// The third is anchored on `HEAD` by name, because git says the same of a
  /// sha it cannot resolve or a damaged object store, and those are failures
  /// rather than "no earlier version".
  static final RegExp _pathNotInRevision = RegExp(
    'does not exist in|exists on disk, but not in'
    '|neither on disk nor in the index'
    "|invalid object name '?HEAD'?",
    caseSensitive: false,
  );

  /// `ls-tree HEAD` on a branch with no commit yet.
  static final RegExp _noHead = RegExp(
    'not a valid object name HEAD',
    caseSensitive: false,
  );

  /// The exit `ls-tree` gives for a `HEAD` that names nothing, which
  /// [deleteUncommitted] reads as an answer.
  static const Set<int> _noSuchObject = <int>{128};

  /// `HEAD` names no commit yet: `log` says the first, `rev-parse` the
  /// second, `restore --staged` the third.
  static final RegExp _unbornHead = RegExp(
    r'does not have any commits yet|bad default revision'
    r"|could not resolve 'HEAD'",
    caseSensitive: false,
  );

  /// `for-each-ref` asked to stand refs against an unborn `HEAD`.
  static final RegExp _headNotFound = RegExp(
    "failed to find 'HEAD'",
    caseSensitive: false,
  );
}
