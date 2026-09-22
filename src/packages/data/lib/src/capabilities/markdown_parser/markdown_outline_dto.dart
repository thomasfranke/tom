/// What one parse of a document reports.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_span_dto.dart';

part 'markdown_outline_dto.freezed.dart';

/// The block-level constructs of a text, and the scope they were parsed in.
///
/// A DTO for the reason [MarkdownSpanDto] is one: it crosses the contract
/// and names nothing the domain knows.
///
/// [linkDefinitions] is why this is not just a list — a link reference is
/// declared once and used anywhere, so a caller rendering one construct
/// alone needs the definitions with it.
@freezed
abstract class MarkdownOutlineDto with _$MarkdownOutlineDto {
  /// Creates an outline.
  const factory MarkdownOutlineDto({
    /// The spans, in the order they appear, never overlapping.
    ///
    /// Handed over unmodifiable, never copied.
    required List<MarkdownSpanDto> spans,

    /// Every link reference definition, as its own lines, newline-joined.
    ///
    /// Empty when the text declares none. The lines are the text's own, so
    /// appending them to any fragment of it parses the same way.
    required String linkDefinitions,
  }) = _MarkdownOutlineDto;
}
