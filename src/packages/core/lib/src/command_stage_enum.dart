/// Where a command is between being asked for and having ended.
library;

/// The stages a command passes through once somebody may have to say yes
/// before it runs ([Decision 38](../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
enum CommandStageEnum {
  /// Asked for, not started: somebody has to say yes, or a command before
  /// it in the same plan has to end first.
  waiting,

  /// Started, and not ended yet.
  running,

  /// Ended, or could not start — how is the record's exit code.
  ended,

  /// Refused by the person; it never started.
  denied,

  /// Never started because a command before it in its plan was refused or
  /// failed.
  cancelled;

  /// Whether nothing more will happen to the command.
  bool get isOver => this == ended || this == denied || this == cancelled;
}
