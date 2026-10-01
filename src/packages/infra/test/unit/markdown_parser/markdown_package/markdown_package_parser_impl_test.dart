import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const MarkdownPackageParserImpl parser = MarkdownPackageParserImpl();

  /// The outline of [markdown], or a failed test.
  Future<MarkdownOutlineDto> outlineOf(String markdown) async {
    final Result<MarkdownOutlineDto, MarkdownParserFailure> result =
        await parser.outline(markdown);
    return (result as Success<MarkdownOutlineDto, MarkdownParserFailure>).value;
  }

  /// Every span of [markdown] as `kind start..end`.
  Future<List<String>> spansOf(String markdown) async => <String>[
    for (final MarkdownSpanDto span in (await outlineOf(markdown)).spans)
      '${span.kind.name} ${span.startLine}..${span.endLine}',
  ];

  group('what it reports', () {
    test('a heading and a paragraph, with the line they are on', () async {
      expect(await spansOf('# Title\n\nSome prose.\n'), <String>[
        'heading 0..0',
        'paragraph 2..2',
      ]);
    });

    test('a list is one span, whatever it nests', () async {
      expect(await spansOf('- one\n- two\n  - nested\n- three\n'), <String>[
        'list 0..3',
      ]);
    });

    test('a table is one span, header row and all', () async {
      expect(await spansOf('| a | b |\n|---|---|\n| 1 | 2 |\n'), <String>[
        'table 0..2',
      ]);
    });

    test('a fenced code block keeps its fences', () async {
      expect(await spansOf('```dart\nvoid main() {}\n```\n'), <String>[
        'code 0..2',
      ]);
    });

    test('every flavour of list and code is placed too', () async {
      // One case per syntax subclass, since one nothing exercises could stop
      // recording unnoticed.
      expect(
        await spansOf(
          '1. one\n2. two\n\n'
          '- [ ] todo\n- [x] done\n\n'
          '1. [ ] first\n\n'
          // Prose in between, because four spaces straight after a list is
          // that item's second paragraph and not a code block.
          'Prose.\n\n'
          '    indented();\n',
        ),
        <String>[
          'list 0..1',
          'list 3..4',
          'list 6..6',
          'paragraph 8..8',
          'code 10..10',
        ],
      );
    });

    test('a heading carrying an id is still a heading', () async {
      expect(await spansOf('# Title {#top}\n\nSetext {#s}\n=====\n'), <String>[
        'heading 0..0',
        'heading 2..3',
      ]);
    });

    test('anything else the parser makes an element of is html', () async {
      // A GitHub alert becomes a `div`, which the product has no word for.
      expect(await spansOf('> [!NOTE]\n> Mind this.\n'), <String>['html 0..1']);
    });

    test('a quote, a rule and raw html each get their own', () async {
      expect(await spansOf('> quoted\n\n---\n\n<div>raw</div>\n'), <String>[
        'quote 0..0',
        'rule 2..2',
        'html 4..4',
      ]);
    });
  });

  group('the positions', () {
    test('a setext heading starts at its text, not at its underline', () async {
      expect(await spansOf('Title\n=====\n\nProse.\n'), <String>[
        'heading 0..1',
        'paragraph 3..3',
      ]);
    });

    test('identical lines do not collapse onto the first of them', () async {
      expect(
        await spansOf('| 1 | 2 |\n|---|---|\n| x | y |\n| x | y |\n\nEnd.\n'),
        <String>['table 0..3', 'paragraph 5..5'],
      );
    });

    test('spans are in order and never overlap', () async {
      final List<MarkdownSpanDto> spans = (await outlineOf(
        '# A\n\nOne.\n\n## B\n\nTwo.\n',
      )).spans;

      for (int i = 1; i < spans.length; i++) {
        expect(spans[i].startLine, greaterThan(spans[i - 1].endLine));
      }
    });

    test('a blank line belongs to no span', () async {
      final List<MarkdownSpanDto> spans = (await outlineOf('A.\n\nB.\n')).spans;

      expect(spans.map((MarkdownSpanDto s) => s.startLine), <int>[0, 2]);
    });
  });

  group('link reference definitions', () {
    test('travel as their own lines, so a fragment can carry them', () async {
      const String markdown = 'See [the docs][d].\n\n[d]: https://tom.dev\n';

      final MarkdownOutlineDto outline = await outlineOf(markdown);

      expect(outline.linkDefinitions, '[d]: https://tom.dev');
      // And the definition is not a span: nothing draws it.
      expect(outline.spans, <MarkdownSpanDto>[
        const MarkdownSpanDto(
          startLine: 0,
          endLine: 0,
          kind: MarkdownSpanKindEnum.paragraph,
        ),
      ]);
    });

    test('a document with none says so with an empty string', () async {
      expect((await outlineOf('Just prose.\n')).linkDefinitions, isEmpty);
    });

    test('a title comes back quoted, the way it was written', () async {
      const String markdown = '[d]: https://tom.dev "The docs"\n\nSee [x][d].';

      expect(
        (await outlineOf(markdown)).linkDefinitions,
        '[d]: https://tom.dev "The docs"',
      );
    });

    test('a line inside a code block is not mistaken for one', () async {
      expect(
        (await outlineOf('```\n[d]: https://tom.dev\n```\n')).linkDefinitions,
        isEmpty,
      );
    });
  });

  group('what it leaves out', () {
    test('an empty document has no spans and does not fail', () async {
      expect((await outlineOf('')).spans, isEmpty);
    });

    test('a footnote definition is dropped, not placed wrongly', () async {
      // The parser synthesises a footnotes section corresponding to no lines
      // at all, and the definition itself is reported as a footnote rather
      // than as a block.
      final List<String> spans = await spansOf('Text.[^a]\n\n[^a]: Note.\n');

      expect(spans.first, 'paragraph 0..0');
      expect(spans.where((String s) => s.contains('-1')), isEmpty);
    });
  });

  group('the footnotes it reports', () {
    /// Every footnote of [markdown] as `number label: text`.
    Future<List<String>> notesOf(String markdown) async => <String>[
      for (final MarkdownFootnoteDto note in (await outlineOf(markdown))
          .footnotes)
        '${note.number} ${note.label}: ${note.text}',
    ];

    test('a document with none reports none', () async {
      expect(await notesOf('# Title\n\nProse.\n'), isEmpty);
    });

    test('the note is what was written, without the syntax that held it',
        () async {
      expect(await notesOf('Text.[^a]\n\n[^a]: The note itself.\n'), <String>[
        '1 a: The note itself.',
      ]);
    });

    test('they are numbered in the order they are first cited', () async {
      // Not the order they are defined in: that is what every renderer does,
      // and a block cannot see the citations in other blocks.
      expect(
        await notesOf(
          'First.[^b]\n\nSecond.[^a]\n\n[^a]: A.\n\n[^b]: B.\n',
        ),
        <String>['1 b: B.', '2 a: A.'],
      );
    });

    test('a definition nobody cites is not a footnote', () async {
      // The parser only collects the ones a reference matched, and a note
      // with no marker has nothing to be the foot of.
      expect(await notesOf('Prose.\n\n[^a]: Uncited.\n'), isEmpty);
    });

    test('a definition inside a fence is text, not a note', () async {
      expect(
        await notesOf('Text.[^a]\n\n```\n[^a]: Not one.\n```\n'),
        isEmpty,
      );
    });
  });
}
