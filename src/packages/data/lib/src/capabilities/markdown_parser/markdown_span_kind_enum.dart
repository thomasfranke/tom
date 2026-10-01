/// The block-level constructs this capability reports.
library;

/// What a `MarkdownSpanDto` turned out to be.
///
/// The same shape as the domain's `BlockKindEnum` and deliberately a different
/// type, so a parser reporting something extra breaks `tom_data`, not the
/// domain.
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
