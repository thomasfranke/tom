/// The block-level constructs this capability reports.
library;

/// What a `MarkdownSpanDto` turned out to be.
///
/// The capability's own vocabulary, one value per construct a caller can do
/// something with. It is deliberately the same shape as the domain's
/// `BlockKind` and deliberately a different type: the day a second parser
/// reports something extra, `tom_data` is where the compiler asks about it.
enum MarkdownSpanKindEnum {
  /// Prose.
  paragraph,

  /// A heading of any level, `#` or underlined.
  heading,

  /// A whole list, nesting included.
  list,

  /// A whole table.
  table,

  /// A fenced or indented code block.
  code,

  /// A block quote, and everything inside it.
  quote,

  /// A thematic break.
  rule,

  /// Raw HTML, passed through untouched.
  html,
}
