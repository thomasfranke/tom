/// What exporting a document can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/export/export_format_enum.dart';

part 'export_failure.freezed.dart';

/// An export that left no file behind.
///
/// Each variant names what the person chose — the destination or the
/// format — and what the engine or the disk said travels in
/// [AppFailure.cause].
@freezed
sealed class ExportFailure with _$ExportFailure implements AppFailure {
  /// The file could not be written: the engine broke, or the disk refused.
  const factory ExportFailure.cannotWrite(
    /// The absolute path the export was to land at.
    String destination, {
    AppFailure? cause,
  }) = ExportCannotWrite;

  /// No exporter writes [format].
  const factory ExportFailure.unsupported(
    /// The format that was asked for.
    ExportFormatEnum format, {
    AppFailure? cause,
  }) = ExportUnsupported;

  /// Something in the document does not fit the format — a table row taller
  /// than a PDF page is the first.
  const factory ExportFailure.tooLarge(
    /// The format it did not fit.
    ExportFormatEnum format, {
    AppFailure? cause,
  }) = ExportTooLarge;
}
