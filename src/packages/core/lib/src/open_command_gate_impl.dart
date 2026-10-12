/// The gate nobody stands at.
library;

import 'package:tom_core/src/command_gate.dart';
import 'package:tom_core/src/command_request.dart';

/// The [CommandGate] that lets everything through — what a capability asks
/// when nobody gave it one, so a test or a tool never has to.
final class OpenCommandGateImpl implements CommandGate {
  /// Creates the gate.
  const OpenCommandGateImpl();

  @override
  CommandPlan plan(List<CommandRequest> commands) => const _OpenPlan();
}

final class _OpenPlan implements CommandPlan {
  const _OpenPlan();

  @override
  Future<CommandVerdict> next() =>
      Future<CommandVerdict>.value(const CommandVerdict.run());

  @override
  void close() {}
}
