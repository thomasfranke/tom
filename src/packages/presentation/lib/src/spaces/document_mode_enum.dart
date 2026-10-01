/// How the document area is being looked at.
library;

/// Source, both, or preview — the three the mode bar offers, and no WYSIWYG
/// ([Decision
/// 3](../../../../../../docs/technical/decisions/003-editor-is-source-plus-preview.md)).
///
/// A mode of the *window*, not of a panel: it decides which panels the
/// document region draws (`docs/product/editor/source-mode/doc.md`).
enum DocumentModeEnum {
  /// The source alone, the whole width.
  source,

  /// Source and preview side by side, which is how a space opens.
  split,

  /// The preview alone, at the reading measure.
  ///
  /// A mode, never a permission: the document is no less editable.
  preview,
}
