/// The `dart:io` implementation of [GitClient].
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

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
  });

  /// The folder every command runs inside.
  final String workingDirectory;

  /// How long a local command may take before it is killed.
  final Duration timeout;

  /// How long a command reaching a remote may take before it is killed.
  final Duration networkTimeout;

  /// The tail of the serialized queue.
  ///
  /// Every operation chains onto it, so two commands cannot race for the
  /// index lock on one instance.
  Future<void> _queue = Future<void>.value();

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
  Future<Result<String, GitClientFailure>> branches() =>
      _git(<String>['branch', '--format=$_branchFormat']);

  @override
  Future<Result<String, GitClientFailure>> show(
    String revision,
    String path,
  ) async {
    final Result<String, GitClientFailure> result = await _git(<String>[
      'show',
      '$revision:$path',
    ]);
    // Recognised here rather than in `_translate`, which is handed the command
    // line and not its two halves.
    return switch (result) {
      Failure<String, GitClientFailure>(
        failure: GitClientCommandFailed(:final String stderr),
      )
          when _pathNotInRevision.hasMatch(stderr) =>
        Failure<String, GitClientFailure>(
          GitClientPathNotInRevision(revision, path, cause: result.failure),
        ),
      _ => result,
    };
  }

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
    // `restore --staged` rebuilds the index from `HEAD`, which is fatal before
    // the first commit; every staged path is an addition there, so taking it
    // back out of the index is what unstaging means. `--ignore-unmatch` keeps
    // both branches succeeding on a path that was not staged.
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
      // `--no-rebase`: a bare `git pull` fails on divergent branches unless
      // `pull.rebase` or `pull.ff` is set, and the choice is the product's.
      // Merge, because the app promises that nothing committed is lost and a
      // rebase can stop halfway (`docs/product/git-workflow/push-pull/doc.md`).
      _gitVoid(<String>['pull', '--no-rebase'], limit: networkTimeout);

  @override
  Future<Result<void, GitClientFailure>> push() =>
      _gitVoid(<String>['push'], limit: networkTimeout);

  /// [path], as a pathspec git resolves from the repository root.
  ///
  /// A bare pathspec resolves against [workingDirectory], which is the root
  /// only by accident; `top` keeps a path read from [status] usable in
  /// [stage]. `literal` because git reads `[` in a pathspec as a glob.
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
  /// The queue never carries a failure forward, so one operation that threw
  /// cannot stop every later command in the space.
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
  static Future<void> _drain(Future<String> out, Future<String> err) {
    final Future<void> closed = Future.wait<String>(<Future<String>>[
      out,
      err,
    ]).then<void>((List<String> _) {}).catchError((Object _) {});
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
  /// root-relative paths, as the contract requires.
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
  /// The parent environment stays: PATH, agent and credential helper are the
  /// user's. Suppressing the prompt takes all three prompt variables, because
  /// git falls through from the terminal to `GIT_ASKPASS` to ssh's own
  /// `SSH_ASKPASS`, and one left reachable blocks for the whole
  /// [networkTimeout] instead of failing as [GitClientAuthenticationFailed].
  /// `GIT_OPTIONAL_LOCKS=0` because TOM reads far more often than a person;
  /// `LC_ALL=C` so the patterns below are not a bet on the locale.
  /// `GIT_SSH_COMMAND` stays unset: it would override `core.sshCommand`.
  static const Map<String, String> _environment = <String, String>{
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
    "|invalid object name '?HEAD'?",
    caseSensitive: false,
  );

  /// `HEAD` names no commit yet: `log` says the first, `rev-parse` the
  /// second, `restore --staged` the third.
  static final RegExp _unbornHead = RegExp(
    r'does not have any commits yet|bad default revision'
    r"|could not resolve 'HEAD'",
    caseSensitive: false,
  );
}
