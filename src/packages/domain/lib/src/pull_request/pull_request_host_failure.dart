/// What asking the host about a pull request can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'pull_request_host_failure.freezed.dart';

/// The host could not be asked, or did not do what was asked.
@freezed
sealed class PullRequestHostFailure
    with _$PullRequestHostFailure
    implements AppFailure {
  /// There is no way to ask: `gh` is not installed, the account holds no
  /// token, or the host is not GitHub — so the page keeps its link to the
  /// host's own page
  /// (`docs/product/git-workflow/pull-request/opening-it/doc.md`).
  const factory PullRequestHostFailure.unavailable({AppFailure? cause}) =
      PullRequestHostUnavailable;

  /// The host could not be reached.
  const factory PullRequestHostFailure.unreachable({AppFailure? cause}) =
      PullRequestHostUnreachable;

  /// The host refused the account's token.
  const factory PullRequestHostFailure.refused({AppFailure? cause}) =
      PullRequestHostRefused;

  /// The person refused the command that would have asked the host
  /// (`docs/product/git-workflow/approvals/doc.md`): nothing was sent, and
  /// nothing is said about it.
  @Implements<CommandDenial>()
  const factory PullRequestHostFailure.denied({AppFailure? cause}) =
      PullRequestHostDenied;

  /// The host answered something else.
  const factory PullRequestHostFailure.operationFailed({AppFailure? cause}) =
      PullRequestHostOperationFailed;
}
