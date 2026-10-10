/// What writing a document as another format can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';

part 'document_exporter_failure.freezed.dart';

/// An export that produced no bytes.
@freezed
sealed class DocumentExporterFailure
    with _$DocumentExporterFailure
    implements AppFailure {
  /// The engine broke while writing the output.
  const factory DocumentExporterFailure.writeFailed(
    /// What it reported, verbatim. For diagnostics — never parsed.
    String description, {
    AppFailure? cause,
  }) = DocumentExporterWriteFailed;

  /// This implementation does not write [format].
  const factory DocumentExporterFailure.unsupported(
    /// The format that was asked for.
    ExporterFormatEnum format, {
    AppFailure? cause,
  }) = DocumentExporterUnsupported;

  /// Something in the document will not fit the output's shape — a table
  /// row taller than a page is the first.
  const factory DocumentExporterFailure.tooLarge(
    /// What the engine said, verbatim. For diagnostics — never parsed.
    String description, {
    AppFailure? cause,
  }) = DocumentExporterTooLarge;
}
