/// [MarkdownHtmlDocumentExporterImpl] with real image files read from disk
/// and the page written to a real temporary folder: what travels inside the
/// page, what a title or a block of raw HTML does to it, and the one way it
/// fails.
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

  const MarkdownHtmlDocumentExporterImpl exporter =
      MarkdownHtmlDocumentExporterImpl();

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_html_export_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  ExporterBlockDto paragraph(String source) =>
      ExporterBlockDto(source: source, kind: ExporterBlockKindEnum.paragraph);

  /// The bytes of a fixture, read as the repository's reader would: null
  /// when the file is not there.
  Future<Uint8List?> fixture(String reference) async {
    final File file = File('test/fixtures/images/$reference');
    return file.existsSync() ? file.readAsBytesSync() : null;
  }

  Future<Result<Uint8List, DocumentExporterFailure>> export(
    List<ExporterBlockDto> blocks, {
    String title = 'Figure',
    List<ExporterFootnoteDto> footnotes = const <ExporterFootnoteDto>[],
    ExporterImageReader? readImage,
  }) => exporter.export(
    ExporterDocumentDto(
      title: title,
      blocks: blocks,
      linkDefinitions: '',
      footnotes: footnotes,
    ),
    ExporterFormatEnum.html,
    readImage: readImage,
  );

  /// The page [blocks] export as, or a failed test.
  Future<String> htmlOf(
    List<ExporterBlockDto> blocks, {
    String title = 'Figure',
    List<ExporterFootnoteDto> footnotes = const <ExporterFootnoteDto>[],
    ExporterImageReader? readImage,
  }) async {
    final Result<Uint8List, DocumentExporterFailure> result = await export(
      blocks,
      title: title,
      footnotes: footnotes,
      readImage: readImage,
    );
    return switch (result) {
      Success<Uint8List, DocumentExporterFailure>(
        value: final Uint8List bytes,
      ) =>
        utf8.decode(bytes),
      Failure<Uint8List, DocumentExporterFailure>(
        failure: final DocumentExporterFailure failure,
      ) =>
        fail('the export failed: $failure'),
    };
  }

  /// What each `<img>` of [html] points at, in order.
  List<String> sourcesIn(String html) => <String>[
    for (final RegExpMatch image in RegExp(
      r'<img src="([^"]*)"',
    ).allMatches(html))
      image.group(1)!,
  ];

  /// The bytes a `data:` [address] carries.
  Uint8List carriedBy(String address) =>
      base64Decode(address.substring(address.indexOf(',') + 1));

  group('an image from disk travels inside the page', () {
    for (final (String file, String type) in <(String, String)>[
      ('wide.png', 'image/png'),
      ('wide.jpg', 'image/jpeg'),
      ('figure.svg', 'image/svg+xml'),
    ]) {
      test('$file as $type, every byte of the file', () async {
        final String html = await htmlOf(<ExporterBlockDto>[
          paragraph('![The chart]($file)'),
        ], readImage: fixture);

        final String address = sourcesIn(html).single;
        expect(address, startsWith('data:$type;base64,'));
        expect(
          carriedBy(address),
          File('test/fixtures/images/$file').readAsBytesSync(),
        );
        expect(html, contains('alt="The chart"'));
      });
    }

    test('named twice it is read once, and both places carry it', () async {
      final List<String> asked = <String>[];

      final String html = await htmlOf(
        <ExporterBlockDto>[
          paragraph('![One](wide.png)'),
          paragraph('Again: ![Two](wide.png)'),
        ],
        readImage: (String reference) {
          asked.add(reference);
          return fixture(reference);
        },
      );

      expect(asked, <String>['wide.png']);
      final List<String> sources = sourcesIn(html);
      expect(sources, hasLength(2));
      expect(sources.first, sources.last);
      expect(sources.first, startsWith('data:image/png;base64,'));
    });

    test('in a footnote\'s text it travels too', () async {
      final String html = await htmlOf(
        <ExporterBlockDto>[paragraph('See the chart.[^c]')],
        footnotes: const <ExporterFootnoteDto>[
          ExporterFootnoteDto(
            label: 'c',
            number: 1,
            text: '![The chart](wide.jpg)',
          ),
        ],
        readImage: fixture,
      );

      expect(sourcesIn(html).single, startsWith('data:image/jpeg;base64,'));
    });

    test('one that is not on disk keeps the address it was written with, '
        'beside one that is', () async {
      final String html = await htmlOf(<ExporterBlockDto>[
        paragraph('![Here](wide.png) ![Gone](img/gone.png)'),
      ], readImage: fixture);

      final List<String> sources = sourcesIn(html);
      expect(sources.first, startsWith('data:image/png;base64,'));
      expect(sources.last, 'img/gone.png');
    });

    test('a file that is not an image keeps its address', () async {
      File('${tempDir.path}/notes.png').writeAsStringSync('not a picture');

      final String html = await htmlOf(
        <ExporterBlockDto>[paragraph('![Notes](notes.png)')],
        readImage: (String reference) async =>
            File('${tempDir.path}/$reference').readAsBytesSync(),
      );

      expect(sourcesIn(html), <String>['notes.png']);
    });

    test('five megabytes of image are carried whole, inside half a '
        'minute', () async {
      // A PNG by its first bytes, which is all the exporter reads of it.
      final Uint8List large = Uint8List(5 * 1024 * 1024)
        ..setAll(0, <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      for (int index = 8; index < large.length; index++) {
        large[index] = index * 31 % 251;
      }
      File('${tempDir.path}/large.png').writeAsBytesSync(large);

      final Stopwatch watch = Stopwatch()..start();
      final String html = await htmlOf(
        <ExporterBlockDto>[paragraph('![Large](large.png)')],
        readImage: (String reference) async =>
            File('${tempDir.path}/$reference').readAsBytesSync(),
      );
      watch.stop();

      expect(carriedBy(sourcesIn(html).single), large);
      expect(html, endsWith('</html>\n'));
      // Well under a second on a laptop; the bound is for a loaded CI
      // machine.
      expect(watch.elapsed, lessThan(const Duration(seconds: 30)));
    });
  });

  group('the page', () {
    test('lands on disk as UTF-8 a browser can open, accents and '
        'quotes as written', () async {
      final String path = '${tempDir.path}/Ação — resumo.html';
      final Result<Uint8List, DocumentExporterFailure> result =
          await export(const <ExporterBlockDto>[
            ExporterBlockDto(
              source: '# Ação — “resumo”',
              kind: ExporterBlockKindEnum.heading,
            ),
            ExporterBlockDto(
              source: 'Œuvre *naïve*, 文档 e 🚀.',
              kind: ExporterBlockKindEnum.paragraph,
            ),
          ], title: 'Ação — resumo');
      File(path).writeAsBytesSync(
        (result as Success<Uint8List, DocumentExporterFailure>).value,
      );

      final String read = File(path).readAsStringSync();
      expect(read, startsWith('<!DOCTYPE html>'));
      expect(read, contains('<meta charset="utf-8">'));
      expect(read, contains('<title>Ação — resumo</title>'));
      expect(read, contains('Ação — “resumo”</h1>'));
      expect(read, contains('<p>Œuvre <em>naïve</em>, 文档 e 🚀.</p>'));
      expect(read, endsWith('</html>\n'));
    });

    test('a title that tries to close itself stays a title: nothing it '
        'holds becomes markup', () async {
      final String html = await htmlOf(<ExporterBlockDto>[
        paragraph('Prose.'),
      ], title: 'a</title><script>alert(1)</script>');

      final String head = html.substring(0, html.indexOf('</head>'));
      expect('</title>'.allMatches(head), hasLength(1));
      expect(head, isNot(contains('<script')));
      expect(head, contains('&lt;script&gt;alert(1)'));
    });

    test('a document with no block is still a whole page', () async {
      final String html = await htmlOf(const <ExporterBlockDto>[]);

      expect(html, contains('<article>\n</article>'));
      expect(html, endsWith('</html>\n'));
    });

    test('raw HTML the document holds reaches the page as written, and '
        'the markdown inside it is still rendered', () async {
      final String html = await htmlOf(<ExporterBlockDto>[
        const ExporterBlockDto(
          source:
              '<details>\n<summary>More</summary>\n\nHidden *words*.\n\n'
              '</details>',
          kind: ExporterBlockKindEnum.html,
        ),
        paragraph('Press <kbd>⌘K</kbd> & search.'),
      ]);

      expect(html, contains('<details>\n<summary>More</summary>'));
      expect(html, contains('<p>Hidden <em>words</em>.</p>'));
      expect(html, contains('<p>Press <kbd>⌘K</kbd> &amp; search.</p>'));
    });

    test('five thousand blocks are one page, in order, inside half a '
        'minute', () async {
      final Stopwatch watch = Stopwatch()..start();
      final String html = await htmlOf(<ExporterBlockDto>[
        for (int index = 0; index < 5000; index++)
          paragraph('Paragraph number $index.'),
      ]);
      watch.stop();

      expect('<p>Paragraph number'.allMatches(html), hasLength(5000));
      expect(
        html.indexOf('number 4998.'),
        lessThan(html.indexOf('number 4999.')),
      );
      expect(watch.elapsed, lessThan(const Duration(seconds: 30)));
    });
  });

  group('each failure, from the exporter itself', () {
    test('write failed: an image whose file cannot be opened, with what '
        'the disk said and no page', () async {
      final String missing = '${tempDir.path}/gone.png';

      final Result<Uint8List, DocumentExporterFailure> result = await export(
        <ExporterBlockDto>[paragraph('![A chart](gone.png)')],
        // The reader the contract asks for answers null for a file it
        // cannot have; one that lets the disk's own error out is how the
        // exporter's catch-all is reached for real.
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
              title: 'Figure',
              blocks: <ExporterBlockDto>[paragraph('Prose.')],
              linkDefinitions: '',
            ),
            ExporterFormatEnum.pdf,
          );

      expect(
        (result as Failure<Uint8List, DocumentExporterFailure>).failure,
        const DocumentExporterUnsupported(ExporterFormatEnum.pdf),
      );
    });

    test('and the exporter that just failed writes the next page', () async {
      await export(
        <ExporterBlockDto>[paragraph('![A chart](gone.png)')],
        readImage: (String reference) async =>
            File('${tempDir.path}/gone.png').readAsBytesSync(),
      );

      expect(
        await htmlOf(<ExporterBlockDto>[paragraph('Prose.')]),
        contains('<p>Prose.</p>'),
      );
    });
  });
}
