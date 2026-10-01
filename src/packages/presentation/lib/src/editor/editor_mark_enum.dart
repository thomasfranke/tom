/// What a line of the source pane is marked as.
library;

/// The four things the gutter can say about a line.
///
/// The diff's three plus the conflict, because they come from two readings
/// and never from both at once: while a marker is on screen the diff is not
/// asked for (`docs/product/editor/conflicted-document/doc.md`).
enum EditorMarkEnum {
  /// In the working copy only.
  added,

  /// In the compared version only — the line it closed over.
  removed,

  /// The same block, written differently.
  modified,

  /// Git stopped mid-merge with both sides in this document.
  conflicted,
}
