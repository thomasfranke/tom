/// One footnote as a parse reports it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'markdown_footnote_dto.freezed.dart';

/// What a parser says about one footnote, in words no package owns.
///
/// A DTO because it crosses the capability contract: the label, the number
/// and the text are three facts any markdown parser can answer, and none of
/// them is a node of anybody's AST
/// ([Decision 24](../../../../../../../docs/technical/decisions/024-a-capability-is-a-folder.md)).
@freezed
abstract class MarkdownFootnoteDto with _$MarkdownFootnoteDto {
  /// Creates the row.
  const factory MarkdownFootnoteDto({
    /// What the author called it — `a` in `[^a]`.
    required String label,

    /// Which one it is, counting from one in citation order.
    required int number,

    /// What it says, without the `[^label]:` that introduced it.
    required String text,
  }) = _MarkdownFootnoteDto;
}
