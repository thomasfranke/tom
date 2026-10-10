/// The command-line implementation of [Credentials].
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/credentials/credentials.dart';
import 'package:tom_infra/src/credentials/credentials_command_key_enum.dart';
import 'package:tom_infra/src/credentials/credentials_failure.dart';

/// Runs [executable] with [arguments], writing [input] to it, and answers
/// once it ends.
typedef CredentialsRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? input,
      String? workingDirectory,
    });

/// Asks the person's own `gh`, `git` and `ssh`, with nothing to answer a
/// question on: no terminal, no askpass, batch mode.
///
/// [environment] is laid over the app's, or replaces it when
/// [includeParentEnvironment] is false — which is how an end-to-end run
/// keeps the machine's real logins out of reach.
final class CommandLineCredentialsImpl implements Credentials {
  /// Creates the implementation; [run] is the seam the tests answer through.
  CommandLineCredentialsImpl({
    this.environment = const <String, String>{},
    this.includeParentEnvironment = true,
    this.timeout = const Duration(seconds: 10),
    this.commandLog = const SilentCommandLog(),
    this.commandGate = const OpenCommandGateImpl(),
    CredentialsRunner? run,
  }) {
    _runner = run ?? _run;
  }

  /// What every program is started with, over the app's own.
  final Map<String, String> environment;

  /// Where every program is written down once it ends — the two whose
  /// answer is a credential with that answer hidden.
  final CommandLog commandLog;

  /// What says whether git or `gh` may start; `ssh` is never asked about
  /// ([Decision 38](../../../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
  final CommandGate commandGate;

  /// Whether the app's own environment is inherited at all.
  final bool includeParentEnvironment;

  /// How long one program may take before it is killed.
  final Duration timeout;

  late final CredentialsRunner _runner;

  /// What makes every one of them refuse rather than ask.
  static const Map<String, String> _noQuestions = <String, String>{
    'GIT_TERMINAL_PROMPT': '0',
    'GIT_ASKPASS': '',
    'SSH_ASKPASS_REQUIRE': 'never',
    'GH_PROMPT_DISABLED': '1',
    'GH_NO_UPDATE_NOTIFIER': '1',
    'LC_ALL': 'C',
  };

  @override
  Future<Result<String, CredentialsFailure>> ghAccounts(String host) async {
    // Exit 1 is "nobody is signed in", an answer like any other.
    final Result<ProcessResult?, CredentialsFailure> json = await _ask(
      'gh',
      <String>['auth', 'status', '--hostname', host, '--json', 'hosts'],
      key: CredentialsCommandKeyEnum.ghAccounts,
      answers: const <int>{1},
    );
    if (json case Success<ProcessResult?, CredentialsFailure>(
      value: final ProcessResult result,
    ) when '${result.stderr}'.contains('unknown flag')) {
      // A `gh` from before `--json`: its report, whichever stream it used.
      return (await _ask(
        'gh',
        <String>['auth', 'status', '--hostname', host],
        key: CredentialsCommandKeyEnum.ghAccountsAsText,
        answers: const <int>{1},
      )).map(
        (ProcessResult? text) =>
            text == null ? '' : '${text.stdout}\n${text.stderr}'.trim(),
      );
    }
    return json.map((ProcessResult? result) => '${result?.stdout ?? ''}');
  }

  @override
  Future<Result<String, CredentialsFailure>> ghToken(
    String host,
    String login,
  ) async => (await _ask(
    'gh',
    <String>['auth', 'token', '--hostname', host, '--user', login],
    key: CredentialsCommandKeyEnum.ghToken,
    secretOutput: true,
    answers: const <int>{1},
  )).map(_printedOnSuccess);

  @override
  Future<Result<String, CredentialsFailure>> gitCredential(
    String host, {
    required String folder,
  }) async => (await _ask(
    'git',
    <String>['-c', 'credential.interactive=false', 'credential', 'fill'],
    key: CredentialsCommandKeyEnum.gitCredential,
    input: 'protocol=https\nhost=$host\n\n',
    workingDirectory: folder,
    secretOutput: true,
    // 128 is git's "it would have had to ask": no credential, an answer.
    answers: const <int>{1, 128},
  )).map(_printedOnSuccess);

  @override
  Future<Result<String, CredentialsFailure>> sshGreeting(String host) async =>
      (await _ask(
        'ssh',
        <String>[
          '-T',
          '-o',
          'BatchMode=yes',
          '-o',
          'ConnectTimeout=5',
          'git@$host',
          // GitHub greets a key it knows and exits 1; 255 is no key it knows.
        ],
        answers: const <int>{1, 255},
      )).map((ProcessResult? result) => '${result?.stderr ?? ''}'.trim());

  /// What it printed when it worked; a refusal is "nothing here", and its
  /// output is never carried, because a refusal's output may be a secret.
  static String _printedOnSuccess(ProcessResult? result) =>
      result == null || result.exitCode != 0 ? '' : '${result.stdout}'.trim();

  /// [executable]'s result, or null when it is not installed — written down
  /// either way, its output hidden when it is [secretOutput] and the exits
  /// in [answers] drawn as answers rather than errors.
  ///
  /// With a [key] the gate is asked first, before the program and its timer
  /// start; `ssh` has none and is never asked about.
  Future<Result<ProcessResult?, CredentialsFailure>> _ask(
    String executable,
    List<String> arguments, {
    CredentialsCommandKeyEnum? key,
    String? input,
    String? workingDirectory,
    bool secretOutput = false,
    Set<int> answers = const <int>{},
  }) async {
    int? ticket;
    if (key != null) {
      final CommandRequest request = CommandRequest.of(
        key: key,
        executable: executable,
        arguments: arguments,
      );
      switch (await commandGate.ask(request)) {
        case CommandRun(ticket: final int? given):
          ticket = given;
        case CommandDenied():
          return Failure<ProcessResult?, CredentialsFailure>(
            CredentialsCommandDenied(request.commandLine),
          );
      }
    }
    final CommandEnded ended = commandLog.started(
      executable,
      arguments,
      secretOutput: secretOutput,
      answers: answers,
      ticket: ticket,
    );
    try {
      final ProcessResult result = await _runner(
        executable,
        arguments,
        input: input,
        workingDirectory: workingDirectory,
      );
      ended(result.exitCode, stdout: result.stdout, stderr: result.stderr);
      return Success<ProcessResult?, CredentialsFailure>(result);
    } on TimeoutException {
      ended(null);
      return Failure<ProcessResult?, CredentialsFailure>(
        CredentialsTimedOut(executable),
      );
    } on ProcessException catch (error) {
      ended(null, stderr: error.message, ran: false);
      // ENOENT on every platform `dart:io` runs on: not installed.
      return error.errorCode == 2
          ? const Success<ProcessResult?, CredentialsFailure>(null)
          : Failure<ProcessResult?, CredentialsFailure>(
              CredentialsOperationFailed('$executable: ${error.message}'),
            );
    }
  }

  /// Starts [executable], hands it [input], and kills it past [timeout].
  Future<ProcessResult> _run(
    String executable,
    List<String> arguments, {
    String? input,
    String? workingDirectory,
  }) async {
    final Process process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: <String, String>{...environment, ..._noQuestions},
      includeParentEnvironment: includeParentEnvironment,
    );
    if (input != null) {
      process.stdin.write(input);
    }
    // Closed at once: a program waiting on its input is a program that
    // would have asked.
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
