/// What one parse of a document reports.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_infra/src/markdown_parser/markdown_span.dart';

part 'markdown_outline.freezed.dart';

/// The block-level constructs of a text, and the scope they were parsed in.
///
/// [linkDefinitions] is the reason this is not just a list: a link reference
/// is declared once and used anywhere, so a caller rendering one construct
/// on its own needs the definitions with it.
@freezed
abstract class MarkdownOutline with _$MarkdownOutline {
  /// Creates an outline.
  const factory MarkdownOutline({
    /// The spans, in the order they appear, never overlapping.
    ///
    /// Handed over unmodifiable, never copied.
    required List<MarkdownSpan> spans,

    /// Every link reference definition, as its own lines, newline-joined.
    ///
    /// Empty when the text declares none. The lines are the text's own, so
    /// appending them to any fragment of it parses the same way.
    required String linkDefinitions,
  }) = _MarkdownOutline;
}
