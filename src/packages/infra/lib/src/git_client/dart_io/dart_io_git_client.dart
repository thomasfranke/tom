/// The `dart:io` implementation of [GitClient].
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/git_client/git_client.dart';
import 'package:tom_infra/src/git_client/git_client_failure.dart';

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
final class DartIoGitClient implements GitClient {
  /// Creates a client running git inside [workingDirectory].
  ///
  /// [workingDirectory] may sit below the repository root; git resolves
  /// upwards on its own and [repositoryRoot] reports where it landed.
  /// [timeout] bounds a local command, [networkTimeout] one that reaches a
  /// remote — without them a hung command stalls the whole queue, not one
  /// action.
  DartIoGitClient({
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
  Future<Result<String>> repositoryRoot() async {
    final Result<String> root = await _git(<String>[
      'rev-parse',
      '--show-toplevel',
    ]);
    return switch (root) {
      Success<String>(:final String value) => Success<String>(value.trim()),
      Failure<String>() => root,
    };
  }

  @override
  Future<Result<String>> status() => _git(<String>[
    'status',
    '--porcelain=v2',
    '--branch',
    '--untracked-files=all',
    '-z',
  ]);

  @override
  Future<Result<String>> log({String? path, int? limit}) => _git(<String>[
    'log',
    '--format=$_logFormat',
    if (limit != null) '--max-count=$limit',
    if (path != null) ...<String>['--', path],
  ]);

  @override
  Future<Result<String>> branches() =>
      _git(<String>['branch', '--format=$_branchFormat']);

  @override
  Future<Result<String>> show(String revision, String path) =>
      _git(<String>['show', '$revision:$path']);

  @override
  Future<Result<void>> stage(List<String> paths) =>
      _gitVoid(<String>['add', '--', ...paths]);

  @override
  Future<Result<void>> unstage(List<String> paths) =>
      _gitVoid(<String>['restore', '--staged', '--', ...paths]);

  @override
  Future<Result<void>> commit(String message) =>
      _gitVoid(<String>['commit', '--message', message]);

  @override
  Future<Result<void>> createBranch(String name) =>
      _gitVoid(<String>['switch', '--create', name]);

  @override
  Future<Result<void>> switchBranch(String name) =>
      _gitVoid(<String>['switch', name]);

  @override
  Future<Result<void>> fetch() =>
      _gitVoid(<String>['fetch'], limit: networkTimeout);

  @override
  Future<Result<void>> pull() =>
      _gitVoid(<String>['pull'], limit: networkTimeout);

  @override
  Future<Result<void>> push() =>
      _gitVoid(<String>['push'], limit: networkTimeout);

  /// Runs a command whose output the caller does not need.
  Future<Result<void>> _gitVoid(
    List<String> arguments, {
    Duration? limit,
  }) async {
    final Result<String> result = await _git(arguments, limit: limit);
    return switch (result) {
      Success<String>() => const Success<void>(null),
      Failure<String>(:final AppFailure failure) => Failure<void>(failure),
    };
  }

  /// Queues [arguments] and hands back stdout, or a typed failure.
  Future<Result<String>> _git(List<String> arguments, {Duration? limit}) =>
      _enqueue(() => _run(arguments, limit ?? timeout));

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
  Future<Result<String>> _run(List<String> arguments, Duration limit) async {
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
      // Two very different things arrive here: no `git` on the PATH, and a
      // working directory that is gone — a space whose folder was deleted or
      // unmounted while it was open. Reporting the second as "git is not
      // installed" would send the user to fix their machine over a missing
      // folder.
      return Directory(workingDirectory).existsSync()
          ? const Failure<String>(GitClientExecutableNotFound())
          : Failure<String>(GitClientNotARepository(workingDirectory));
    }

    final Future<String> out = process.stdout.transform(_decoder).join();
    final Future<String> err = process.stderr.transform(_decoder).join();

    final int exitCode;
    try {
      exitCode = await process.exitCode.timeout(limit);
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      await Future.wait<String>(<Future<String>>[out, err]);
      return Failure<String>(GitClientTimedOut(command, limit));
    }

    final String stdout = await out;
    final String stderr = await err;
    return exitCode == 0
        ? Success<String>(stdout)
        : Failure<String>(_translate(command, exitCode, stdout, stderr));
  }

  /// What git is run with, on top of the user's own environment.
  ///
  /// The parent environment is kept — PATH, the SSH agent and the credential
  /// helper are the user's, which is the whole point of driving their binary.
  /// These three are forced on top of it, and none changes what git does:
  /// no credential prompt nothing is there to answer, no index lock taken for
  /// a read TOM performs far more often than a person would, and messages in
  /// English so that recognising one below is not a bet on the user's locale.
  static const Map<String, String> _environment = <String, String>{
    'GIT_TERMINAL_PROMPT': '0',
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
  static final RegExp _conflictedPath = RegExp(
    r'^CONFLICT \([^)]*\): Merge conflict in (.+)$',
    multiLine: true,
  );
}
