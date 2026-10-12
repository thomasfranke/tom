/// Whether a pull request can be opened from where the repository stands.
library;

/// What the `Pull request` row says about itself
/// (`docs/product/git-workflow/pull-request/when-it-cannot-be-opened/doc.md`).
///
/// One value per sentence the row can carry, so the reason is decided here
/// and only worded by the screen.
enum PullRequestAvailabilityEnum {
  /// Git has not answered yet: drawn muted, saying nothing.
  reading,

  /// There is something to propose.
  available,

  /// The branch checked out is the one a proposal would go into.
  onBase,

  /// The remote is on a host the app does not know.
  unknownHost,

  /// The repository has no remote.
  noRemote,

  /// `HEAD` points at a commit rather than a branch.
  detached,

  /// The remote names no branch of its own, and neither `main` nor `master`
  /// exists.
  noBase,

  /// Git could not be read for another reason.
  unreadable,

  /// The space is not inside a repository: muted with no reason, the one
  /// git control a folder without one still draws
  /// (`docs/product/workspace/without-a-repository/doc.md`).
  noRepository,
}
