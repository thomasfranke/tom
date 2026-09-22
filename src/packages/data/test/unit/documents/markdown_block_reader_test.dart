import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  /// The document `content` is, at a fixed path.
  Document documentOf(String content) =>
      Document(path: SpaceRelativePath('guides/writing.md'), content: content);

  /// The reader over a parser answering [answer].
  MarkdownBlockReader readerOf(Result<MarkdownOutline> answer) =>
      MarkdownBlockReader(parser: _Parser(answer: answer));

  group('spans become blocks', () {
    test('each block carries the document lines its span names', () async {
      const String content = '# Title\n\nSome prose.\n';
      final MarkdownBlockReader reader = readerOf(
        const Success<MarkdownOutline>(
          MarkdownOutline(
            spans: <MarkdownSpan>[
              MarkdownSpan(
                startLine: 0,
                endLine: 0,
                kind: MarkdownSpanKind.heading,
              ),
              MarkdownSpan(
                startLine: 2,
                endLine: 2,
                kind: MarkdownSpanKind.paragraph,
              ),
            ],
            linkDefinitions: '',
          ),
        ),
      );

      final Result<ParsedDocument> result = await reader.read(
        documentOf(content),
      );

      expect((result as Success<ParsedDocument>).value.blocks, <Block>[
        const Block(
          startLine: 0,
          endLine: 0,
          source: '# Title',
          kind: BlockKind.heading,
        ),
        const Block(
          startLine: 2,
          endLine: 2,
          source: 'Some prose.',
          kind: BlockKind.paragraph,
        ),
      ]);
    });

    test('a long span keeps its lines joined, newlines and all', () async {
      final MarkdownBlockReader reader = readerOf(
        const Success<MarkdownOutline>(
          MarkdownOutline(
            spans: <MarkdownSpan>[
              MarkdownSpan(
                startLine: 0,
                endLine: 2,
                kind: MarkdownSpanKind.code,
              ),
            ],
            linkDefinitions: '',
          ),
        ),
      );

      final Result<ParsedDocument> result = await reader.read(
        documentOf('```\ncode();\n```\n'),
      );

      expect(
        (result as Success<ParsedDocument>).value.blocks.single.source,
        '```\ncode();\n```',
      );
    });

    test('the definitions travel with the document, not a block', () async {
      // A block rendered alone needs them; putting a copy on every block
      // would be the same string as many times as there are blocks.
      final MarkdownBlockReader reader = readerOf(
        const Success<MarkdownOutline>(
          MarkdownOutline(
            spans: <MarkdownSpan>[],
            linkDefinitions: '[d]: https://tom.dev',
          ),
        ),
      );

      final Result<ParsedDocument> result = await reader.read(documentOf(''));

      expect(
        (result as Success<ParsedDocument>).value.linkDefinitions,
        '[d]: https://tom.dev',
      );
    });

    test('the document comes back with its blocks', () async {
      final Document document = documentOf('Prose.\n');
      final MarkdownBlockReader reader = readerOf(
        const Success<MarkdownOutline>(
          MarkdownOutline(spans: <MarkdownSpan>[], linkDefinitions: ''),
        ),
      );

      final Result<ParsedDocument> result = await reader.read(document);

      expect((result as Success<ParsedDocument>).value.document, document);
    });
  });

  group('every kind has a word in the domain', () {
    test('and the translation is one to one', () async {
      final MarkdownBlockReader reader = readerOf(
        Success<MarkdownOutline>(
          MarkdownOutline(
            spans: <MarkdownSpan>[
              for (final (int i, MarkdownSpanKind kind)
                  in MarkdownSpanKind.values.indexed)
                MarkdownSpan(startLine: i, endLine: i, kind: kind),
            ],
            linkDefinitions: '',
          ),
        ),
      );

      final Result<ParsedDocument> result = await reader.read(
        documentOf(
          List<String>.filled(MarkdownSpanKind.values.length, 'x').join('\n'),
        ),
      );

      expect(
        (result as Success<ParsedDocument>).value.blocks.map(
          (Block block) => block.kind.name,
        ),
        MarkdownSpanKind.values.map((MarkdownSpanKind kind) => kind.name),
      );
    });
  });

  group('a failure crosses in the product vocabulary', () {
    test('a parser that broke names the document, not the text', () async {
      // The capability says "the parser threw"; what the user has is a
      // document that would not open.
      final MarkdownBlockReader reader = readerOf(
        const Failure<MarkdownOutline>(MarkdownParserFailed('stack overflow')),
      );

      final Result<ParsedDocument> result = await reader.read(
        documentOf('anything'),
      );

      expect(
        (result as Failure<ParsedDocument>).failure,
        const DocumentOperationFailed('guides/writing.md', 'stack overflow'),
      );
    });
  });
}

/// A parser that answers what it was told to.
final class _Parser implements MarkdownParser {
  const _Parser({required this.answer});

  final Result<MarkdownOutline> answer;

  @override
  Future<Result<MarkdownOutline>> outline(String markdown) async => answer;
}
