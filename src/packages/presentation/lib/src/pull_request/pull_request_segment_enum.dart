/// The two segments of the pull request's right column.
library;

/// `Pull request · Overview`
/// (`docs/product/git-workflow/pull-request/the-right-column/doc.md`).
enum PullRequestSegmentEnum {
  /// The base, the commits and the action.
  proposal,

  /// What the branch did, in numbers; no action.
  overview,
}
