/// What a formatting button asks for.
library;

/// The fifteen things a button can do to the source.
///
/// Undo and redo are not here: they act on the editor's own history and not
/// on the text, which is why the boards tell the first group apart from the
/// rest (`docs/product/editor/formatting-shortcuts/doc.md`).
enum FormatCommandEnum {
  /// `# ` on every line the selection touches.
  heading,

  /// `**` around the selection.
  bold,

  /// `*` around the selection.
  italic,

  /// `~~` around the selection.
  strikethrough,

  /// `- ` on every line the selection touches.
  list,

  /// `1. ` on every line the selection touches, counting from one.
  orderedList,

  /// `- [ ] ` on every line the selection touches.
  taskList,

  /// `> ` on every line the selection touches.
  quote,

  /// Backticks around the selection, or a fence around the lines it spans.
  code,

  /// A two-column table with a header, at the caret.
  table,

  /// `---` on a line of its own, at the caret.
  rule,

  /// `[text](url)` around the selection, or empty at the caret.
  link,

  /// `![alt](url)` at the caret.
  image,

  /// A reference at the caret and its definition at the foot.
  footnote,

  /// `> [!NOTE]` on every line the selection touches.
  alert,
}
