/// Asking before a process runs, behind a contract.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/src/app_failure.dart';
import 'package:tom_core/src/command_request.dart';

part 'command_gate.freezed.dart';

/// What a capability asks before it starts git or `gh`, and waits on.
///
/// A port beside [CommandLog](command_log.dart), for the same reason: the
/// capabilities are in `tom_infra`, whoever says yes is in presentation, and
/// neither may see the other ([Decision 38](../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
/// **Asked before the process and its timer start**, so nobody's reading
/// time counts toward a timeout.
abstract interface class CommandGate {
  /// Says what is about to run — [commands], the one or the several one
  /// method runs, in order — and answers where each verdict is waited on.
  CommandPlan plan(List<CommandRequest> commands);
}

/// The commands one method declared together, approved top down.
abstract interface class CommandPlan {
  /// The verdict on the plan's next command, in the order it was declared.
  ///
  /// Asked when the command is about to start, never ahead: the one before
  /// it has ended by then.
  Future<CommandVerdict> next();

  /// Ends the plan before its last command — one of them failed — so what
  /// was still to run is cancelled rather than left waiting.
  void close();
}

/// What the gate says about one command.
@freezed
sealed class CommandVerdict with _$CommandVerdict {
  /// It may start now.
  const factory CommandVerdict.run({
    /// What the gate knows this command by, handed back with its record so
    /// the list that asked finds its own row; null when nothing waited.
    int? ticket,
  }) = CommandRun;

  /// It must not start, and neither may the rest of its plan.
  const factory CommandVerdict.denied() = CommandDenied;
}

/// A failure that is somebody saying no to a command, in any vocabulary.
///
/// A marker each hierarchy's own denial implements, so what stops quietly
/// can be told from what went wrong without naming every hierarchy.
abstract interface class CommandDenial implements AppFailure {}

/// Whether a failure is a refusal somewhere down its chain.
extension DenialInChain on AppFailure {
  /// True when this failure or anything it was translated from is a
  /// [CommandDenial]: nothing broke, and nothing is to be reported.
  bool get isDenial => this is CommandDenial || (cause?.isDenial ?? false);
}

/// The one way a capability asks about a single command.
extension CommandAsking on CommandGate {
  /// The verdict on [command], a plan of one.
  Future<CommandVerdict> ask(CommandRequest command) =>
      plan(<CommandRequest>[command]).next();
}
