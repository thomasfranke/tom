/// The block-level constructs an exporter is handed.
library;

/// What an `ExporterBlockDto` is.
///
/// The same shape as the domain's `BlockKindEnum` and deliberately a different
/// type, as `MarkdownSpanKindEnum` is: a kind the domain gains breaks
/// `tom_data`'s translation, not every exporter.
enum ExporterBlockKindEnum {
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
