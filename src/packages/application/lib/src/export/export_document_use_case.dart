/// Exporting a document as PDF or HTML.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Writes the document the preview shows to a file outside the app
/// (`docs/product/export/doc.md`) — free, for everybody, in every edition.
final class ExportDocumentUseCase with UseCase {
  /// Creates the use case.
  const ExportDocumentUseCase({
    required this.exports,
    required this.observability,
  });

  /// Where an export is written.
  final ExportRepository exports;

  @override
  final Observability observability;

  /// Writes [document] — the preview's parse, so the buffer mid-edit — as
  /// [format] at [destination], the absolute path the person chose, with
  /// the images it names read from [space].
  Future<Result<void, AppFailure>> export(
    SpaceEntity space,
    ParsedDocumentValueObject document,
    ExportFormatEnum format,
    String destination,
  ) => guard(() => exports.export(space, document, format, destination));
}
