/// What asking the machine for a GitHub login can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'credentials_failure.freezed.dart';

/// A program that holds a login did not answer.
///
/// A program that is not installed is not one of these: it holds no login,
/// which is an answer (`Credentials`).
@freezed
sealed class CredentialsFailure
    with _$CredentialsFailure
    implements AppFailure {
  /// [program] outlived the time it was given and was killed.
  const factory CredentialsFailure.timedOut(
    /// The program that was asked.
    String program, {
    AppFailure? cause,
  }) = CredentialsTimedOut;

  /// The question was refused before the program started: somebody said no
  /// at the gate. Nothing ran, and nothing is wrong.
  @Implements<CommandDenial>()
  const factory CredentialsFailure.commandDenied(
    /// The command as it would have run.
    String command, {
    AppFailure? cause,
  }) = CredentialsCommandDenied;

  /// The program could not be started, or failed in a way that is not "no
  /// login".
  const factory CredentialsFailure.operationFailed(
    /// What it said on its error stream — never what it printed, which may be
    /// a secret.
    String description, {
    AppFailure? cause,
  }) = CredentialsOperationFailed;
}
