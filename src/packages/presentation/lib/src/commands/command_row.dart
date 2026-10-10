/// One row of the commands panel.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_presentation/src/commands/command_action_enum.dart';

part 'command_row.freezed.dart';

/// A [record] and the number it was given when it arrived.
///
/// The number, not the position, is the row's identity: the list drops its
/// oldest rows, so a position names a different command a moment later. It
/// is also the row's ticket at the gate, so a command is the same row before
/// and after it runs.
@freezed
abstract class CommandRow with _$CommandRow {
  /// Creates the row.
  const factory CommandRow({
    /// Counted from the first command of the session, never reused.
    required int id,

    /// What ran, is running or waits to.
    required CommandRecord record,

    /// The plan it was asked in — the commands one method declared, or one
    /// action ran — or null for a command nobody could be asked about.
    int? plan,

    /// What the plan is called, or null when it was asked outside any
    /// action.
    CommandActionEnum? action,

    /// The command's key, as `git-approvals.json` spells it; null with
    /// [plan].
    String? key,

    /// Whether the command changes something rather than only reading.
    @Default(false) bool isWrite,

    /// Whether it runs without the person saying yes: the list allows it,
    /// or the mode no longer asks. What the row says before its time.
    @Default(false) bool isAllowed,
  }) = _CommandRow;

  const CommandRow._();

  /// Where the command is between asked for and ended.
  CommandStageEnum get stage => record.stage;
}
