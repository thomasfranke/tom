/// What one parse of a document reports.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_footnote_dto.dart';
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

    /// Every footnote of the text, in citation order.
    ///
    /// Reported rather than left in the spans because the parser is the only
    /// one that can number them: the number is the order the notes are first
    /// cited in, across the whole text
    /// ([Decision 31](../../../../../../../docs/technical/decisions/031-where-a-footnotes-text-goes.md)).
    @Default(<MarkdownFootnoteDto>[]) List<MarkdownFootnoteDto> footnotes,

    /// What sits between each `[[` and `]]` of the text, in document order,
    /// never one inside code.
    ///
    /// The raw words and nothing more: what they mean — target, anchor,
    /// label — is the domain's to read, so a second parser owes only this.
    @Default(<String>[]) List<String> wikilinks,
  }) = _MarkdownOutlineDto;
}
