/// A whole document, as an exporter is handed it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_data/src/capabilities/document_exporter/exporter_block_dto.dart';
import 'package:tom_data/src/capabilities/document_exporter/exporter_footnote_dto.dart';

part 'exporter_document_dto.freezed.dart';

/// The blocks the preview draws and the document scope they need.
///
/// Built from the parse the preview already holds, never from the file
/// ([Decision 30](../../../../../../../docs/technical/decisions/030-export-renders-the-preview-not-the-file.md)),
/// so an export cannot say something the preview does not.
@freezed
abstract class ExporterDocumentDto with _$ExporterDocumentDto {
  /// Creates the document.
  const factory ExporterDocumentDto({
    /// What the output is titled, the document's name without its extension.
    required String title,

    /// The top-level blocks, in document order.
    required List<ExporterBlockDto> blocks,

    /// Every link reference definition as the document's own lines, so a
    /// block rendered alone resolves `[text][ref]`.
    required String linkDefinitions,

    /// Every footnote, in citation order.
    @Default(<ExporterFootnoteDto>[]) List<ExporterFootnoteDto> footnotes,
  }) = _ExporterDocumentDto;
}
