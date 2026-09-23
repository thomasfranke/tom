/// The `dart:io` implementation of [GitClient].
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Drives the system's `git` binary through [Process].
///
/// The only implementation today, chosen at the composition root: credentials,
/// SSH and config come for free because it is the user's own git running
/// ([Decision
/// 2](../../../../../../../docs/technical/decisions/002-git-via-system-binary.md)).
/// A `libgit2/` sibling is scheduled rather than speculative — iOS and Android
/// have no binary to drive.
///
/// One instance per space, and git 2.23 or newer for `switch` and `restore`.
final class DartIoGitClientImpl implements GitClient {
  /// Creates a client running git inside [workingDirectory].
  ///
  /// [workingDirectory] may sit below the repository root; git resolves
  /// upwards on its own and [repositoryRoot] reports where it landed. Every
  /// path crossing the contract stays relative to that root whatever this
  /// folder is — see [_pathspec].
  /// [timeout] bounds a local command, [networkTimeout] one that reaches a
  /// remote — without them a hung command stalls the whole queue, not one
  /// action.
  DartIoGitClientImpl({
    required this.workingDirectory,
    this.timeout = const Duration(seconds: 30),
    this.networkTimeout = const Duration(minutes: 2),
  });

  /// The folder every command runs inside.
  final String workingDirectory;

  /// How long a local command may take before it is killed.
  final Duration timeout;

  /// How long a command reaching a remote may take before it is killed.
  final Duration networkTimeout;

  /// The tail of the serialized queue.
  ///
  /// Every operation chains onto this, so a commit during a checkout, or two
  /// fetches racing for the index lock, cannot happen on one instance.
  Future<void> _queue = Future<void>.value();

  /// Bytes to text, tolerating anything that is not valid UTF-8.
  ///
  /// A decoder that threw would turn "this file is odd" into an exception
  /// crossing a boundary.
  static const Utf8Decoder _decoder = Utf8Decoder(allowMalformed: true);

  /// How long a killed process's pipes are given to close.
  ///
  /// Killing git closes git's own ends, but anything it started that outlives
  /// it — a hook's background job, and whatever else inherited the pipe —
  /// holds its copy open for as long as it lives, and `dart:io` cannot kill a
  /// process group. Waiting on them unbounded would hang the queue the timeout
  /// exists to protect, so they are abandoned instead: the bytes of a command
  /// that was killed are worth nothing anyway.
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

  @override
  Future<Result<String, GitClientFailure>> repositoryRoot() async {
    final Result<String, GitClientFailure> root = await _git(<String>[
      'rev-parse',
      '--show-toplevel',
    ]);
    return switch (root) {
      Success<String, GitClientFailure>(:final String value) =>
        Success<String, GitClientFailure>(value.trim()),
      Failure<String, GitClientFailure>() => root,
    };
  }

  @override
  Future<Result<String, GitClientFailure>> status() => _git(<String>[
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
  }) async {
    final Result<String, GitClientFailure> result = await _git(<String>[
      'log',
      '--format=$_logFormat',
      if (limit != null) '--max-count=$limit',
      if (path != null) ...<String>['--', _pathspec(path)],
    ]);
    // A branch whose first commit has not happened yet is not an error: the
    // history is empty, which is exactly what a space opened on a freshly
    // initialised repository should show. Calling it fatal is git's
    // convention, not the product's.
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
  Future<Result<String, GitClientFailure>> branches() =>
      _git(<String>['branch', '--format=$_branchFormat']);

  @override
  Future<Result<String, GitClientFailure>> show(String revision, String path) =>
      _git(<String>['show', '$revision:$path']);

  @override
  Future<Result<void, GitClientFailure>> stage(List<String> paths) =>
      _gitVoid(<String>['add', '--', ...paths.map(_pathspec)]);

  @override
  Future<Result<void, GitClientFailure>> unstage(List<String> paths) async {
    final Result<void, GitClientFailure> result = await _gitVoid(<String>[
      'restore',
      '--staged',
      '--',
      ...paths.map(_pathspec),
    ]);
    // `restore --staged` rewrites the index from `HEAD`, so before the first
    // commit there is nothing to restore from and git calls it fatal — on a
    // freshly initialised repository, which is a normal state for a space.
    // Every staged path is an addition there by definition, and taking it
    // back out of the index is exactly what unstaging means.
    // `--ignore-unmatch` keeps the two branches behaving alike: `restore`
    // succeeds on a path that was not staged, and so must this.
    return switch (result) {
      Failure<void, GitClientFailure>(
        failure: GitClientCommandFailed(:final String stderr),
      )
          when _unbornHead.hasMatch(stderr) =>
        _gitVoid(<String>[
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
  Future<Result<void, GitClientFailure>> commit(String message) =>
      _gitVoid(<String>['commit', '--message', message]);

  @override
  Future<Result<void, GitClientFailure>> createBranch(String name) =>
      _gitVoid(<String>['switch', '--create', name]);

  @override
  Future<Result<void, GitClientFailure>> switchBranch(String name) =>
      _gitVoid(<String>['switch', name]);

  @override
  Future<Result<void, GitClientFailure>> fetch() =>
      _gitVoid(<String>['fetch'], limit: networkTimeout);

  @override
  Future<Result<void, GitClientFailure>> pull() =>
      _gitVoid(<String>['pull'], limit: networkTimeout);

  @override
  Future<Result<void, GitClientFailure>> push() =>
      _gitVoid(<String>['push'], limit: networkTimeout);

  /// [path], as a pathspec git resolves from the repository root.
  ///
  /// Every path crossing this contract is repository-root relative, because
  /// that is what `status --porcelain=v2` returns and a path the caller read
  /// from [status] has to be usable in [stage]. A bare pathspec would be
  /// resolved against [workingDirectory] instead, which is the repository
  /// root only by accident: a space is a folder, not a repository, and `docs/`
  /// inside a code repository is the normal case, not the exotic one.
  ///
  /// `literal` on top of `top` because a document may legitimately be called
  /// `notes[draft].md`, and git reads `[` in a pathspec as a glob.
  static String _pathspec(String path) => ':(top,literal)$path';

  /// Runs a command whose output the caller does not need.
  Future<Result<void, GitClientFailure>> _gitVoid(
    List<String> arguments, {
    Duration? limit,
  }) async {
    final Result<String, GitClientFailure> result = await _git(
      arguments,
      limit: limit,
    );
    return result.map((_) {});
  }

  /// Queues [arguments] and hands back stdout, or a typed failure.
  Future<Result<String, GitClientFailure>> _git(
    List<String> arguments, {
    Duration? limit,
  }) => _enqueue(() => _run(arguments, limit ?? timeout));

  /// Chains [operation] onto the queue.
  ///
  /// The queue never carries a failure forward: one operation that somehow
  /// threw must not stop every later command in the space.
  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final Future<T> result = _queue.then((void _) => operation());
    _queue = result.then<void>((T _) {}).catchError((Object _) {});
    return result;
  }

  /// Starts git, collects both streams, and kills it if it outlives [limit].
  Future<Result<String, GitClientFailure>> _run(
    List<String> arguments,
    Duration limit,
  ) async {
    final String command = 'git ${arguments.join(' ')}';
    final Process process;
    try {
      process = await Process.start(
        'git',
        arguments,
        workingDirectory: workingDirectory,
        environment: _environment,
      );
    } on ProcessException {
      return Failure<String, GitClientFailure>(await _startFailure());
    }

    final Future<String> out = process.stdout.transform(_decoder).join();
    final Future<String> err = process.stderr.transform(_decoder).join();

    final int exitCode;
    try {
      exitCode = await process.exitCode.timeout(limit);
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      await _drain(out, err);
      return Failure<String, GitClientFailure>(
        GitClientTimedOut(command, limit),
      );
    }

    final String stdout = await out;
    final String stderr = await err;
    if (exitCode == 0) {
      return Success<String, GitClientFailure>(stdout);
    }
    final GitClientFailure failure = _translate(
      command,
      exitCode,
      stdout,
      stderr,
    );
    return Failure<String, GitClientFailure>(
      failure is GitClientMergeConflict ? await _named(failure) : failure,
    );
  }

  /// Why [Process.start] refused, without letting the probe throw.
  ///
  /// Two very different things arrive as a `ProcessException`: no `git` on
  /// the PATH, and a working directory git could not enter — a space whose
  /// folder was deleted or unmounted while it was open. Reporting the second
  /// as "git is not installed" would send the user to fix their machine over
  /// a missing folder.
  ///
  /// The probe can fail too: a parent the machine will not let TOM read
  /// answers neither yes nor no. That is still a folder TOM cannot open, and
  /// never a missing binary — and a `FileSystemException` escaping here is
  /// the one thing this package promises never to leak.
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
  /// Both futures keep their handlers whether or not this returns first, so a
  /// pipe that dies with the process cannot surface later as an unhandled
  /// asynchronous error.
  static Future<void> _drain(Future<String> out, Future<String> err) {
    final Future<void> closed = Future.wait<String>(<Future<String>>[
      out,
      err,
    ]).then<void>((List<String> _) {}).catchError((Object _) {});
    return closed.timeout(_drainGrace, onTimeout: () {});
  }

  /// [conflict] carrying the paths git's index reports, when it can be asked.
  ///
  /// The `CONFLICT (...)` lines have a shape per kind — `Merge conflict in
  /// the path` for a content clash, `the path deleted in ... and modified in
  /// ...` for modify/delete, two paths for rename/rename — so reading them off
  /// the message misses most of them and the product would announce a conflict
  /// listing no files. The index knows: `--diff-filter=U` is every path left
  /// conflicted, whatever produced it. What the message gave stands only if
  /// asking fails.
  Future<GitClientFailure> _named(GitClientMergeConflict conflict) async {
    final List<String> unmerged = await _unmergedPaths();
    return unmerged.isEmpty ? conflict : GitClientMergeConflict(unmerged);
  }

  /// Every path git left unmerged, relative to the repository root.
  ///
  /// Runs outside the queue on purpose: the caller is holding the queue slot
  /// it would wait for. `diff.relative` is forced off because a user who set
  /// it would otherwise get paths relative to [workingDirectory], which the
  /// contract does not allow.
  Future<List<String>> _unmergedPaths() async {
    final Result<String, GitClientFailure> unmerged = await _run(<String>[
      '-c',
      'diff.relative=false',
      'diff',
      '--name-only',
      '--diff-filter=U',
      '-z',
    ], timeout);
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
  /// The parent environment is kept — PATH, the SSH agent and the credential
  /// helper are the user's, which is the whole point of driving their binary.
  /// These are forced on top of it, and none changes what git does:
  /// no credential prompt nothing is there to answer, no index lock taken for
  /// a read TOM performs far more often than a person would, and messages in
  /// English so that recognising one below is not a bet on the user's locale.
  ///
  /// Suppressing the prompt takes all four: `GIT_TERMINAL_PROMPT` covers only
  /// the terminal, and git then falls through to `GIT_ASKPASS`, then to ssh's
  /// own `SSH_ASKPASS`. An askpass left reachable turns a missing credential
  /// into a dialog nobody is looking at, blocking for the whole
  /// [networkTimeout] instead of failing as [GitClientAuthenticationFailed].
  /// `GIT_SSH_COMMAND` is deliberately not set: it would override the user's
  /// own `core.sshCommand`, which is exactly the config this client exists to
  /// honour.
  static const Map<String, String> _environment = <String, String>{
    'GIT_TERMINAL_PROMPT': '0',
    'GIT_ASKPASS': '',
    'SSH_ASKPASS_REQUIRE': 'never',
    'GIT_OPTIONAL_LOCKS': '0',
    'LC_ALL': 'C',
  };

  /// Maps what the command reported to a [GitClientFailure].
  ///
  /// Recognition is by message, which git offers no alternative to — exit
  /// codes are 1 or 128 for nearly everything. Each pattern is anchored on
  /// wording git has kept stable for years, `LC_ALL=C` guarantees the
  /// language, and anything unrecognised falls back to
  /// [GitClientCommandFailed] rather than being guessed at.
  ///
  /// Both streams are read because the halves of a conflict arrive
  /// separately: the `CONFLICT` lines on stdout, `Automatic merge failed` on
  /// stderr.
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
    if (_pushRejected.hasMatch(output)) {
      return GitClientPushRejected(stderr);
    }
    if (_mergeConflict.hasMatch(output)) {
      return GitClientMergeConflict(<String>[
        for (final RegExpMatch match in _conflictedPath.allMatches(output))
          match.group(1)!.trim(),
      ]);
    }
    return GitClientCommandFailed(command, exitCode, stderr);
  }

  /// The folder is outside any repository.
  static final RegExp _notARepository = RegExp(
    'not a git repository',
    caseSensitive: false,
  );

  /// Git needed credentials and did not get usable ones.
  static final RegExp _authenticationFailed = RegExp(
    'authentication failed|could not read username|could not read password|'
    r'permission denied \(publickey|terminal prompts disabled|'
    'invalid username or password',
    caseSensitive: false,
  );

  /// A push lost the race to the remote.
  static final RegExp _pushRejected = RegExp(
    r'\[rejected\]|non-fast-forward|updates were rejected',
    caseSensitive: false,
  );

  /// A merge, rebase or pull stopped on conflicts.
  static final RegExp _mergeConflict = RegExp(
    'automatic merge failed|could not apply|^CONFLICT ',
    caseSensitive: false,
    multiLine: true,
  );

  /// The path named by one `CONFLICT (...): Merge conflict in <path>` line.
  ///
  /// The fallback behind [_unmergedPaths], and only that: it recognises the
  /// content conflict and none of the other kinds.
  static final RegExp _conflictedPath = RegExp(
    r'^CONFLICT \([^)]*\): Merge conflict in (.+)$',
    multiLine: true,
  );

  /// `HEAD` names no commit — the branch exists but carries none yet.
  ///
  /// Three phrasings for one state: `log` says the first, `rev-parse` the
  /// second, and `restore --staged` the third.
  static final RegExp _unbornHead = RegExp(
    r'does not have any commits yet|bad default revision'
    r"|could not resolve 'HEAD'",
    caseSensitive: false,
  );
}
