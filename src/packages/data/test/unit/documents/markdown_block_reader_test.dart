import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  /// The document `content` is, at a fixed path.
  Document documentOf(String content) =>
      Document(path: SpaceRelativePath('guides/writing.md'), content: content);

  /// The reader over a parser answering [answer].
  MarkdownBlockReader readerOf(
    Result<MarkdownOutlineDto, MarkdownParserFailure> answer,
  ) => MarkdownBlockReader(parser: _Parser(answer: answer));

  group('spans become blocks', () {
    test('each block carries the document lines its span names', () async {
      const String content = '# Title\n\nSome prose.\n';
      final MarkdownBlockReader reader = readerOf(
        const Success<MarkdownOutlineDto, MarkdownParserFailure>(
          MarkdownOutlineDto(
            spans: <MarkdownSpanDto>[
              MarkdownSpanDto(
                startLine: 0,
                endLine: 0,
                kind: MarkdownSpanKindEnum.heading,
              ),
              MarkdownSpanDto(
                startLine: 2,
                endLine: 2,
                kind: MarkdownSpanKindEnum.paragraph,
              ),
            ],
            linkDefinitions: '',
          ),
        ),
      );

      final Result<ParsedDocument, DocumentFailure> result = await reader.read(
        documentOf(content),
      );

      expect(
        (result as Success<ParsedDocument, DocumentFailure>).value.blocks,
        <Block>[
          const Block(
            startLine: 0,
            endLine: 0,
            source: '# Title',
            kind: BlockKindEnum.heading,
          ),
          const Block(
            startLine: 2,
            endLine: 2,
            source: 'Some prose.',
            kind: BlockKindEnum.paragraph,
          ),
        ],
      );
    });

    test('a long span keeps its lines joined, newlines and all', () async {
      final MarkdownBlockReader reader = readerOf(
        const Success<MarkdownOutlineDto, MarkdownParserFailure>(
          MarkdownOutlineDto(
            spans: <MarkdownSpanDto>[
              MarkdownSpanDto(
                startLine: 0,
                endLine: 2,
                kind: MarkdownSpanKindEnum.code,
              ),
            ],
            linkDefinitions: '',
          ),
        ),
      );

      final Result<ParsedDocument, DocumentFailure> result = await reader.read(
        documentOf('```\ncode();\n```\n'),
      );

      expect(
        (result as Success<ParsedDocument, DocumentFailure>)
            .value
            .blocks
            .single
            .source,
        '```\ncode();\n```',
      );
    });

    test('the definitions travel with the document, not a block', () async {
      // A block rendered alone needs them; putting a copy on every block
      // would be the same string as many times as there are blocks.
      final MarkdownBlockReader reader = readerOf(
        const Success<MarkdownOutlineDto, MarkdownParserFailure>(
          MarkdownOutlineDto(
            spans: <MarkdownSpanDto>[],
            linkDefinitions: '[d]: https://tom.dev',
          ),
        ),
      );

      final Result<ParsedDocument, DocumentFailure> result = await reader.read(
        documentOf(''),
      );

      expect(
        (result as Success<ParsedDocument, DocumentFailure>)
            .value
            .linkDefinitions,
        '[d]: https://tom.dev',
      );
    });

    test('the document comes back with its blocks', () async {
      final Document document = documentOf('Prose.\n');
      final MarkdownBlockReader reader = readerOf(
        const Success<MarkdownOutlineDto, MarkdownParserFailure>(
          MarkdownOutlineDto(spans: <MarkdownSpanDto>[], linkDefinitions: ''),
        ),
      );

      final Result<ParsedDocument, DocumentFailure> result = await reader.read(
        document,
      );

      expect(
        (result as Success<ParsedDocument, DocumentFailure>).value.document,
        document,
      );
    });
  });

  group('every kind has a word in the domain', () {
    test('and the translation is one to one', () async {
      final MarkdownBlockReader reader = readerOf(
        Success<MarkdownOutlineDto, MarkdownParserFailure>(
          MarkdownOutlineDto(
            spans: <MarkdownSpanDto>[
              for (final (int i, MarkdownSpanKindEnum kind)
                  in MarkdownSpanKindEnum.values.indexed)
                MarkdownSpanDto(startLine: i, endLine: i, kind: kind),
            ],
            linkDefinitions: '',
          ),
        ),
      );

      final Result<ParsedDocument, DocumentFailure> result = await reader.read(
        documentOf(
          List<String>.filled(
            MarkdownSpanKindEnum.values.length,
            'x',
          ).join('\n'),
        ),
      );

      expect(
        (result as Success<ParsedDocument, DocumentFailure>).value.blocks.map(
          (Block block) => block.kind.name,
        ),
        MarkdownSpanKindEnum.values.map(
          (MarkdownSpanKindEnum kind) => kind.name,
        ),
      );
    });
  });

  group('a failure crosses in the product vocabulary', () {
    test('a parser that broke names the document, not the text', () async {
      // The capability says "the parser threw"; what the user has is a
      // document that would not open.
      const MarkdownParserFailed reported = MarkdownParserFailed(
        'stack overflow',
      );
      final MarkdownBlockReader reader = readerOf(
        const Failure<MarkdownOutlineDto, MarkdownParserFailure>(reported),
      );

      final Result<ParsedDocument, DocumentFailure> result = await reader.read(
        documentOf('anything'),
      );

      // The variant names the document and nothing else; "stack overflow" is
      // the parser's word and stays in the cause.
      final DocumentFailure failure =
          (result as Failure<ParsedDocument, DocumentFailure>).failure;
      expect(
        failure,
        const DocumentOperationFailed('guides/writing.md', cause: reported),
      );
      expect(failure.diagnostics, contains('stack overflow'));
    });
  });
}

/// A parser that answers what it was told to.
final class _Parser implements MarkdownParser {
  const _Parser({required this.answer});

  final Result<MarkdownOutlineDto, MarkdownParserFailure> answer;

  @override
  Future<Result<MarkdownOutlineDto, MarkdownParserFailure>> outline(
    String markdown,
  ) async => answer;
}
