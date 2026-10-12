/// One footnote, as an exporter is handed it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exporter_footnote_dto.freezed.dart';

/// A note and the number the document gave it, which the export draws the
/// way the preview does: the number in the prose, the text at the foot
/// ([Decision 31](../../../../../../../docs/technical/decisions/031-where-a-footnotes-text-goes.md)).
@freezed
abstract class ExporterFootnoteDto with _$ExporterFootnoteDto {
  /// Creates the note.
  const factory ExporterFootnoteDto({
    /// What the author called it — `a` in `[^a]`.
    required String label,

    /// Which one it is, counting from one in citation order.
    required int number,

    /// What it says, as markdown.
    required String text,
  }) = _ExporterFootnoteDto;
}
