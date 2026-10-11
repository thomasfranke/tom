/// [DocumentSearchService] held to the real parser: the heading an
/// occurrence is filed under has to be a heading the preview draws, and a
/// replacement has to leave the document the parser reads otherwise as it
/// was. The finder scans the buffer by itself; this is where the two meet.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const DocumentSearchService finder = DocumentSearchService();
  const HeadingAnchorService headings = HeadingAnchorService();
  const MarkdownBlockReaderImpl reader = MarkdownBlockReaderImpl(
    markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
  );

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

  /// The words of the nearest heading the parser reports at or above
  /// [line], or empty above the first one.
  String headingAbove(ParsedDocumentValueObject document, int line) {
    String words = '';
    for (final BlockValueObject block in document.blocks) {
      if (block.startLine > line) {
        break;
      }
      words = headings.textOf(block) ?? words;
    }
    return words;
  }

  /// Holds every occurrence of [terms] in [markdown] to the parser's
  /// headings, and expects [count] of them so an empty search cannot pass.
  Future<void> expectHeadingsAgree(
    String markdown,
    String terms, {
    required int count,
  }) async {
    final ParsedDocumentValueObject document = await parsed(markdown);
    final List<OccurrenceValueObject> found = finder.find(markdown, terms);

    expect(found, hasLength(count));
    for (final OccurrenceValueObject each in found) {
      expect(
        each.heading,
        headingAbove(document, each.line),
        reason: 'the occurrence on line ${each.line}',
      );
    }
  }

  const String document = '''
Intro mentions the diff once.

# Guide

The diff is rendered.

## Reading a diff

A diff of prose, not of lines.

### Marks

- added
- removed, in the diff

| Mark | In the diff |
|---|---|
| A | added |
''';

  group('the heading an occurrence is filed under is one the parser '
      'reads', () {
    test('in a document of plain hash headings, at every level', () async {
      await expectHeadingsAgree(document, 'diff', count: 6);
    });

    test('an occurrence in the heading itself is under that '
        'heading', () async {
      final List<OccurrenceValueObject> found = finder.find(
        document,
        'reading',
      );

      expect(found.single.heading, 'Reading a diff');
      expect(
        headingAbove(await parsed(document), found.single.line),
        'Reading a diff',
      );
    });

    test('a tag written with no space after its hash is no heading to '
        'either', () async {
      await expectHeadingsAgree(
        '# Guide\n\n#release notes mention the diff.\n',
        'diff',
        count: 1,
      );
    });

    test('a hash line indented as code is no heading to either', () async {
      await expectHeadingsAgree(
        '# Guide\n\nProse.\n\n    # not a heading\n    the diff\n',
        'diff',
        count: 1,
      );
    });

    test(
      'a hash line inside a fence is not a heading',
      () async {
        await expectHeadingsAgree(
          '# Guide\n\n```sh\n# Install the tools\ntom diff\n```\n\n'
              'The diff again.\n',
          'diff',
          count: 2,
        );
      },
      skip:
          'defect S7-P7: the finder reads headings off the text by itself, '
          'so a `#` comment inside a fence files every occurrence after it '
          'under "Install the tools"',
    );

    test(
      'an underlined heading is a heading',
      () async {
        await expectHeadingsAgree(
          'Guide\n=====\n\nThe diff.\n\nReading\n-------\n\nA diff.\n',
          'diff',
          count: 2,
        );
      },
      skip:
          'defect S7-P7: the finder knows hash headings only, so an '
          'occurrence under an underlined heading is filed under none',
    );

    test(
      'closing hashes are not part of the heading',
      () async {
        await expectHeadingsAgree(
          '## Style ##\n\nThe diff.\n',
          'diff',
          count: 1,
        );
      },
      skip:
          'defect S7-P7: the finder keeps the closing hashes — "Style ##" '
          'where the preview draws "Style"',
    );
  });

  group('where an occurrence is', () {
    test('its line falls inside the block the parser cut around it', () async {
      final ParsedDocumentValueObject read = await parsed(document);

      for (final OccurrenceValueObject each in finder.find(document, 'diff')) {
        final BlockValueObject block = read.blocks.singleWhere(
          (BlockValueObject it) =>
              it.startLine <= each.line && each.line <= it.endLine,
        );
        expect(block.source.toLowerCase(), contains('diff'));
        expect(document.substring(each.start, each.end), each.matched);
      }
    });

    test('in a document with Windows line endings the line is still the '
        'line, and the excerpt carries no carriage return', () {
      final String windows = document.replaceAll('\n', '\r\n');

      final List<OccurrenceValueObject> unix = finder.find(document, 'diff');
      final List<OccurrenceValueObject> found = finder.find(windows, 'diff');

      expect(
        found.map((OccurrenceValueObject it) => it.line),
        unix.map((OccurrenceValueObject it) => it.line),
      );
      expect(
        found.map((OccurrenceValueObject it) => it.heading),
        unix.map((OccurrenceValueObject it) => it.heading),
      );
      for (final OccurrenceValueObject each in found) {
        expect(each.excerpt, isNot(contains('\r')));
        expect(
          each.excerpt.substring(each.excerptStart),
          startsWith(each.matched),
        );
      }
    });
  });

  group('replacing, read back by the parser', () {
    test('every occurrence replaced leaves the same blocks, of the same '
        'kinds, on the same lines', () async {
      final ParsedDocumentValueObject was = await parsed(document);

      final String replaced = finder.replaceAll(document, 'diff', 'comparison');
      final ParsedDocumentValueObject now = await parsed(replaced);

      expect(finder.find(replaced, 'diff'), isEmpty);
      expect(finder.find(replaced, 'comparison'), hasLength(6));
      expect(
        <String>[
          for (final BlockValueObject block in now.blocks)
            '${block.kind.name} ${block.startLine}..${block.endLine}',
        ],
        <String>[
          for (final BlockValueObject block in was.blocks)
            '${block.kind.name} ${block.startLine}..${block.endLine}',
        ],
      );
    });

    test('line endings and a missing final newline are kept, byte for '
        'byte', () {
      final String windows = document.replaceAll('\n', '\r\n').trimRight();

      final String replaced = finder.replaceAll(windows, 'diff', 'comparison');

      expect(replaced, windows.replaceAll('diff', 'comparison'));
      expect(
        '\r\n'.allMatches(replaced),
        hasLength('\r\n'.allMatches(windows).length),
      );
      expect(replaced, isNot(endsWith('\n')));
    });

    test('one occurrence found before the buffer moved is refused, and '
        'the text handed back is none', () {
      final OccurrenceValueObject stale = finder.find(document, 'rendered')[0];

      expect(finder.replace('# Guide\n\n$document', stale, 'drawn'), isNull);
      expect(
        finder.replace(document, stale, 'drawn'),
        document.replaceFirst('rendered', 'drawn'),
      );
    });
  });
}
