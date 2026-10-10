/// [MarkdownHtmlDocumentExporterImpl]: block by block, in the scope of the
/// whole document, the way the preview renders.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const MarkdownHtmlDocumentExporterImpl exporter =
      MarkdownHtmlDocumentExporterImpl();

  Future<String> htmlOf(ExporterDocumentDto document) async {
    final Result<Uint8List, DocumentExporterFailure> result = await exporter
        .export(document, ExporterFormatEnum.html);
    return utf8.decode(
      (result as Success<Uint8List, DocumentExporterFailure>).value,
    );
  }

  ExporterDocumentDto documentOf(
    List<ExporterBlockDto> blocks, {
    String title = 'Intro',
    String linkDefinitions = '',
    List<ExporterFootnoteDto> footnotes = const <ExporterFootnoteDto>[],
  }) => ExporterDocumentDto(
    title: title,
    blocks: blocks,
    linkDefinitions: linkDefinitions,
    footnotes: footnotes,
  );

  test('a page of its own, titled by the document, holding every block in '
      'order', () async {
    final String html = await htmlOf(
      documentOf(const <ExporterBlockDto>[
        ExporterBlockDto(
          source: '# Intro',
          kind: ExporterBlockKindEnum.heading,
        ),
        ExporterBlockDto(
          source: 'Some *prose*.',
          kind: ExporterBlockKindEnum.paragraph,
        ),
      ]),
    );

    expect(html, startsWith('<!DOCTYPE html>'));
    expect(html, contains('<meta charset="utf-8">'));
    expect(html, contains('<title>Intro</title>'));
    final int heading = html.indexOf('<h1 id="intro">Intro</h1>');
    final int prose = html.indexOf('<p>Some <em>prose</em>.</p>');
    expect(heading, isNonNegative);
    expect(prose, greaterThan(heading));
  });

  test('the title is escaped, since a file name can say anything', () async {
    final String html = await htmlOf(
      documentOf(const <ExporterBlockDto>[], title: 'a <b> & c'),
    );

    expect(html, contains('<title>a &lt;b&gt; &amp; c</title>'));
  });

  test('a reference link resolves in a block that does not hold its '
      'definition', () async {
    final String html = await htmlOf(
      documentOf(const <ExporterBlockDto>[
        ExporterBlockDto(
          source: 'See [the guide][guide].',
          kind: ExporterBlockKindEnum.paragraph,
        ),
      ], linkDefinitions: '[guide]: https://example.com/guide'),
    );

    expect(html, contains('<a href="https://example.com/guide">the guide</a>'));
  });

  test('a footnote carries the number the document gave it, and the notes '
      'are drawn once at the foot', () async {
    final String html = await htmlOf(
      documentOf(
        const <ExporterBlockDto>[
          ExporterBlockDto(
            source: 'First.[^b]',
            kind: ExporterBlockKindEnum.paragraph,
          ),
          ExporterBlockDto(
            source: 'Second.[^a]',
            kind: ExporterBlockKindEnum.paragraph,
          ),
        ],
        footnotes: const <ExporterFootnoteDto>[
          ExporterFootnoteDto(label: 'b', number: 1, text: 'Note *one*.'),
          ExporterFootnoteDto(label: 'a', number: 2, text: 'Note two.'),
        ],
      ),
    );

    expect(html, contains('<p>First.<sup>1</sup></p>'));
    expect(html, contains('<p>Second.<sup>2</sup></p>'));
    expect(html, contains('<li value="1"><p>Note <em>one</em>.</p></li>'));
    expect(html, contains('<li value="2"><p>Note two.</p></li>'));
    expect('<section class="footnotes">'.allMatches(html), hasLength(1));
  });

  test('a reference to no note is left exactly as written', () async {
    final String html = await htmlOf(
      documentOf(const <ExporterBlockDto>[
        ExporterBlockDto(
          source: 'A claim.[^nowhere]',
          kind: ExporterBlockKindEnum.paragraph,
        ),
      ]),
    );

    expect(html, contains('<p>A claim.[^nowhere]</p>'));
    expect(html, isNot(contains('footnotes')));
  });

  test("GitHub's constructs come out as GitHub writes them", () async {
    final String html = await htmlOf(
      documentOf(const <ExporterBlockDto>[
        ExporterBlockDto(
          source: '| a | b |\n|---|---|\n| 1 | 2 |',
          kind: ExporterBlockKindEnum.table,
        ),
        ExporterBlockDto(
          source: '```dart\nfinal int a = 1;\n```',
          kind: ExporterBlockKindEnum.code,
        ),
        ExporterBlockDto(
          source: '- [x] done',
          kind: ExporterBlockKindEnum.list,
        ),
      ]),
    );

    expect(html, contains('<table>'));
    expect(html, contains('<code class="language-dart">final int a = 1;'));
    expect(html, contains('type="checkbox"'));
  });

  group('an image travels inside the page', () {
    Future<String> htmlWith(String source, List<int>? bytes) async {
      final Result<Uint8List, DocumentExporterFailure> result = await exporter
          .export(
            documentOf(<ExporterBlockDto>[
              ExporterBlockDto(
                source: source,
                kind: ExporterBlockKindEnum.paragraph,
              ),
            ]),
            ExporterFormatEnum.html,
            readImage: (String reference) async =>
                bytes == null ? null : Uint8List.fromList(bytes),
          );
      return utf8.decode(
        (result as Success<Uint8List, DocumentExporterFailure>).value,
      );
    }

    test('as a data address, typed by its bytes rather than its '
        'name', () async {
      final List<int> png = <int>[0x89, 0x50, 0x4E, 0x47, 1, 2];

      final String html = await htmlWith('![A chart](chart.jpg)', png);

      expect(
        html,
        contains(
          '<img src="data:image/png;base64,${base64Encode(png)}" '
          'alt="A chart" />',
        ),
      );
    });

    test('an SVG too', () async {
      final String html = await htmlWith(
        '![A chart](chart.svg)',
        utf8.encode('<svg xmlns="http://www.w3.org/2000/svg"></svg>'),
      );

      expect(html, contains('src="data:image/svg+xml;base64,'));
    });

    test('and one that cannot be had, or is not an image, keeps the src '
        'it was written with', () async {
      expect(
        await htmlWith('![A chart](img/chart.png)', null),
        contains('<img src="img/chart.png" alt="A chart" />'),
      );
      expect(
        await htmlWith('![A chart](img/chart.png)', utf8.encode('text')),
        contains('<img src="img/chart.png" alt="A chart" />'),
      );
    });
  });

  test('PDF is not this exporter\'s', () async {
    final Result<Uint8List, DocumentExporterFailure> result = await exporter
        .export(documentOf(const <ExporterBlockDto>[]), ExporterFormatEnum.pdf);

    expect(
      (result as Failure<Uint8List, DocumentExporterFailure>).failure,
      const DocumentExporterUnsupported(ExporterFormatEnum.pdf),
    );
  });
}
