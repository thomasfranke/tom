/// What the commands panel lists.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_presentation/src/commands/command_action_enum.dart';
import 'package:tom_presentation/src/commands/command_row.dart';

part 'commands_state.freezed.dart';

/// The commands of this session, oldest first, which of them are open, and
/// which wait for somebody to say yes
/// (`docs/product/workspace/commands/doc.md`,
/// `docs/product/git-workflow/approvals/doc.md`).
@freezed
abstract class CommandsState with _$CommandsState {
  /// Creates the state.
  const factory CommandsState({
    /// The last `CommandsNotifier.kept` commands, oldest first.
    @Default(<CommandRow>[]) List<CommandRow> rows,

    /// How many ran this session, the dropped ones included.
    @Default(0) int total,

    /// The rows showing their output, by [CommandRow.id].
    @Default(<int>{}) Set<int> expanded,

    /// The row the panel is asked to scroll to, until it has.
    int? revealing,

    /// The row whose `Always allow` was pressed in Manual, while the
    /// question it raises — switch to Semi-automatic? — is unanswered.
    int? pendingSwitch,
  }) = _CommandsState;

  const CommandsState._();

  /// How many commands wait — for the person, or for the one above them.
  int get waiting => rows
      .where((CommandRow row) => row.stage == CommandStageEnum.waiting)
      .length;

  /// The rows of [plan], in the order they were asked.
  List<CommandRow> planOf(int plan) =>
      rows.where((CommandRow row) => row.plan == plan).toList();

  /// How many of [plan]'s commands ran to their end — the `N` of
  /// `stopped · N of M ran`, [planOf]'s length being the `M`.
  int ranIn(int plan) => rows
      .where(
        (CommandRow row) =>
            row.plan == plan && row.stage == CommandStageEnum.ended,
      )
      .length;

  /// Whether [plan] was stopped by a refusal.
  bool isStopped(int plan) => rows.any(
    (CommandRow row) =>
        row.plan == plan && row.stage == CommandStageEnum.denied,
  );

  /// Whether [row] is the one of its plan the person can answer now: its
  /// first command still to run, with nothing before it still running. The
  /// rows under it wait for it.
  bool isApprovable(CommandRow row) {
    if (row.stage != CommandStageEnum.waiting || row.plan == null) {
      return false;
    }
    for (final CommandRow other in rows) {
      if (other.plan != row.plan) {
        continue;
      }
      if (other.id == row.id) {
        return true;
      }
      if (!other.stage.isOver) {
        return false;
      }
    }
    return false;
  }

  /// Whether a command of [action] waits: what the control that was pressed
  /// says instead of its verb.
  bool isWaitingOn(CommandActionEnum action) => rows.any(
    (CommandRow row) =>
        row.action == action && row.stage == CommandStageEnum.waiting,
  );

  /// Whether a command of [action] is running now.
  bool isRunning(CommandActionEnum action) => rows.any(
    (CommandRow row) =>
        row.action == action && row.stage == CommandStageEnum.running,
  );
}
