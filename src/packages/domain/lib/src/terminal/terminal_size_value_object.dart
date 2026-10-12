/// How big a terminal's screen is, in characters.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'terminal_size_value_object.freezed.dart';

/// The screen a shell draws on: what the panel can hold at its font.
@freezed
abstract class TerminalSizeValueObject with _$TerminalSizeValueObject {
  /// A screen [columns] wide and [rows] tall, at least one of each.
  @Assert('columns > 0 && rows > 0', 'a screen holds at least one cell')
  const factory TerminalSizeValueObject({
    /// Characters across.
    required int columns,

    /// Lines down.
    required int rows,
  }) = _TerminalSizeValueObject;
}
