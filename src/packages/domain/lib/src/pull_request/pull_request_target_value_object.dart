/// Where a pull request would go.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/branch_name_value_object.dart';
import 'package:tom_domain/src/pull_request/remote_project_value_object.dart';

part 'pull_request_target_value_object.freezed.dart';

/// The project on its host, the branch the remote calls its own, and the
/// branch the repository is on — what decides whether the control can act,
/// and what it says when it cannot
/// (`docs/product/git-workflow/pull-request/when-it-cannot-be-opened/doc.md`).
@freezed
abstract class PullRequestTargetValueObject
    with _$PullRequestTargetValueObject {
  /// A target; any part may be missing.
  const factory PullRequestTargetValueObject({
    /// The recognised project, or null for no remote or an unknown host.
    RemoteProjectValueObject? project,

    /// The remote's own branch, the base a proposal starts at.
    BranchNameValueObject? defaultBranch,

    /// Whether the repository has a remote at all, which is what tells an
    /// unknown host from no remote when [project] is null.
    @Default(false) bool hasRemote,

    /// The branch checked out when this was read, or null when detached.
    ///
    /// Read here rather than taken from the git column, which may be shut.
    BranchNameValueObject? branch,

    /// Whether `HEAD` pointed at a commit rather than a branch.
    @Default(false) bool isDetached,
  }) = _PullRequestTargetValueObject;
}
