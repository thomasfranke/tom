/// [PdfWidgetsDocumentExporterImpl] with the IBM Plex files `tom_ui` vendors,
/// read from disk, and the PDF written to a real temporary folder.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_pdf_export_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  // Read by path because this package cannot depend on `tom_ui`; the tests
  // run from the package's own folder.
  ByteData face(String file) =>
      ByteData.sublistView(File('../ui/fonts/$file').readAsBytesSync());

  final PdfWidgetsDocumentExporterImpl exporter =
      PdfWidgetsDocumentExporterImpl(
        serif: face('IBMPlexSerif-Regular.ttf'),
        serifItalic: face('IBMPlexSerif-Italic.ttf'),
        serifSemiBold: face('IBMPlexSerif-SemiBold.ttf'),
        sansSemiBold: face('IBMPlexSans-SemiBold.ttf'),
        mono: face('IBMPlexMono-Regular.ttf'),
      );

  const ExporterDocumentDto document = ExporterDocumentDto(
    title: 'Ação',
    blocks: <ExporterBlockDto>[
      ExporterBlockDto(
        source: '# Ação — “resumo”',
        kind: ExporterBlockKindEnum.heading,
      ),
      ExporterBlockDto(
        source: 'Œuvre *naïve*, **façade** e `código`.',
        kind: ExporterBlockKindEnum.paragraph,
      ),
    ],
    linkDefinitions: '',
  );

  test('the faces handed in are the ones the file embeds', () async {
    final Result<Uint8List, DocumentExporterFailure> result = await exporter
        .export(document, ExporterFormatEnum.pdf);
    final String pdf = latin1.decode(
      (result as Success<Uint8List, DocumentExporterFailure>).value,
    );

    expect(pdf, contains('IBMPlexSerif'));
    expect(pdf, contains('IBMPlexSans'));
    expect(pdf, contains('IBMPlexMono'));
    expect(pdf, isNot(contains('/Times-Roman')));
  });

  group('an image from disk', () {
    Future<String> pdfWith(String fixture) async {
      final Result<Uint8List, DocumentExporterFailure> result = await exporter
          .export(
            ExporterDocumentDto(
              title: 'Figure',
              blocks: <ExporterBlockDto>[
                ExporterBlockDto(
                  source: '![The chart]($fixture)\n*The caption*',
                  kind: ExporterBlockKindEnum.paragraph,
                ),
              ],
              linkDefinitions: '',
            ),
            ExporterFormatEnum.pdf,
            readImage: (String reference) async =>
                File('test/fixtures/images/$reference').readAsBytesSync(),
          );
      return latin1.decode(
        (result as Success<Uint8List, DocumentExporterFailure>).value,
      );
    }

    // A4 less two 56-point margins.
    const String textWidth = '483.27559';

    test('a PNG wider than the page is embedded whole and drawn at the '
        "text's width", () async {
      final String pdf = await pdfWith('wide.png');

      expect(pdf, matches(RegExp(r'/Subtype\s*/Image\s*/Width 1600')));
      expect(_contentsOf(pdf), contains('$textWidth 0 0 36.24567 0 0 cm'));
    });

    test('a JPEG is embedded as the JPEG it is', () async {
      final String pdf = await pdfWith('wide.jpg');

      expect(pdf, contains('/DCTDecode'));
      expect(_contentsOf(pdf), contains('$textWidth 0 0 36.24567 0 0 cm'));
    });

    test('an SVG is drawn as paths, in its own colour', () async {
      final String pdf = await pdfWith('figure.svg');

      expect(pdf, isNot(matches(RegExp(r'/Subtype\s*/Image'))));
      // #2a9d8f, the rectangle's fill.
      expect(_contentsOf(pdf), contains('0.16471 0.61569 0.56078 rg'));
    });
  });

  test('a PDF beyond Latin-1 lands on disk whole', () async {
    final String path = '${tempDir.path}/Ação.pdf';

    final Result<Uint8List, DocumentExporterFailure> result = await exporter
        .export(document, ExporterFormatEnum.pdf);
    final Uint8List bytes =
        (result as Success<Uint8List, DocumentExporterFailure>).value;
    File(path).writeAsBytesSync(bytes);

    final Uint8List read = File(path).readAsBytesSync();
    expect(latin1.decode(read.sublist(0, 5)), '%PDF-');
    expect(latin1.decode(read.sublist(read.length - 6)).trim(), '%%EOF');
  });
}

/// Every stream in [pdf] that inflates, inflated and joined: the pages'
/// drawing, where a picture's size is written.
String _contentsOf(String pdf) {
  final StringBuffer contents = StringBuffer();
  for (final RegExpMatch stream in RegExp(
    r'/FlateDecode/Length \d+>>stream\n',
  ).allMatches(pdf)) {
    final int end = pdf.indexOf('endstream', stream.end);
    try {
      contents.write(
        latin1.decode(
          zlib.decode(latin1.encode(pdf.substring(stream.end, end))),
        ),
      );
    } on FormatException {
      continue;
    }
  }
  return '$contents';
}
