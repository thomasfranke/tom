/// What reading a GitHub account can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'account_failure.freezed.dart';

/// GitHub, or the tools that hold a login, did not say.
///
/// None of these is shown as an error: the popover's answer to each is that
/// nothing is known (`docs/product/workspace/the-account/doc.md`).
@freezed
sealed class AccountFailure with _$AccountFailure implements AppFailure {
  /// GitHub could not be reached.
  const factory AccountFailure.unreachable({AppFailure? cause}) =
      AccountUnreachable;

  /// GitHub refused the token the machine holds.
  const factory AccountFailure.refused({AppFailure? cause}) = AccountRefused;

  /// The person refused the command that would have asked
  /// (`docs/product/git-workflow/approvals/doc.md`): nothing is known, and
  /// nothing went wrong.
  @Implements<CommandDenial>()
  const factory AccountFailure.denied({AppFailure? cause}) = AccountDenied;

  /// A tool or GitHub answered something else.
  const factory AccountFailure.operationFailed({AppFailure? cause}) =
      AccountOperationFailed;
}
