/// How the document area is being looked at.
library;

/// Source, both, or preview — the three the mode bar offers.
///
/// A mode of the *window*, not of a panel: it decides which panels the
/// document region draws, so a panel cannot own it without owning its
/// neighbours (`docs/product/editor/source-mode/doc.md`).
///
/// There is no fourth, and in particular no WYSIWYG — the editor is source
/// plus preview, now and later ([Decision
/// 3](../../../../../../docs/technical/decisions/003-editor-is-source-plus-preview.md)).
enum DocumentModeEnum {
  /// The source alone, the whole width.
  source,

  /// Source and preview side by side, which is how a space opens.
  split,

  /// The preview alone, at the more generous measure reading deserves.
  ///
  /// A mode, never a permission: the document is no less editable, the
  /// editor is simply not on screen.
  preview,
}
