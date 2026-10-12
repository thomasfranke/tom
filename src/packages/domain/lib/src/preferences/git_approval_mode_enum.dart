/// Who says yes before git and `gh` run.
library;

/// The three modes of `docs/product/git-workflow/approvals/doc.md`.
///
/// In the domain because the choice is **stored**: it is a preference, and
/// a value that crosses a repository belongs to the model.
enum GitApprovalModeEnum {
  /// Nobody: every command runs as soon as it is asked for. The default.
  automatic,

  /// A list the person keeps: a command waits unless the list allows it.
  semi,

  /// The person, every time, reads included; the list is not consulted.
  manual,
}
