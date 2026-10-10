/// What the pull request page knows.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/pull_request/pull_request_availability_enum.dart';
import 'package:tom_presentation/src/pull_request/pull_request_segment_enum.dart';

part 'pull_request_state.freezed.dart';

/// Where a pull request would go, and — while the page is up — what the
/// branch proposes and what it did.
///
/// Which branch and which base are the session's
/// (`SpaceSessionState.pullRequest`); this holds only what was read for
/// them.
@freezed
abstract class PullRequestState with _$PullRequestState {
  /// A state; everything is null until read.
  const factory PullRequestState({
    /// The remote's project and its own branch, or null until git answered.
    PullRequestTargetValueObject? target,

    /// The commits and changes over the base, or null until read.
    BranchProposalValueObject? proposal,

    /// The overview, or null until read.
    BranchOverviewValueObject? overview,

    /// What the base can be: the remote's own branch first, then every
    /// other local branch but the one proposed.
    @Default(<BranchNameValueObject>[]) List<BranchNameValueObject> bases,

    /// Which segment the right column shows.
    @Default(PullRequestSegmentEnum.proposal) PullRequestSegmentEnum segment,

    /// Why the last reading or the last press did not work, or null.
    AppFailure? failure,

    /// Why [target] could not be read, or null — what tells a folder with no
    /// repository from one git could not read.
    AppFailure? targetFailure,

    /// Whether `gh` answered for this branch, so the pull request can be
    /// created from here rather than only on the host's page.
    @Default(false) bool throughGh,

    /// The pull request the branch already has, or null.
    OpenedPullRequestValueObject? opened,

    /// Whether `Create pull request` is running.
    @Default(false) bool creating,

    /// Why the last `Create pull request` did not open one, or null.
    AppFailure? createFailure,
  }) = _PullRequestState;

  const PullRequestState._();

  /// Whether a pull request can be opened, and if not, why
  /// (`docs/product/git-workflow/pull-request/when-it-cannot-be-opened/doc.md`).
  ///
  /// [git] is the git column's reading when there is one — fresher after a
  /// switch — and the target's own otherwise, since the column may be shut.
  PullRequestAvailabilityEnum availability(GitStatusValueObject? git) {
    switch (targetFailure) {
      case GitNotARepository():
        return PullRequestAvailabilityEnum.noRepository;
      case AppFailure():
        return PullRequestAvailabilityEnum.unreadable;
      case null:
        break;
    }
    final PullRequestTargetValueObject? read = target;
    if (read == null) {
      return PullRequestAvailabilityEnum.reading;
    }
    if (!read.hasRemote) {
      return PullRequestAvailabilityEnum.noRemote;
    }
    if (read.project == null) {
      return PullRequestAvailabilityEnum.unknownHost;
    }
    if (git?.isDetached ?? read.isDetached) {
      return PullRequestAvailabilityEnum.detached;
    }
    final BranchNameValueObject? base = read.defaultBranch;
    if (base == null) {
      return PullRequestAvailabilityEnum.noBase;
    }
    final BranchNameValueObject? branch = git?.branch ?? read.branch;
    if (branch == null) {
      return PullRequestAvailabilityEnum.reading;
    }
    return branch == base
        ? PullRequestAvailabilityEnum.onBase
        : PullRequestAvailabilityEnum.available;
  }

  /// The branch a pull request would be opened from: the git column's
  /// reading when there is one, the target's otherwise.
  BranchNameValueObject? branchFrom(GitStatusValueObject? git) =>
      git?.branch ?? target?.branch;
}
