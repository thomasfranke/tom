/// What stands between the branch and its pull request.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

part 'pull_request_status.freezed.dart';

/// The status row's sentence, in the order it is checked
/// (`docs/product/git-workflow/pull-request/when-it-cannot-be-opened/doc.md`).
///
/// Uncommitted work comes first because it is a guard: both actions go
/// unavailable under it. A branch with commits the remote lacks comes next,
/// and carries `Push`, the one action that can happen where it stands.
@freezed
sealed class PullRequestStatus with _$PullRequestStatus {
  /// Nothing stands in the way.
  const factory PullRequestStatus.ready({required int commits}) =
      PullRequestReady;

  /// [documents] are not committed, so they would not be in it.
  const factory PullRequestStatus.uncommitted({required int documents}) =
      PullRequestUncommitted;

  /// [commits] are not on the remote yet — all of them when the branch has
  /// no upstream.
  const factory PullRequestStatus.unpublished({
    required int commits,
    required bool hasUpstream,
  }) = PullRequestUnpublished;

  /// The draft has no first heading, so there is no title to open it with.
  const factory PullRequestStatus.untitled() = PullRequestUntitled;

  /// The branch has nothing over its base.
  const factory PullRequestStatus.empty() = PullRequestEmpty;

  /// The host already has pull request [number] open from this branch.
  const factory PullRequestStatus.alreadyOpen({required int number}) =
      PullRequestAlreadyOpen;

  /// `Create pull request` was pressed and the host did not open one.
  const factory PullRequestStatus.notCreated({required AppFailure failure}) =
      PullRequestNotCreated;

  /// Git has not answered yet; nothing is offered until it has.
  const factory PullRequestStatus.reading() = PullRequestReading;

  /// Git could not read the branch against its base.
  const factory PullRequestStatus.failed() = PullRequestFailed;

  const PullRequestStatus._();

  /// [git], [proposal] and the draft's [title] as the row's state; [failed]
  /// when the last reading did not come back, [notCreated] when the last
  /// press did not open it, and [opened] the number the host already has.
  ///
  /// One already open comes after the branch's own news — work to commit or
  /// to push still changes what it shows — and before the title, which it no
  /// longer needs.
  static PullRequestStatus of({
    required GitStatusValueObject? git,
    required BranchProposalValueObject? proposal,
    required String? title,
    bool failed = false,
    AppFailure? notCreated,
    int? opened,
  }) {
    if (failed) {
      return const PullRequestStatus.failed();
    }
    if (notCreated != null) {
      return PullRequestStatus.notCreated(failure: notCreated);
    }
    if (git != null && git.entries.isNotEmpty) {
      return PullRequestStatus.uncommitted(documents: git.entries.length);
    }
    if (proposal == null) {
      return const PullRequestStatus.reading();
    }
    final int commits = proposal.commits.length;
    if (commits == 0) {
      return const PullRequestStatus.empty();
    }
    if (git != null && (git.upstream == null || git.ahead > 0)) {
      return PullRequestStatus.unpublished(
        commits: git.upstream == null ? commits : git.ahead,
        hasUpstream: git.upstream != null,
      );
    }
    if (opened != null) {
      return PullRequestStatus.alreadyOpen(number: opened);
    }
    if (title == null) {
      return const PullRequestStatus.untitled();
    }
    return PullRequestStatus.ready(commits: commits);
  }

  /// Whether the action that opens it may be pressed.
  bool get canOpen => this is PullRequestReady;
}
