/// [HeadingAnchorService] over headings the real parser produced, held to
/// the `id` the real HTML exporter writes for the same heading on a real
/// disk: an anchor that works in the app has to work in the page too.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;

  const HeadingAnchorService anchors = HeadingAnchorService();
  const MarkdownBlockReaderImpl reader = MarkdownBlockReaderImpl(
    markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
  );
  const ExportRepositoryImpl exports = ExportRepositoryImpl(
    source: ExportDataSource(
      exporters: <ExporterFormatEnum, DocumentExporter>{
        ExporterFormatEnum.html: MarkdownHtmlDocumentExporterImpl(),
      },
      filesystem: DartIoFilesystemImpl(),
    ),
  );

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_anchor_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  /// [markdown] split into blocks by the real parser.
  Future<ParsedDocumentValueObject> parsed(String markdown) async {
    final Result<ParsedDocumentValueObject, DocumentFailure> read = await reader
        .read(
          DocumentEntity(
            path: SpaceRelativePathValueObject('guides/writing.md'),
            content: markdown,
          ),
        );
    return (read as Success<ParsedDocumentValueObject, DocumentFailure>).value;
  }

  /// The headings of [document], in order.
  List<BlockValueObject> headingsOf(ParsedDocumentValueObject document) =>
      <BlockValueObject>[
        for (final BlockValueObject block in document.blocks)
          if (block.kind == BlockKindEnum.heading) block,
      ];

  /// The `id` of every heading in the page [document] exports as, in order.
  Future<List<String>> exportedIdsOf(ParsedDocumentValueObject document) async {
    final String path = '${tempDir.path}/writing.html';
    final Result<void, ExportFailure> exported = await exports.export(
      SpaceEntity(
        root: tempDir.path,
        repositoryRoot: tempDir.path,
        name: 'space',
      ),
      document,
      ExportFormatEnum.html,
      path,
    );
    expect(exported, isA<Success<void, ExportFailure>>());
    return <String>[
      for (final RegExpMatch heading in RegExp(
        r'<h[1-6] id="([^"]*)"',
      ).allMatches(File(path).readAsStringSync()))
        heading.group(1)!,
    ];
  }

  /// Holds [markdown] to the rule: the page carries one `id` per heading,
  /// and each `id`, used as an anchor, names the heading it was written on.
  Future<void> expectAnchorsMatchThePage(String markdown) async {
    final ParsedDocumentValueObject document = await parsed(markdown);
    final List<BlockValueObject> headings = headingsOf(document);
    final List<String> ids = await exportedIdsOf(document);

    expect(ids, hasLength(headings.length), reason: 'ids: $ids');
    for (int index = 0; index < ids.length; index++) {
      expect(
        anchors.headingOf(ids[index], document.blocks),
        same(headings[index]),
        reason:
            'the page calls heading $index "${ids[index]}", '
            'which is not the heading that anchor finds',
      );
    }
  }

  group('the heading an anchor names, over real blocks', () {
    test('a heading written with hashes', () async {
      final ParsedDocumentValueObject document = await parsed(
        '# Guide\n\nProse.\n\n## Getting started\n\nMore.\n',
      );

      expect(
        anchors.headingOf('getting-started', document.blocks)?.source,
        '## Getting started',
      );
      expect(
        anchors.headingOf('#Getting-Started', document.blocks)?.source,
        '## Getting started',
      );
    });

    test('an underlined heading, by its words and not its underline', () async {
      final ParsedDocumentValueObject document = await parsed(
        'Guide\n=====\n\nProse.\n\nGetting started\n---------------\n',
      );

      expect(
        anchors.headingOf('getting-started', document.blocks)?.source,
        'Getting started\n---------------',
      );
      expect(anchors.headingOf('guide', document.blocks)?.startLine, 0);
    });

    test('closing hashes are not part of the name', () async {
      final ParsedDocumentValueObject document = await parsed(
        '## Style ##\n\nProse.\n',
      );

      expect(anchors.headingOf('style', document.blocks)?.startLine, 0);
    });

    test('a link keeps its words, code keeps its text', () async {
      final ParsedDocumentValueObject document = await parsed(
        '## See [the guide](https://example.com/g)\n\n'
        'Prose.\n\n'
        '## The `tom` command\n',
      );

      expect(anchors.headingOf('see-the-guide', document.blocks), isNotNull);
      expect(anchors.headingOf('the-tom-command', document.blocks), isNotNull);
    });

    test('a repeat is reached by its suffix', () async {
      final ParsedDocumentValueObject document = await parsed(
        '## Notes\n\nFirst.\n\n## Notes\n\nSecond.\n\n## Notes\n\nThird.\n',
      );

      expect(anchors.headingOf('notes', document.blocks)?.startLine, 0);
      expect(anchors.headingOf('notes-1', document.blocks)?.startLine, 4);
      expect(anchors.headingOf('notes-2', document.blocks)?.startLine, 8);
      expect(anchors.headingOf('notes-3', document.blocks), isNull);
    });

    test('accents are kept, punctuation is dropped', () async {
      final ParsedDocumentValueObject document = await parsed(
        '## Revisão & publicação: o quê?\n\nProse.\n',
      );

      expect(
        anchors.headingOf('revisão--publicação-o-quê', document.blocks),
        isNotNull,
      );
    });

    test('a hash line inside a fence is no heading to name', () async {
      final ParsedDocumentValueObject document = await parsed(
        '# Guide\n\n```sh\n# Install\n```\n',
      );

      expect(anchors.headingOf('install', document.blocks), isNull);
    });
  });

  group('the anchor is the id the exported page carries', () {
    test('for headings written with hashes', () async {
      await expectAnchorsMatchThePage(
        '# Guide\n\nProse.\n\n## Getting started\n\nMore.\n\n### Step 2\n',
      );
    });

    test('for underlined headings', () async {
      await expectAnchorsMatchThePage(
        'Guide\n=====\n\nProse.\n\nGetting started\n---------------\n',
      );
    });

    test('for closing hashes', () async {
      await expectAnchorsMatchThePage('## Style ##\n\nProse.\n');
    });

    test('for code inside the heading', () async {
      await expectAnchorsMatchThePage('## The `tom` command\n\nProse.\n');
    });

    test('for punctuation', () async {
      await expectAnchorsMatchThePage(
        '## Questions & answers: why?\n\nProse.\n\n## What\'s new (2.0)\n',
      );
    });

    test('for emphasis inside the heading', () async {
      await expectAnchorsMatchThePage('## A *very* **bold** claim\n');
    });

    // The three below fail today for one reason: the page's ids are the
    // `markdown` package's, and the app's anchors are GitHub's rule.
    test('for a link inside the heading', () async {
      await expectAnchorsMatchThePage(
        '## See [the guide](https://example.com/g)\n\nProse.\n',
      );
    });

    test('for accents', () async {
      await expectAnchorsMatchThePage('## Revisão e publicação\n\nProse.\n');
    });

    test('for a repeated heading', () async {
      await expectAnchorsMatchThePage(
        '## Notes\n\nFirst.\n\n## Notes\n\nSecond.\n',
      );
    });
  });
}
