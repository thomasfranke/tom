/// Where every process the app runs is written down, behind a contract.
library;

import 'package:tom_core/src/command_record.dart';

/// What a capability tells about each process it ran.
///
/// A port, like [Observability](observability.dart): the capabilities that
/// start processes live in `tom_infra` and the list that shows them in
/// presentation, and neither may see the other. Kept for the session only
/// ([Decision 36](../../../../../docs/technical/decisions/036-every-command-is-written-down.md)).
abstract interface class CommandLog {
  /// Writes [record] down. Never throws: a list nobody reads must not turn a
  /// command that worked into one that failed.
  void record(CommandRecord record);
}

/// Writes down the process that was started when this was made, once it
/// ends: with its exit code, or null when it never ended on its own —
/// [ran] false when it could not be started at all.
typedef CommandEnded =
    void Function(int? exitCode, {Object? stdout, Object? stderr, bool ran});

/// The one way a capability times a process for its log.
extension CommandTiming on CommandLog {
  /// Starts the clock on [executable] with [arguments] and answers what
  /// records it — [secretOutput] and [answers] as [CommandRecord.of] reads
  /// them, declared by the caller that knows which exits it expects, and
  /// [ticket] the one the gate gave with its verdict.
  CommandEnded started(
    String executable,
    List<String> arguments, {
    bool secretOutput = false,
    Set<int> answers = const <int>{},
    int? ticket,
  }) {
    final DateTime startedAt = DateTime.now();
    final Stopwatch clock = Stopwatch()..start();
    return (int? exitCode, {Object? stdout, Object? stderr, bool ran = true}) =>
        record(
          CommandRecord.of(
            executable: executable,
            arguments: arguments,
            startedAt: startedAt,
            duration: clock.elapsed,
            exitCode: exitCode,
            stdout: '${stdout ?? ''}',
            stderr: '${stderr ?? ''}',
            secretOutput: secretOutput,
            answers: answers,
            ran: ran,
            ticket: ticket,
          ),
        );
  }
}
