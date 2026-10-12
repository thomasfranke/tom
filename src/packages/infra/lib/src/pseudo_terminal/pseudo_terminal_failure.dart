/// What starting a shell in a pseudo-terminal can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'pseudo_terminal_failure.freezed.dart';

/// The shell did not start.
@freezed
sealed class PseudoTerminalFailure
    with _$PseudoTerminalFailure
    implements AppFailure {
  /// The shell the person uses is not where the machine says it is.
  const factory PseudoTerminalFailure.unavailable(
    /// The executable that was looked for.
    String shell, {
    AppFailure? cause,
  }) = PseudoTerminalUnavailable;

  /// The pseudo-terminal could not be opened, or the shell not started in it.
  const factory PseudoTerminalFailure.startFailed(
    /// What the platform said, verbatim. For diagnostics — never parsed.
    String description, {
    AppFailure? cause,
  }) = PseudoTerminalStartFailed;
}
