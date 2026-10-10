/// The `gh` implementation of [GithubApi].
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/github_api/github_api.dart';
import 'package:tom_infra/src/github_api/github_api_failure.dart';
import 'package:tom_infra/src/github_api/github_command_key_enum.dart';

/// Runs [executable] with [arguments] and [environment] over the
/// implementation's own, in [workingDirectory] and writing [input] to it,
/// and answers once it ends.
typedef GhRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      required Map<String, String> environment,
      String? input,
      String? workingDirectory,
    });

/// Asks GitHub through `gh`, so TOM holds no HTTP client and no account of
/// its own ([Decision
/// 35](../../../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
///
/// **The token travels in `GH_TOKEN`, never in an argument**: an argument
/// is what a process list, and the app's own list of the commands it ran,
/// shows anybody — and `GH_TOKEN` is per call, so the account `gh` has
/// active is never switched. A pull request's body goes on the input, for
/// the same reason and because it may be long.
final class GhCliGithubApiImpl implements GithubApi {
  /// Creates the implementation; [run] is the seam the tests answer through.
  GhCliGithubApiImpl({
    this.host = 'github.com',
    this.environment = const <String, String>{},
    this.includeParentEnvironment = true,
    this.timeout = const Duration(seconds: 15),
    this.commandLog = const SilentCommandLog(),
    this.commandGate = const OpenCommandGateImpl(),
    GhRunner? run,
  }) {
    _runner = run ?? _run;
  }

  /// The host `gh` asks.
  final String host;

  /// Where every request is written down once it ends — its arguments,
  /// never the environment the token travels in.
  final CommandLog commandLog;

  /// What says whether a request may start, asked before every one of them
  /// ([Decision 38](../../../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
  final CommandGate commandGate;

  /// What `gh` is started with, over the app's own.
  final Map<String, String> environment;

  /// Whether the app's own environment is inherited at all.
  final bool includeParentEnvironment;

  /// How long one request may take before `gh` is killed.
  final Duration timeout;

  late final GhRunner _runner;

  @override
  Future<Result<String, GithubApiFailure>> repository(
    String path, {
    required String token,
  }) => _gh(GithubCommandKeyEnum.repository, <String>[
    'api',
    '--hostname',
    host,
    'repos/$path',
  ], token);

  @override
  Future<Result<String, GithubApiFailure>> openPullRequests(
    String folder, {
    required String repository,
    required String head,
    required String token,
  }) => _gh(
    GithubCommandKeyEnum.openPullRequests,
    <String>[
      'pr',
      'list',
      '--repo',
      '$host/$repository',
      '--head',
      head,
      '--state',
      'open',
      '--json',
      'number,url,title',
    ],
    token,
    workingDirectory: folder,
  );

  @override
  Future<Result<String, GithubApiFailure>> createPullRequest(
    String folder, {
    required String repository,
    required String base,
    required String head,
    required String title,
    required String body,
    required String token,
  }) async {
    final Result<String, GithubApiFailure> created = await _gh(
      GithubCommandKeyEnum.createPullRequest,
      <String>[
        'pr',
        'create',
        '--repo',
        '$host/$repository',
        '--base',
        base,
        '--head',
        head,
        '--title',
        title,
        '--body-file',
        '-',
      ],
      token,
      input: body,
      workingDirectory: folder,
    );
    return switch (created) {
      Success<String, GithubApiFailure>(value: final String printed) =>
        Success<String, GithubApiFailure>(printed.trim()),
      // `gh` names the one already open on its error stream.
      Failure<String, GithubApiFailure>(
        failure: GithubApiOperationFailed(:final String description),
      )
          when _exists.hasMatch(description) =>
        Failure<String, GithubApiFailure>(
          GithubApiPullRequestExists(
            _address.firstMatch(description)?.group(0) ?? '',
          ),
        ),
      Failure<String, GithubApiFailure>() => created,
    };
  }

  /// Asks the gate, then runs `gh` with [arguments] as [token] — the gate
  /// first, so nobody's reading time counts toward [timeout].
  Future<Result<String, GithubApiFailure>> _gh(
    GithubCommandKeyEnum key,
    List<String> arguments,
    String token, {
    String? input,
    String? workingDirectory,
  }) async {
    final CommandRequest request = CommandRequest.of(
      key: key,
      executable: 'gh',
      arguments: arguments,
    );
    final int? ticket;
    switch (await commandGate.ask(request)) {
      case CommandRun(ticket: final int? given):
        ticket = given;
      case CommandDenied():
        return Failure<String, GithubApiFailure>(
          GithubApiCommandDenied(request.commandLine),
        );
    }
    final CommandEnded ended = commandLog.started(
      'gh',
      arguments,
      ticket: ticket,
    );
    final ProcessResult result;
    try {
      result = await _runner(
        'gh',
        arguments,
        environment: <String, String>{
          'GH_TOKEN': token,
          'GH_PROMPT_DISABLED': '1',
          'GH_NO_UPDATE_NOTIFIER': '1',
          'LC_ALL': 'C',
        },
        input: input,
        workingDirectory: workingDirectory,
      );
      ended(result.exitCode, stdout: result.stdout, stderr: result.stderr);
    } on TimeoutException {
      ended(null);
      return const Failure<String, GithubApiFailure>(
        GithubApiUnreachable('timed out'),
      );
    } on ProcessException catch (error) {
      ended(null, stderr: error.message, ran: false);
      return Failure<String, GithubApiFailure>(
        error.errorCode == 2
            ? const GithubApiUnavailable('gh')
            : GithubApiOperationFailed('gh: ${error.message}'),
      );
    }
    if (result.exitCode == 0) {
      return Success<String, GithubApiFailure>('${result.stdout}');
    }
    final String said = '${result.stderr}'.trim();
    final int? status = int.tryParse(_status.firstMatch(said)?.group(1) ?? '');
    return Failure<String, GithubApiFailure>(switch (status) {
      401 || 403 => GithubApiRefused(status!),
      404 => const GithubApiNotFound(),
      null when _offline.hasMatch(said) => GithubApiUnreachable(said),
      _ => GithubApiOperationFailed(said),
    });
  }

  /// `gh: Not Found (HTTP 404)`.
  static final RegExp _status = RegExp(r'\(HTTP (\d{3})\)');

  /// What `gh` says when the connection, not GitHub, answered.
  static final RegExp _offline = RegExp(
    'error connecting|no such host|timeout|network is unreachable',
    caseSensitive: false,
  );

  /// `a pull request for branch "x" into branch "main" already exists:`.
  static final RegExp _exists = RegExp(
    'pull request for branch .* already exists',
  );

  /// The address `gh` names after it.
  static final RegExp _address = RegExp(r'https?://\S+');

  Future<ProcessResult> _run(
    String executable,
    List<String> arguments, {
    required Map<String, String> environment,
    String? input,
    String? workingDirectory,
  }) async {
    final Process process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: <String, String>{...this.environment, ...environment},
      includeParentEnvironment: includeParentEnvironment,
    );
    if (input != null) {
      process.stdin.add(utf8.encode(input));
    }
    unawaited(process.stdin.close().catchError((Object _) {}));
    final Future<String> out = process.stdout.transform(utf8.decoder).join();
    final Future<String> err = process.stderr.transform(utf8.decoder).join();
    final int code;
    try {
      code = await process.exitCode.timeout(timeout);
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      rethrow;
    }
    return ProcessResult(process.pid, code, await out, await err);
  }
}
