/// [PdfWidgetsDocumentExporterImpl] over the PDF's own faces, read back from
/// the file's uncompressed dictionaries — pages, fonts, links.
library;

import 'dart:convert';
// For `zlib` alone, to read the compressed page contents back.
import 'dart:io' show zlib;
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const PdfWidgetsDocumentExporterImpl exporter =
      PdfWidgetsDocumentExporterImpl();

  ExporterDocumentDto documentOf(
    List<ExporterBlockDto> blocks, {
    String linkDefinitions = '',
    List<ExporterFootnoteDto> footnotes = const <ExporterFootnoteDto>[],
  }) => ExporterDocumentDto(
    title: 'Intro',
    blocks: blocks,
    linkDefinitions: linkDefinitions,
    footnotes: footnotes,
  );

  Future<String> pdfOf(ExporterDocumentDto document) async {
    final Result<Uint8List, DocumentExporterFailure> result = await exporter
        .export(document, ExporterFormatEnum.pdf);
    return latin1.decode(
      (result as Success<Uint8List, DocumentExporterFailure>).value,
    );
  }

  int pagesIn(String pdf) => RegExp(r'/Type\s*/Page\b').allMatches(pdf).length;

  /// The words drawn on each page, in page order and drawing order, read
  /// from the content stream each page names.
  List<List<String>> pagesOf(String pdf) {
    final String kids =
        RegExp(r'/Kids\s*\[([^\]]*)\]').firstMatch(pdf)?.group(1) ?? '';
    return <List<String>>[
      for (final RegExpMatch page in RegExp(r'(\d+) 0 R').allMatches(kids))
        _wordsIn(_contentOf(pdf, page.group(1) ?? '')),
    ];
  }

  test('writes a PDF, titled by the document', () async {
    final String pdf = await pdfOf(
      documentOf(const <ExporterBlockDto>[
        ExporterBlockDto(
          source: '# Intro',
          kind: ExporterBlockKindEnum.heading,
        ),
        ExporterBlockDto(
          source: 'Some *prose* with **weight**.',
          kind: ExporterBlockKindEnum.paragraph,
        ),
      ]),
    );

    expect(pdf, startsWith('%PDF-'));
    expect(pdf, contains('Intro'));
    expect(pagesIn(pdf), 1);
  });

  test('without font files, the prose falls back to the PDF\'s own Times, '
      'the headings to Helvetica and code to Courier', () async {
    final String pdf = await pdfOf(
      documentOf(const <ExporterBlockDto>[
        ExporterBlockDto(
          source: '# Intro',
          kind: ExporterBlockKindEnum.heading,
        ),
        ExporterBlockDto(
          source: 'Prose with `code`.',
          kind: ExporterBlockKindEnum.paragraph,
        ),
      ]),
    );

    expect(pdf, contains('/Times-Roman'));
    expect(pdf, contains('/Helvetica-Bold'));
    expect(pdf, contains('/Courier'));
  });

  test('a link keeps its address', () async {
    final String pdf = await pdfOf(
      documentOf(const <ExporterBlockDto>[
        ExporterBlockDto(
          source: 'See [the guide][guide].',
          kind: ExporterBlockKindEnum.paragraph,
        ),
      ], linkDefinitions: '[guide]: https://example.com/guide'),
    );

    expect(pdf, contains('https://example.com/guide'));
  });

  test('a long fence runs onto the next page instead of failing', () async {
    final String code = <String>[
      '```dart',
      for (int line = 0; line < 200; line++) '  final int n$line = $line;',
      '```',
    ].join('\n');

    final String pdf = await pdfOf(
      documentOf(<ExporterBlockDto>[
        ExporterBlockDto(source: code, kind: ExporterBlockKindEnum.code),
      ]),
    );

    expect(pagesIn(pdf), greaterThan(1));
  });

  test(
    'every construct the preview draws is laid out without failing',
    () async {
      final Result<Uint8List, DocumentExporterFailure> result = await exporter
          .export(
            documentOf(
              const <ExporterBlockDto>[
                ExporterBlockDto(
                  source: '- one\n  - nested\n- [x] done\n- [ ] to do',
                  kind: ExporterBlockKindEnum.list,
                ),
                ExporterBlockDto(
                  source: '3. three\n4. four',
                  kind: ExporterBlockKindEnum.list,
                ),
                ExporterBlockDto(
                  source: '| a | b |\n|---|---|\n| 1 | ~~2~~ |',
                  kind: ExporterBlockKindEnum.table,
                ),
                ExporterBlockDto(
                  source: '> quoted\n> > twice',
                  kind: ExporterBlockKindEnum.quote,
                ),
                ExporterBlockDto(
                  source: '> [!NOTE]\n> An alert.',
                  kind: ExporterBlockKindEnum.quote,
                ),
                ExporterBlockDto(
                  source: '---',
                  kind: ExporterBlockKindEnum.rule,
                ),
                ExporterBlockDto(
                  source: '<div>raw</div>',
                  kind: ExporterBlockKindEnum.html,
                ),
                ExporterBlockDto(
                  source: 'A claim.[^a] An image ![alt](x.png).  \nBroken.',
                  kind: ExporterBlockKindEnum.paragraph,
                ),
              ],
              footnotes: const <ExporterFootnoteDto>[
                ExporterFootnoteDto(label: 'a', number: 1, text: 'The note.'),
              ],
            ),
            ExporterFormatEnum.pdf,
          );

      expect(result, isA<Success<Uint8List, DocumentExporterFailure>>());
    },
  );

  test('a table row taller than a page is too large, not a crash', () async {
    final String cell = List<String>.filled(6000, 'word').join(' ');

    final Result<Uint8List, DocumentExporterFailure> result = await exporter
        .export(
          documentOf(<ExporterBlockDto>[
            ExporterBlockDto(
              source: '| a |\n|---|\n| $cell |',
              kind: ExporterBlockKindEnum.table,
            ),
          ]),
          ExporterFormatEnum.pdf,
        );

    expect(
      (result as Failure<Uint8List, DocumentExporterFailure>).failure,
      isA<DocumentExporterTooLarge>(),
    );
  });

  group('an image', () {
    // A one-pixel PNG, so this file reads nothing from disk; the fixtures
    // are the integration test's.
    final Uint8List dot = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
      '60e6kgAAAABJRU5ErkJggg==',
    );
    final RegExp anImage = RegExp(r'/Subtype\s*/Image');

    Future<String> pdfWith(String source, Uint8List? bytes) async {
      final Result<Uint8List, DocumentExporterFailure> result = await exporter
          .export(
            documentOf(<ExporterBlockDto>[
              ExporterBlockDto(
                source: source,
                kind: ExporterBlockKindEnum.paragraph,
              ),
            ]),
            ExporterFormatEnum.pdf,
            readImage: (String reference) async => bytes,
          );
      return latin1.decode(
        (result as Success<Uint8List, DocumentExporterFailure>).value,
      );
    }

    test('is embedded when its bytes can be had', () async {
      expect(await pdfWith('![A dot](dot.png)', dot), matches(anImage));
    });

    test('is embedded once however often it is named', () async {
      final String pdf = await pdfWith(
        '![one](dot.png) and [![two](dot.png)](https://example.com)',
        dot,
      );

      // One picture and its transparency, not two of each.
      expect(RegExp(r'/SMask \d+ 0 R').allMatches(pdf), hasLength(1));
    });

    test('that cannot be had keeps its alt text, and the export', () async {
      final String pdf = await pdfWith('![The missing chart](gone.png)', null);

      expect(pdf, isNot(matches(anImage)));
      expect(pagesOf(pdf).single, contains('chart'));
    });

    test('that is not an image keeps its alt text, and the export', () async {
      final String pdf = await pdfWith(
        '![The broken chart](broken.png)',
        Uint8List.fromList(utf8.encode('not a picture')),
      );

      expect(pdf, isNot(matches(anImage)));
      expect(pagesOf(pdf).single, contains('chart'));
    });

    test('nobody to ask is alt text, as before', () async {
      final String pdf = await pdfOf(
        documentOf(const <ExporterBlockDto>[
          ExporterBlockDto(
            source: '![The chart](chart.png)',
            kind: ExporterBlockKindEnum.paragraph,
          ),
        ]),
      );

      expect(pagesOf(pdf).single, contains('chart'));
    });
  });

  group('a heading never sits alone at the foot of a page', () {
    // Enough filler lines to walk the heading down page one and past it,
    // one line at a time, so one of them lands it at the foot.
    for (int filler = 24; filler <= 40; filler++) {
      test('after $filler lines', () async {
        final String pdf = await pdfOf(
          documentOf(<ExporterBlockDto>[
            for (int line = 0; line < filler; line++)
              const ExporterBlockDto(
                source: 'Filler',
                kind: ExporterBlockKindEnum.paragraph,
              ),
            const ExporterBlockDto(
              source: '## Chapter',
              kind: ExporterBlockKindEnum.heading,
            ),
            const ExporterBlockDto(
              source: '### Section',
              kind: ExporterBlockKindEnum.heading,
            ),
            ExporterBlockDto(
              source: List<String>.filled(30, 'Body').join(' '),
              kind: ExporterBlockKindEnum.paragraph,
            ),
          ]),
        );

        for (final List<String> page in pagesOf(pdf)) {
          expect(page.last, isNot(anyOf('Chapter', 'Section')));
        }
      });
    }

    test('and moves to the next page with the block it heads', () async {
      final List<List<String>> moved = <List<String>>[];
      for (int filler = 24; filler <= 40; filler++) {
        final List<List<String>> pages = pagesOf(
          await pdfOf(
            documentOf(<ExporterBlockDto>[
              for (int line = 0; line < filler; line++)
                const ExporterBlockDto(
                  source: 'Filler',
                  kind: ExporterBlockKindEnum.paragraph,
                ),
              const ExporterBlockDto(
                source: '## Chapter',
                kind: ExporterBlockKindEnum.heading,
              ),
              ExporterBlockDto(
                source: List<String>.filled(30, 'Body').join(' '),
                kind: ExporterBlockKindEnum.paragraph,
              ),
            ]),
          ),
        );
        if (pages.length > 1 && pages[1].first == 'Chapter') {
          moved.add(pages[1]);
        }
      }

      expect(moved, isNotEmpty);
      for (final List<String> page in moved) {
        expect(page.take(2), <String>['Chapter', 'Body']);
      }
    });
  });

  test('HTML is not this exporter\'s', () async {
    final Result<Uint8List, DocumentExporterFailure> result = await exporter
        .export(
          documentOf(const <ExporterBlockDto>[]),
          ExporterFormatEnum.html,
        );

    expect(
      (result as Failure<Uint8List, DocumentExporterFailure>).failure,
      const DocumentExporterUnsupported(ExporterFormatEnum.html),
    );
  });
}

/// The inflated content stream of the page that is object [id] in [pdf].
String _contentOf(String pdf, String id) {
  final int page = pdf.indexOf('\n$id 0 obj');
  final String contents =
      RegExp(
        r'/Contents (\d+) 0 R',
      ).firstMatch(pdf.substring(page))?.group(1) ??
      '';
  final int object = pdf.indexOf('\n$contents 0 obj');
  final int start = pdf.indexOf('stream\n', object) + 'stream\n'.length;
  final int end = pdf.indexOf('endstream', start);
  return latin1.decode(zlib.decode(latin1.encode(pdf.substring(start, end))));
}

/// The strings a content stream shows, one per `TJ`.
List<String> _wordsIn(String content) => <String>[
  for (final RegExpMatch shown in RegExp(
    r'\[\((.*?)\)\]TJ',
  ).allMatches(content))
    shown.group(1) ?? '',
];
