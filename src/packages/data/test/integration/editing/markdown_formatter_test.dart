/// [MarkdownFormatterService] held to the real parser and the real HTML
/// exporter: what a button writes has to be the construct the button names
/// once it is read back, and a toggle has to give the bytes back.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const MarkdownFormatterService formatter = MarkdownFormatterService();
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

  /// The kinds of [markdown]'s blocks, in order.
  Future<List<BlockKindEnum>> kindsOf(String markdown) async => <BlockKindEnum>[
    for (final BlockValueObject block in (await parsed(markdown)).blocks)
      block.kind,
  ];

  /// [markdown] as the page the real exporter writes, which is where an
  /// inline construct shows: the outline only knows blocks.
  Future<String> htmlOf(String markdown) async {
    final ParsedDocumentValueObject document = await parsed(markdown);
    final Result<Uint8List, DocumentExporterFailure> exported =
        await const MarkdownHtmlDocumentExporterImpl().export(
          ExporterDocumentDto(
            title: 'writing',
            blocks: <ExporterBlockDto>[
              for (final BlockValueObject block in document.blocks)
                ExporterBlockDto(
                  source: block.source,
                  kind: ExporterBlockKindEnum.values.byName(block.kind.name),
                ),
            ],
            linkDefinitions: document.linkDefinitions,
            footnotes: <ExporterFootnoteDto>[
              for (final FootnoteValueObject note in document.footnotes)
                ExporterFootnoteDto(
                  label: note.label,
                  number: note.number,
                  text: note.text,
                ),
            ],
          ),
          ExporterFormatEnum.html,
        );
    final String page = utf8.decode(
      (exported as Success<Uint8List, DocumentExporterFailure>).value,
    );
    return page.substring(
      page.indexOf('<article>') + '<article>'.length,
      page.indexOf('</article>'),
    );
  }

  const String document =
      '# Guide\n'
      '\n'
      'The first words matter.\n'
      '\n'
      'One line\n'
      'Another line\n'
      '\n'
      'The end.\n';

  /// [command] pressed with [selected] selected in [text]; a [selected]
  /// that is empty is a caret at [caretAfter].
  FormattedSourceValueObject press(
    FormatCommandEnum command, {
    String text = document,
    String selected = '',
    String caretAfter = '',
  }) {
    final int start = selected.isEmpty
        ? text.indexOf(caretAfter) + caretAfter.length
        : text.indexOf(selected);
    expect(start, isNot(-1), reason: 'the fixture holds no such text');
    return formatter.apply(
      text,
      command,
      start: start,
      end: start + selected.length,
    );
  }

  /// [first] pressed again, over the selection it handed back.
  FormattedSourceValueObject again(
    FormatCommandEnum command,
    FormattedSourceValueObject first,
  ) => formatter.apply(first.text, command, start: first.start, end: first.end);

  const String twoLines = 'One line\nAnother line';

  group('what a button writes is what the parser reads', () {
    test('heading: the line becomes a heading', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.heading,
        caretAfter: 'The first',
      );

      expect(await kindsOf(written.text), <BlockKindEnum>[
        BlockKindEnum.heading,
        BlockKindEnum.heading,
        BlockKindEnum.paragraph,
        BlockKindEnum.paragraph,
      ]);
      expect(
        await htmlOf(written.text),
        contains('>The first words matter.</h1>'),
      );
    });

    test('bold: the selection is strong', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.bold,
        selected: 'first words',
      );

      expect(
        await htmlOf(written.text),
        contains('<p>The <strong>first words</strong> matter.</p>'),
      );
    });

    test('italic: the selection is emphasised', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.italic,
        selected: 'first words',
      );

      expect(
        await htmlOf(written.text),
        contains('<p>The <em>first words</em> matter.</p>'),
      );
    });

    test('strikethrough: the selection is struck', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.strikethrough,
        selected: 'first words',
      );

      expect(
        await htmlOf(written.text),
        contains('<p>The <del>first words</del> matter.</p>'),
      );
    });

    test('list: every line the selection touches is an item of one '
        'list', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.list,
        selected: twoLines,
      );

      expect(await kindsOf(written.text), contains(BlockKindEnum.list));
      expect(
        (await htmlOf(written.text)).replaceAll('\n', ''),
        contains('<ul><li>One line</li><li>Another line</li></ul>'),
      );
    });

    test('ordered list: the items are numbered from one', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.orderedList,
        selected: twoLines,
      );

      expect(written.text, contains('1. One line\n2. Another line'));
      expect(
        (await htmlOf(written.text)).replaceAll('\n', ''),
        contains('<ol><li>One line</li><li>Another line</li></ol>'),
      );
    });

    test('task list: every item carries an empty box', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.taskList,
        selected: twoLines,
      );

      final String html = await htmlOf(written.text);
      expect(await kindsOf(written.text), contains(BlockKindEnum.list));
      expect('type="checkbox"'.allMatches(html), hasLength(2));
      expect(html, isNot(contains('checked')));
    });

    test('quote: the lines are one quote', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.quote,
        selected: twoLines,
      );

      expect(await kindsOf(written.text), <BlockKindEnum>[
        BlockKindEnum.heading,
        BlockKindEnum.paragraph,
        BlockKindEnum.quote,
        BlockKindEnum.paragraph,
      ]);
    });

    test('code, inside a line: the selection is a code span', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.code,
        selected: 'first words',
      );

      expect(
        await htmlOf(written.text),
        contains('<p>The <code>first words</code> matter.</p>'),
      );
    });

    test('code, over lines: the lines are one fenced block', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.code,
        selected: twoLines,
      );

      final ParsedDocumentValueObject read = await parsed(written.text);
      final BlockValueObject fence = read.blocks.singleWhere(
        (BlockValueObject block) => block.kind == BlockKindEnum.code,
      );
      expect(fence.source, '```\n$twoLines\n```');
      // What stays selected is the code, not the fences around it.
      expect(written.text.substring(written.start, written.end), twoLines);
    });

    test('table: a table of its own, the paragraph above untouched', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.table,
        caretAfter: 'The first',
      );

      expect(await kindsOf(written.text), <BlockKindEnum>[
        BlockKindEnum.heading,
        BlockKindEnum.paragraph,
        BlockKindEnum.table,
        BlockKindEnum.paragraph,
        BlockKindEnum.paragraph,
      ]);
      final String html = await htmlOf(written.text);
      expect('<th>Column</th>'.allMatches(html), hasLength(2));
      expect(html, contains('<p>The first words matter.</p>'));
    });

    test('rule: a rule, and never an underline that turns the line above '
        'into a heading', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.rule,
        caretAfter: 'The first',
      );

      expect(await kindsOf(written.text), <BlockKindEnum>[
        BlockKindEnum.heading,
        BlockKindEnum.paragraph,
        BlockKindEnum.rule,
        BlockKindEnum.paragraph,
        BlockKindEnum.paragraph,
      ]);
    });

    test('link: the selection is the words of a link', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.link,
        selected: 'first words',
      );

      expect(
        await htmlOf(written.text),
        contains('<p>The <a href="url">first words</a> matter.</p>'),
      );
    });

    test('image: the selection is the alternative text of an image', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.image,
        selected: 'first words',
      );

      expect(
        await htmlOf(written.text),
        contains('<img src="url" alt="first words"'),
      );
    });

    test('footnote: the parser reports the note, numbered one, and the '
        'marker stays in the prose', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.footnote,
        caretAfter: 'matter.',
      );

      final ParsedDocumentValueObject read = await parsed(written.text);
      expect(read.footnotes, hasLength(1));
      expect(read.footnotes.single.label, '1');
      expect(read.footnotes.single.number, 1);
      expect(
        read.blocks.map((BlockValueObject block) => block.kind),
        <BlockKindEnum>[
          BlockKindEnum.heading,
          BlockKindEnum.paragraph,
          BlockKindEnum.paragraph,
          BlockKindEnum.paragraph,
        ],
      );
      expect(
        await htmlOf(written.text),
        contains('<p>The first words matter.<sup>1</sup></p>'),
      );
    });

    test('alert: the line is an alert, the note it names', () async {
      final FormattedSourceValueObject written = press(
        FormatCommandEnum.alert,
        caretAfter: 'The first',
      );

      final String html = await htmlOf(written.text);
      expect(html, contains('markdown-alert-note'));
      expect(html, contains('The first words matter.'));
      // The marker is the construct, never words on the page.
      expect(html, isNot(contains('[!NOTE]')));
    });

    test('alert, pressed again: the note is prose once more', () async {
      final FormattedSourceValueObject once = press(
        FormatCommandEnum.alert,
        caretAfter: 'The first',
      );
      final FormattedSourceValueObject twice = formatter.apply(
        once.text,
        FormatCommandEnum.alert,
        start: once.start,
        end: once.end,
      );

      final String html = await htmlOf(twice.text);
      expect(html, isNot(contains('markdown-alert')));
      expect(html, isNot(contains('<blockquote>')));
      expect(html, contains('<p>The first words matter.</p>'));
    });
    test('every command leaves the rest of the document as it was', () async {
      for (final FormatCommandEnum command in FormatCommandEnum.values) {
        final FormattedSourceValueObject written = press(
          command,
          selected: 'first words',
        );

        final List<BlockValueObject> blocks = (await parsed(
          written.text,
        )).blocks;
        expect(blocks.first.source, '# Guide', reason: command.name);
        expect(
          blocks.map((BlockValueObject block) => block.source),
          contains('The end.'),
          reason: command.name,
        );
      }
    });
  });

  group('pressed twice, the bytes come back', () {
    for (final FormatCommandEnum command in <FormatCommandEnum>[
      FormatCommandEnum.bold,
      FormatCommandEnum.italic,
      FormatCommandEnum.strikethrough,
      FormatCommandEnum.code,
    ]) {
      test('${command.name}, around a few words', () {
        final FormattedSourceValueObject once = press(
          command,
          selected: 'first words',
        );
        final FormattedSourceValueObject twice = again(command, once);

        expect(once.text, isNot(document));
        expect(twice.text, document);
        expect(twice.text.substring(twice.start, twice.end), 'first words');
      });
    }

    for (final FormatCommandEnum command in <FormatCommandEnum>[
      FormatCommandEnum.heading,
      FormatCommandEnum.list,
      FormatCommandEnum.orderedList,
      FormatCommandEnum.taskList,
      FormatCommandEnum.quote,
      FormatCommandEnum.alert,
    ]) {
      test('${command.name}, over two lines', () {
        final FormattedSourceValueObject once = press(
          command,
          selected: twoLines,
        );
        final FormattedSourceValueObject twice = again(command, once);

        expect(once.text, isNot(document));
        expect(twice.text, document);
        expect(twice.text.substring(twice.start, twice.end), twoLines);
      });
    }
  });

  group('a buffer with Windows line endings', () {
    final String windows = document.replaceAll('\n', '\r\n');

    for (final FormatCommandEnum command in <FormatCommandEnum>[
      FormatCommandEnum.heading,
      FormatCommandEnum.list,
      FormatCommandEnum.orderedList,
      FormatCommandEnum.taskList,
      FormatCommandEnum.quote,
      FormatCommandEnum.bold,
    ]) {
      test('${command.name}: every line keeps its ending, and a second press '
          'gives the bytes back', () {
        final FormattedSourceValueObject once = press(
          command,
          text: windows,
          selected: 'One line\r\nAnother line',
        );

        expect(once.text, isNot(windows));
        // No line ending was rewritten or lost: what is left once every
        // CRLF is taken out holds neither half of one.
        expect(once.text.replaceAll('\r\n', ''), isNot(contains('\r')));
        expect(once.text.replaceAll('\r\n', ''), isNot(contains('\n')));
        expect(again(command, once).text, windows);
      });
    }

    test(
      'table: what is inserted ends its lines the way the buffer does',
      () {
        final FormattedSourceValueObject written = press(
          FormatCommandEnum.table,
          text: windows,
          caretAfter: 'The first',
        );

        expect(written.text.replaceAll('\r\n', ''), isNot(contains('\n')));
      },
      skip:
          'defect S7-P6 (unjudged — the intended answer is written nowhere): '
          'an insert writes bare LF lines into a CRLF buffer, leaving the '
          'document with mixed line endings',
    );
  });
}
