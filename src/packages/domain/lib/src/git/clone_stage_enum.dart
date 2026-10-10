/// Where a clone has got to.
library;

/// The stages a clone reports, in the order it passes through them
/// (`docs/product/home/cloning/doc.md`).
///
/// The product's words for git's progress lines; a line that names none of
/// them is not progress anybody needs to see.
enum CloneStageEnum {
  /// Git has started and nothing has come back yet.
  starting,

  /// The remote is gathering what it is about to send.
  preparing,

  /// The repository's history is arriving.
  receiving,

  /// What arrived is being unpacked into commits.
  resolving,

  /// The files of the default branch are being written to disk.
  checkingOut,
}
