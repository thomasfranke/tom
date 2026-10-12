/// The domain's export contract, over the exporters and the disk.
library;

import 'dart:typed_data';

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/document_exporter/exporter_block_dto.dart';
import 'package:tom_data/src/capabilities/document_exporter/exporter_block_kind_enum.dart';
import 'package:tom_data/src/capabilities/document_exporter/exporter_document_dto.dart';
import 'package:tom_data/src/capabilities/document_exporter/exporter_footnote_dto.dart';
import 'package:tom_data/src/capabilities/document_exporter/exporter_format_enum.dart';
import 'package:tom_data/src/export/export_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabulary only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [ExportRepository] over an [ExportDataSource]: render, then write, and
/// nothing is written when the render failed.
final class ExportRepositoryImpl implements ExportRepository {
  /// Creates the repository over [source].
  const ExportRepositoryImpl({required this.source});

  /// Where the bytes are made and where they go.
  final ExportDataSource source;

  @override
  Future<Result<void, ExportFailure>> export(
    SpaceEntity space,
    ParsedDocumentValueObject document,
    ExportFormatEnum format,
    String destination,
  ) async {
    final Result<Uint8List, DocumentExporterFailure> rendered = await source
        .render(
          _dtoOf(document),
          _asExporterFormat(format),
          readImage: (String reference) =>
              _image(space, document.document.path, reference),
        );
    switch (rendered) {
      case Failure<Uint8List, DocumentExporterFailure>(
        failure: final DocumentExporterFailure failure,
      ):
        return Failure<void, ExportFailure>(
          _fromExporter(failure, format, destination),
        );
      case Success<Uint8List, DocumentExporterFailure>(
        value: final Uint8List bytes,
      ):
        return (await source.write(
          destination,
          bytes,
        )).mapFailure<ExportFailure>(
          (FilesystemFailure failure) =>
              ExportCannotWrite(destination, cause: failure),
        );
    }
  }

  /// The bytes of the image [origin] names as [reference], or null when it
  /// is not a file inside [space] or cannot be read.
  ///
  /// The preview's rule (`preview_block_widget.dart`): a local file only,
  /// from the document's folder, and never one outside the space.
  Future<Uint8List?> _image(
    SpaceEntity space,
    SpaceRelativePathValueObject origin,
    String reference,
  ) async {
    final Uri? uri = Uri.tryParse(reference);
    if (uri == null || (uri.hasScheme && !uri.isScheme('file'))) {
      return null;
    }
    final SpaceRelativePathValueObject? path = origin.resolve(
      Uri.decodeFull(uri.path),
    );
    if (path == null) {
      return null;
    }
    return switch (await source.read(space.absolutePathOf(path))) {
      Success<Uint8List, FilesystemFailure>(:final Uint8List value) => value,
      Failure<Uint8List, FilesystemFailure>() => null,
    };
  }

  /// The document as the capability takes it: the blocks without their
  /// positions, titled by the name without its extension.
  static ExporterDocumentDto _dtoOf(ParsedDocumentValueObject parsed) {
    final String name = parsed.document.name;
    final int dot = name.lastIndexOf('.');
    return ExporterDocumentDto(
      title: dot > 0 ? name.substring(0, dot) : name,
      blocks: List<ExporterBlockDto>.unmodifiable(<ExporterBlockDto>[
        for (final BlockValueObject block in parsed.blocks)
          ExporterBlockDto(
            source: block.source,
            kind: _asExporterKind(block.kind),
          ),
      ]),
      linkDefinitions: parsed.linkDefinitions,
      footnotes: List<ExporterFootnoteDto>.unmodifiable(<ExporterFootnoteDto>[
        for (final FootnoteValueObject note in parsed.footnotes)
          ExporterFootnoteDto(
            label: note.label,
            number: note.number,
            text: note.text,
          ),
      ]),
    );
  }

  static ExporterFormatEnum _asExporterFormat(ExportFormatEnum format) =>
      switch (format) {
        ExportFormatEnum.html => ExporterFormatEnum.html,
        ExportFormatEnum.pdf => ExporterFormatEnum.pdf,
      };

  /// Written out although one to one, so a kind the domain gains breaks here.
  static ExporterBlockKindEnum _asExporterKind(BlockKindEnum kind) =>
      switch (kind) {
        BlockKindEnum.paragraph => ExporterBlockKindEnum.paragraph,
        BlockKindEnum.heading => ExporterBlockKindEnum.heading,
        BlockKindEnum.list => ExporterBlockKindEnum.list,
        BlockKindEnum.table => ExporterBlockKindEnum.table,
        BlockKindEnum.code => ExporterBlockKindEnum.code,
        BlockKindEnum.quote => ExporterBlockKindEnum.quote,
        BlockKindEnum.rule => ExporterBlockKindEnum.rule,
        BlockKindEnum.html => ExporterBlockKindEnum.html,
      };

  /// What the exporter said, in the product's words; exhaustive with no
  /// default branch, so a new variant is decided here.
  static ExportFailure _fromExporter(
    DocumentExporterFailure failure,
    ExportFormatEnum format,
    String destination,
  ) => switch (failure) {
    DocumentExporterWriteFailed() => ExportCannotWrite(
      destination,
      cause: failure,
    ),
    DocumentExporterUnsupported() => ExportUnsupported(format, cause: failure),
    DocumentExporterTooLarge() => ExportTooLarge(format, cause: failure),
  };
}
