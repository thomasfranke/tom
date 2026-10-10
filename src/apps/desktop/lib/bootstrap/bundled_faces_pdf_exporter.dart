/// The PDF exporter, given the IBM Plex faces this app already ships.
library;

import 'package:flutter/services.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

/// [PdfWidgetsDocumentExporterImpl] over the faces `tom_ui` vendors, read
/// from the asset bundle on the first export (`stack/fonts.md`).
///
/// Here because only Flutter can read the bundle and `tom_infra` cannot see
/// Flutter; without the faces a PDF falls back to Latin-1 Times. Wiring,
/// not logic: it loads five files and hands them over.
final class BundledFacesPdfExporter implements DocumentExporter {
  /// Creates the exporter over [bundle].
  BundledFacesPdfExporter({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  PdfWidgetsDocumentExporterImpl? _loaded;

  @override
  Future<Result<Uint8List, DocumentExporterFailure>> export(
    ExporterDocumentDto document,
    ExporterFormatEnum format, {
    ExporterImageReader? readImage,
  }) async => (_loaded ??= PdfWidgetsDocumentExporterImpl(
    serif: await _face('IBMPlexSerif-Regular'),
    serifItalic: await _face('IBMPlexSerif-Italic'),
    serifSemiBold: await _face('IBMPlexSerif-SemiBold'),
    sansSemiBold: await _face('IBMPlexSans-SemiBold'),
    mono: await _face('IBMPlexMono-Regular'),
  )).export(document, format, readImage: readImage);

  Future<ByteData> _face(String name) =>
      _bundle.load('packages/tom_ui/fonts/$name.ttf');
}
