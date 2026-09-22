/// The domain's block contract, fulfilled by the markdown capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_outline_dto.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_parser.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_parser_failure.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_span_dto.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_span_kind_enum.dart';
import 'package:tom_domain/tom_domain.dart';

/// [BlockReaderPort] over the [MarkdownParser] capability.
///
/// Two translations and nothing else. Spans into blocks: the capability
/// reports where each construct is and this slices the document's own lines
/// for it, so a block's text stays a view of the document rather than a
/// second copy. Failures into the product's vocabulary.
final class MarkdownBlockReader implements BlockReaderPort {
  /// Creates a reader over [parser].
  const MarkdownBlockReader({required this.parser});

  /// What finds the constructs.
  final MarkdownParser parser;

  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) => parser
      .outline(document.content)
      .map((MarkdownOutlineDto outline) => _documentOf(document, outline))
      .mapFailure(
        (MarkdownParserFailure failure) =>
            _asDocumentFailure(failure, document.path),
      );

  /// [outline] read back against the lines it came from.
  static ParsedDocumentValueObject _documentOf(
    DocumentEntity document,
    MarkdownOutlineDto outline,
  ) {
    final List<String> lines = document.content.split('\n');
    return ParsedDocumentValueObject(
      document: document,
      blocks: List<BlockValueObject>.unmodifiable(<BlockValueObject>[
        for (final MarkdownSpanDto span in outline.spans)
          BlockValueObject(
            startLine: span.startLine,
            endLine: span.endLine,
            source: lines.sublist(span.startLine, span.endLine + 1).join('\n'),
            kind: _asBlockKindEnum(span.kind),
          ),
      ]),
      linkDefinitions: outline.linkDefinitions,
    );
  }

  /// The same kind, in the product's vocabulary.
  ///
  /// One to one today, and still written out: the two enums answer to
  /// different owners, and the day a parser reports something the product
  /// has no word for, this is where the compiler says so.
  static BlockKindEnum _asBlockKindEnum(MarkdownSpanKindEnum kind) =>
      switch (kind) {
        MarkdownSpanKindEnum.paragraph => BlockKindEnum.paragraph,
        MarkdownSpanKindEnum.heading => BlockKindEnum.heading,
        MarkdownSpanKindEnum.list => BlockKindEnum.list,
        MarkdownSpanKindEnum.table => BlockKindEnum.table,
        MarkdownSpanKindEnum.code => BlockKindEnum.code,
        MarkdownSpanKindEnum.quote => BlockKindEnum.quote,
        MarkdownSpanKindEnum.rule => BlockKindEnum.rule,
        MarkdownSpanKindEnum.html => BlockKindEnum.html,
      };

  /// What the capability reported, about the document the user asked for.
  ///
  /// Exhaustive over [MarkdownParserFailure] with no default branch. A
  /// broken parser is not something the product has words for, so it lands
  /// on the fallback rather than being dressed up as a file problem.
  static DocumentFailure _asDocumentFailure(
    MarkdownParserFailure failure,
    SpaceRelativePathValueObject path,
  ) => switch (failure) {
    MarkdownParserFailed() => DocumentOperationFailed(
      path.value,
      cause: failure,
    ),
  };
}
