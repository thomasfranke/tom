/// [PdfWidgetsDocumentExporterImpl] where the real engine runs out of room
/// or of glyphs: an image taller than a page, a file cut short, scripts the
/// Plex faces do not carry, hundreds of pages — and each failure the
/// capability classifies, provoked from the engine rather than written.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  // Read by path because this package cannot depend on `tom_ui`; the tests
  // run from the package's own folder.
  ByteData face(String file) =>
      ByteData.sublistView(File('../ui/fonts/$file').readAsBytesSync());

  final PdfWidgetsDocumentExporterImpl exporter =
      PdfWidgetsDocumentExporterImpl(
        reading: face('PublicSans-Regular.ttf'),
        readingItalic: face('PublicSans-Italic.ttf'),
        readingSemiBold: face('PublicSans-SemiBold.ttf'),
        sansSemiBold: face('PublicSans-SemiBold.ttf'),
        mono: face('IBMPlexMono-Regular.ttf'),
      );

  // With no face handed in the PDF's own Times writes its words as plain
  // strings, which is the only way a test can read what a page says.
  const PdfWidgetsDocumentExporterImpl plain = PdfWidgetsDocumentExporterImpl();

  ExporterBlockDto paragraph(String source) =>
      ExporterBlockDto(source: source, kind: ExporterBlockKindEnum.paragraph);

  Future<Result<Uint8List, DocumentExporterFailure>> export(
    List<ExporterBlockDto> blocks, {
    PdfWidgetsDocumentExporterImpl? through,
    ExporterImageReader? readImage,
  }) => (through ?? exporter).export(
    ExporterDocumentDto(title: 'Limits', blocks: blocks, linkDefinitions: ''),
    ExporterFormatEnum.pdf,
    readImage: readImage,
  );

  /// The PDF [blocks] export as, or a failed test.
  Future<String> pdfOf(
    List<ExporterBlockDto> blocks, {
    PdfWidgetsDocumentExporterImpl? through,
    ExporterImageReader? readImage,
  }) async {
    final Result<Uint8List, DocumentExporterFailure> result = await export(
      blocks,
      through: through,
      readImage: readImage,
    );
    return switch (result) {
      Success<Uint8List, DocumentExporterFailure>(
        value: final Uint8List bytes,
      ) =>
        latin1.decode(bytes),
      Failure<Uint8List, DocumentExporterFailure>(
        failure: final DocumentExporterFailure failure,
      ) =>
        fail('the export failed: $failure'),
    };
  }

  /// How many pages [pdf] says it has.
  int pagesIn(String pdf) =>
      int.parse(RegExp(r'/Count (\d+)').firstMatch(pdf)!.group(1)!);

  group('an image', () {
    // A4 less two 56-point margins, less the gap a figure keeps above and
    // below itself: the tallest a picture is ever drawn.
    const String tallest = '713.88976';

    test('taller than a page is embedded whole and drawn at a page\'s '
        'height, on one page', () async {
      final String pdf = await pdfOf(<ExporterBlockDto>[
        paragraph('![A long strip](strip.png)'),
      ], readImage: (String reference) async => _png(40, 4000));

      expect(
        pdf,
        matches(RegExp(r'/Subtype\s*/Image\s*/Width 40\s*/Height 4000')),
      );
      // A hundredth of its size, so the width follows: 40 × 713.89 / 4000.
      expect(_contentsOf(pdf), contains('7.1389 0 0 $tallest 0 0 cm'));
      expect(pagesIn(pdf), 1);
    });

    test('taller than a page and drawn as paths fits one page too', () async {
      final String pdf = await pdfOf(
        <ExporterBlockDto>[paragraph('![A long strip](strip.svg)')],
        readImage: (String reference) async => utf8.encode(
          '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="5000">'
          '<rect width="100" height="5000" fill="#2a9d8f"/></svg>',
        ),
      );

      expect(_contentsOf(pdf), contains('0.16471 0.61569 0.56078 rg'));
      expect(pagesIn(pdf), 1);
    });

    test('cut short on disk costs its own picture and never the export: '
        'its words stand where it was', () async {
      final Uint8List whole = _png(40, 400);

      final String pdf = await pdfOf(
        <ExporterBlockDto>[
          paragraph('Before.'),
          paragraph('![The chart cut short](cut.png)'),
          paragraph('After.'),
        ],
        through: plain,
        readImage: (String reference) async =>
            whole.sublist(0, whole.length ~/ 2),
      );

      expect(pdf, isNot(matches(RegExp(r'/Subtype\s*/Image'))));
      expect(
        _shownIn(pdf),
        containsAllInOrder(<Matcher>[
          contains('Before.'),
          contains('short'),
          contains('After.'),
        ]),
      );
    });

    test('that is only the first bytes of a PNG is words too', () async {
      final String pdf = await pdfOf(
        <ExporterBlockDto>[paragraph('![Only a header](cut.png)')],
        through: plain,
        readImage: (String reference) async => _png(40, 400).sublist(0, 20),
      );

      expect(pdf, isNot(matches(RegExp(r'/Subtype\s*/Image'))));
      expect(_shownIn(pdf).join(' '), contains('header'));
    });

    test('that is an SVG broken off mid-tag is words too', () async {
      final String pdf = await pdfOf(
        <ExporterBlockDto>[paragraph('![A broken drawing](b.svg)')],
        through: plain,
        readImage: (String reference) async => utf8.encode('<svg><rect'),
      );

      expect(_shownIn(pdf).join(' '), contains('drawing'));
    });
  });

  group('text the Plex faces do not carry', () {
    Future<void> expectAPdf(List<ExporterBlockDto> blocks) async {
      final Result<Uint8List, DocumentExporterFailure> result = await export(
        blocks,
      );

      expect(result, isA<Success<Uint8List, DocumentExporterFailure>>());
      final Uint8List bytes =
          (result as Success<Uint8List, DocumentExporterFailure>).value;
      expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
      expect(latin1.decode(bytes.sublist(bytes.length - 6)).trim(), '%%EOF');
      expect(pagesIn(latin1.decode(bytes)), 1);
    }

    test('Chinese, Japanese and Korean do not break the export', () async {
      await expectAPdf(<ExporterBlockDto>[paragraph('文档是产品。日本語 한국어')]);
    });

    test('emoji do not break it, joined ones included', () async {
      await expectAPdf(<ExporterBlockDto>[
        paragraph('Shipped 🚀 and 🎉 — 👩‍👩‍👧‍👦'),
      ]);
    });

    test('a script written right to left does not break it', () async {
      await expectAPdf(<ExporterBlockDto>[paragraph('مرحبا بالعالم')]);
    });

    test('in a heading and in a fence, where two other faces draw', () async {
      await expectAPdf(const <ExporterBlockDto>[
        ExporterBlockDto(
          source: '# 文档 🚀',
          kind: ExporterBlockKindEnum.heading,
        ),
        ExporterBlockDto(
          source: '```\n文档 🚀\n```',
          kind: ExporterBlockKindEnum.code,
        ),
      ]);
    });
  });

  group('a long document', () {
    test('three hundred pages and more are written inside two '
        'minutes', () async {
      final String words = List<String>.filled(90, 'word').join(' ');

      final Stopwatch watch = Stopwatch()..start();
      final String pdf = await pdfOf(<ExporterBlockDto>[
        for (int index = 0; index < 2000; index++) paragraph('$index $words'),
      ]);
      watch.stop();

      expect(pagesIn(pdf), greaterThan(300));
      expect(pdf, endsWith('%%EOF\n'));
      // A few seconds on a laptop; the bound is for a loaded CI machine.
      expect(watch.elapsed, lessThan(const Duration(minutes: 2)));
    }, timeout: const Timeout(Duration(minutes: 5)));

    /// A fenced block of [lines] lines of code.
    ExporterBlockDto fenceOf(int lines) => ExporterBlockDto(
      source: <String>[
        '```',
        for (int line = 0; line < lines; line++) 'line $line',
        '```',
      ].join('\n'),
      kind: ExporterBlockKindEnum.code,
    );

    test('a fence of a thousand lines runs over its pages', () async {
      final String pdf = await pdfOf(<ExporterBlockDto>[fenceOf(1000)]);

      expect(pagesIn(pdf), greaterThan(10));
    });

    test('a fence of two thousand lines runs over its pages too', () async {
      final String pdf = await pdfOf(<ExporterBlockDto>[fenceOf(2000)]);

      expect(pagesIn(pdf), greaterThan(20));
    });

    test('a list sixty levels deep is written, not refused', () async {
      final String pdf = await pdfOf(<ExporterBlockDto>[
        ExporterBlockDto(
          source: <String>[
            for (int depth = 0; depth < 60; depth++) '${'  ' * depth}- item',
          ].join('\n'),
          kind: ExporterBlockKindEnum.list,
        ),
      ]);

      expect(pagesIn(pdf), greaterThanOrEqualTo(1));
    });
  });

  group('each failure, from the engine itself', () {
    test('too large: a paragraph taller than a page, in the engine\'s own '
        'words and with no bytes', () async {
      final Result<Uint8List, DocumentExporterFailure> result = await export(
        <ExporterBlockDto>[
          paragraph(List<String>.filled(20000, 'word').join(' ')),
        ],
      );

      expect(
        result,
        isA<Failure<Uint8List, DocumentExporterFailure>>().having(
          (Failure<Uint8List, DocumentExporterFailure> it) => it.failure,
          'failure',
          isA<DocumentExporterTooLarge>().having(
            (DocumentExporterTooLarge it) => it.description,
            'description',
            startsWith("Widget won't fit into the page"),
          ),
        ),
      );
    });

    test('too large: one word longer than a page can hold', () async {
      final Result<Uint8List, DocumentExporterFailure> result = await export(
        <ExporterBlockDto>[paragraph('x' * 5000)],
      );

      expect(
        (result as Failure<Uint8List, DocumentExporterFailure>).failure,
        isA<DocumentExporterTooLarge>(),
      );
    });

    test('write failed: an image whose file cannot be opened, with what '
        'the disk said', () async {
      final Directory tempDir = Directory.systemTemp.createTempSync(
        'tom_pdf_limits_test_',
      );
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final String missing = '${tempDir.path}/gone.png';

      final Result<Uint8List, DocumentExporterFailure> result = await export(
        <ExporterBlockDto>[paragraph('![A chart](gone.png)')],
        // The reader the contract asks for answers null for a file it
        // cannot have; one that lets the disk's own error out is how the
        // engine's catch-all is reached for real.
        readImage: (String reference) async => File(missing).readAsBytesSync(),
      );

      expect(
        result,
        isA<Failure<Uint8List, DocumentExporterFailure>>().having(
          (Failure<Uint8List, DocumentExporterFailure> it) => it.failure,
          'failure',
          isA<DocumentExporterWriteFailed>().having(
            (DocumentExporterWriteFailed it) => it.description,
            'description',
            contains(missing),
          ),
        ),
      );
    });

    test('unsupported: the format this exporter does not write', () async {
      final Result<Uint8List, DocumentExporterFailure> result = await exporter
          .export(
            ExporterDocumentDto(
              title: 'Limits',
              blocks: <ExporterBlockDto>[paragraph('Prose.')],
              linkDefinitions: '',
            ),
            ExporterFormatEnum.html,
          );

      expect(
        (result as Failure<Uint8List, DocumentExporterFailure>).failure,
        const DocumentExporterUnsupported(ExporterFormatEnum.html),
      );
    });

    test('and the exporter that just failed writes the next '
        'document', () async {
      await export(<ExporterBlockDto>[paragraph('x' * 5000)]);

      expect(pagesIn(await pdfOf(<ExporterBlockDto>[paragraph('Prose.')])), 1);
    });
  });
}

/// A real PNG of [width] by [height], one grey: signature, header, one
/// deflated run of rows and the end chunk, each with its checksum.
///
/// Written here because the fixtures are wide and this needs a tall one, and
/// because a file cut short has to be a real file first.
Uint8List _png(int width, int height) {
  Uint8List chunk(String type, List<int> data) {
    final List<int> checked = <int>[...ascii.encode(type), ...data];
    int crc = 0xFFFFFFFF;
    for (final int byte in checked) {
      crc ^= byte;
      for (int bit = 0; bit < 8; bit++) {
        crc = (crc & 1) == 1 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
      }
    }
    final ByteData framed = ByteData(8 + data.length + 4)
      ..setUint32(0, data.length)
      ..setUint32(8 + data.length, crc ^ 0xFFFFFFFF);
    return framed.buffer.asUint8List()
      ..setRange(4, 4 + checked.length, checked);
  }

  final ByteData header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    // Eight bits a channel, three channels, nothing interlaced.
    ..setUint8(8, 8)
    ..setUint8(9, 2);
  final int row = 1 + width * 3;
  final Uint8List rows = Uint8List(height * row);
  for (int index = 0; index < rows.length; index++) {
    // Each row opens with its filter, none.
    rows[index] = index % row == 0 ? 0 : 0x66;
  }
  return Uint8List.fromList(<int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    ...chunk('IHDR', header.buffer.asUint8List()),
    ...chunk('IDAT', zlib.encode(rows)),
    ...chunk('IEND', const <int>[]),
  ]);
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

/// The strings [pdf] shows, in drawing order — readable only when the PDF's
/// own faces drew them.
List<String> _shownIn(String pdf) => <String>[
  for (final RegExpMatch shown in RegExp(
    r'\[\((.*?)\)\]TJ',
  ).allMatches(_contentsOf(pdf)))
    shown.group(1) ?? '',
];
