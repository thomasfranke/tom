/// What kind of thing a block is.
library;

/// The block-level constructs a document is made of.
///
/// Closed, and top level on purpose: a list is one block and a table is one
/// block ([Spike
/// B](../../../../../../docs/technical/decisions/019-blocks-come-from-the-markdown-package.md)).
enum BlockKind {
  /// Prose.
  paragraph,

  /// A heading of any level, `#` or underlined.
  heading,

  /// A whole list, bullets or numbers, nesting included.
  list,

  /// A whole table, header row and all.
  table,

  /// A fenced or indented code block.
  code,

  /// A block quote, and everything inside it.
  quote,

  /// A thematic break.
  rule,

  /// Raw HTML the parser passed through untouched.
  html,
}
