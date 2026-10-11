/// The PDF exporter that reads its faces from an asset bundle.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_desktop/bootstrap/bundled_faces_pdf_exporter_impl.dart';
import 'package:tom_infra/tom_infra.dart';

/// Serves the faces from the `ui` package's folder, and counts the loads.
class _FacesBundle extends CachingAssetBundle {
  final List<String> loaded = <String>[];

  @override
  Future<ByteData> load(String key) async {
    loaded.add(key);
    final String name = key.split('/').last;
    final Uint8List bytes = File(
      '../../packages/ui/fonts/$name',
    ).readAsBytesSync();
    return ByteData.sublistView(bytes);
  }
}

void main() {
  const ExporterDocumentDto document = ExporterDocumentDto(
    title: 'Notes',
    blocks: <ExporterBlockDto>[],
    linkDefinitions: '',
  );

  test('the faces are read from tom_ui once, on the first export', () async {
    final _FacesBundle bundle = _FacesBundle();
    final BundledFacesPdfExporterImpl exporter = BundledFacesPdfExporterImpl(
      bundle: bundle,
    );
    expect(bundle.loaded, isEmpty);

    final Result<Uint8List, DocumentExporterFailure> first = await exporter
        .export(document, ExporterFormatEnum.pdf);

    expect(first, isA<Success<Uint8List, DocumentExporterFailure>>());
    final Uint8List bytes =
        (first as Success<Uint8List, DocumentExporterFailure>).value;
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(bundle.loaded, <String>[
      'packages/tom_ui/fonts/PublicSans-Regular.ttf',
      'packages/tom_ui/fonts/PublicSans-Italic.ttf',
      'packages/tom_ui/fonts/PublicSans-SemiBold.ttf',
      'packages/tom_ui/fonts/PublicSans-SemiBold.ttf',
      'packages/tom_ui/fonts/IBMPlexMono-Regular.ttf',
    ]);

    await exporter.export(document, ExporterFormatEnum.pdf);
    expect(bundle.loaded, hasLength(5), reason: 'the second export reloads');
  });
}
