/// Which page of the window a panel belongs to.
library;

/// What the window is showing: the space, one branch's pull request, or a
/// space git knows nothing about.
///
/// A panel names its pages the way it names its modes, and the shell only
/// filters — the right column swaps `Git · History` for `Pull request ·
/// Overview` without knowing either
/// (`docs/product/git-workflow/pull-request/the-right-column/doc.md`).
enum PanelPageEnum {
  /// The space: tabs, documents, git.
  workspace,

  /// A branch's pull request draft, while it is up.
  pullRequest,

  /// A space with no repository: tabs and documents, and no git panel
  /// (`docs/product/workspace/without-a-repository/doc.md`).
  noRepository,
}
