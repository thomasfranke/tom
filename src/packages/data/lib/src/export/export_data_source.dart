/// Producing an export's bytes, and putting them on disk.
library;

import 'dart:typed_data';

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/document_exporter/exporter_document_dto.dart';
import 'package:tom_data/src/capabilities/document_exporter/exporter_format_enum.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where an export is made and where it lands.
///
/// One exporter per format, as [Decision
/// 30](../../../../../../docs/technical/decisions/030-export-renders-the-preview-not-the-file.md)
/// draws them; a format nobody was given is answered here rather than by
/// asking the wrong one.
final class ExportDataSource {
  /// Creates a source over [exporters] and [filesystem].
  const ExportDataSource({required this.exporters, required this.filesystem});

  /// The exporter that writes each format.
  final Map<ExporterFormatEnum, DocumentExporter> exporters;

  /// What puts the bytes on disk.
  final Filesystem filesystem;

  /// [document] as [format]'s bytes, its images asked of [readImage].
  Future<Result<Uint8List, DocumentExporterFailure>> render(
    ExporterDocumentDto document,
    ExporterFormatEnum format, {
    ExporterImageReader? readImage,
  }) async => switch (exporters[format]) {
    final DocumentExporter exporter => exporter.export(
      document,
      format,
      readImage: readImage,
    ),
    null => Failure<Uint8List, DocumentExporterFailure>(
      DocumentExporterUnsupported(format),
    ),
  };

  /// The bytes at [absolutePath], an image a document names.
  Future<Result<Uint8List, FilesystemFailure>> read(String absolutePath) =>
      filesystem.readBytes(absolutePath);

  /// Puts [bytes] at [absolutePath], replacing what is there.
  Future<Result<void, FilesystemFailure>> write(
    String absolutePath,
    Uint8List bytes,
  ) => filesystem.writeBytes(absolutePath, bytes);
}
