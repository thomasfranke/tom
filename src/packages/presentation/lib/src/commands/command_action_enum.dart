/// What the person did, or the app did for them, that made commands run.
library;

/// The name of an action whose commands are one plan in the commands panel
/// (`docs/product/git-workflow/approvals/doc.md`).
///
/// A name and not a sentence: the application words it, and the
/// capabilities never learn it ([Decision 38](../../../../../../docs/technical/decisions/038-a-command-waits-at-a-gate-in-tom-core.md)).
enum CommandActionEnum {
  /// Opening a folder as a space, from Home or from the breadcrumb.
  openSpace,

  /// Cloning an address into a new folder.
  cloneRepository,

  /// Reading the branch a recent space was left on.
  readRecentBranch,

  /// Reading where the repository stands: the status, and the merge.
  readRepository,

  /// Listing the branches.
  readBranches,

  /// Reading the branch this one came from, and where it left it.
  readDiffBase,

  /// Reading the commits that touched a document.
  readHistory,

  /// Reading a file as a commit, the index or the diff's base holds it.
  readVersion,

  /// Staging files.
  stage,

  /// Unstaging files.
  unstage,

  /// Committing what is staged.
  commit,

  /// Putting one file back.
  discard,

  /// Putting every tracked file back.
  discardAll,

  /// Fetching.
  fetch,

  /// Pulling.
  pull,

  /// Pushing, or publishing a branch for the first time.
  push,

  /// Undoing the merge a conflicted pull left behind.
  abortPull,

  /// Switching to a branch.
  switchBranch,

  /// Starting a branch.
  createBranch,

  /// Reading what a pull request would propose, and whether one is open.
  readPullRequest,

  /// Opening a pull request on the host.
  createPullRequest,

  /// Reading who commits here, and the GitHub accounts the machine holds.
  readAccount,

  /// Choosing the GitHub account this repository is used with.
  chooseAccount,
}
