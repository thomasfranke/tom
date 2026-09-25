/// What one parse of a document reports.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_span_dto.dart';

part 'markdown_outline_dto.freezed.dart';

/// The block-level constructs of a text, and the scope they were parsed in.
///
/// A DTO for the reason [MarkdownSpanDto] is one. It is not just a list
/// because a caller rendering one construct alone needs [linkDefinitions].
@freezed
abstract class MarkdownOutlineDto with _$MarkdownOutlineDto {
  /// Creates an outline.
  const factory MarkdownOutlineDto({
    /// The spans in order, never overlapping, handed over unmodifiable.
    required List<MarkdownSpanDto> spans,

    /// Every link reference definition as the text's own lines, newline-joined
    /// and empty when there are none, so appending them to any fragment of the
    /// text parses the same way.
    required String linkDefinitions,
  }) = _MarkdownOutlineDto;
}
