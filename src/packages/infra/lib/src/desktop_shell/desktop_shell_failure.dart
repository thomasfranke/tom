/// What asking the desktop to open a folder can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'desktop_shell_failure.freezed.dart';

/// The desktop did not open what it was asked to.
@freezed
sealed class DesktopShellFailure
    with _$DesktopShellFailure
    implements AppFailure {
  /// The program that would open it is not on this machine.
  const factory DesktopShellFailure.unavailable(
    /// The program that was looked for.
    String program, {
    AppFailure? cause,
  }) = DesktopShellUnavailable;

  /// The program started and refused, or could not be started.
  const factory DesktopShellFailure.operationFailed(
    /// What it said, verbatim. For diagnostics — never parsed.
    String description, {
    AppFailure? cause,
  }) = DesktopShellOperationFailed;
}
