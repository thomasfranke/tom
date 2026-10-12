/// Turning a parsed document into a file's bytes, behind a contract.
library;

import 'dart:typed_data';

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/src/document_exporter/document_exporter_failure.dart';

/// The bytes of the image a document names as [reference] — the `src` as
/// written — or null when it cannot be had.
///
/// Answered by the caller, which knows where the document lives and reads
/// through the filesystem; an exporter only finds the references.
typedef ExporterImageReader = Future<Uint8List?> Function(String reference);

/// Writes a document as one format's bytes.
///
/// **A parsed document in, bytes out**: where the bytes land is the file
/// picker's and the filesystem's, and one implementation per format is
/// [Decision 30](../../../../../../docs/technical/decisions/030-export-renders-the-preview-not-the-file.md).
/// The diff's marks never reach it, because an export is one document.
abstract interface class DocumentExporter {
  /// [document] as [format], or [DocumentExporterUnsupported] when this
  /// implementation does not write that format.
  ///
  /// Each image is asked of [readImage] and embedded; one it cannot have,
  /// or nobody to ask, leaves the image's alt text in its place.
  Future<Result<Uint8List, DocumentExporterFailure>> export(
    ExporterDocumentDto document,
    ExporterFormatEnum format, {
    ExporterImageReader? readImage,
  });
}
