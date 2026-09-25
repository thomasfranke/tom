/// The domain's block contract, fulfilled by the markdown capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_outline_dto.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_span_dto.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_span_kind_enum.dart';
import 'package:tom_data/src/documents/markdown_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabulary only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [BlockReaderPort] over [MarkdownDataSource].
///
/// Two translations: spans into blocks, sliced from the document's own lines
/// so a block's text is a view rather than a copy, and failures into the
/// product's vocabulary.
final class MarkdownBlockReaderImpl implements BlockReaderPort {
  /// Creates a reader over [markdown].
  const MarkdownBlockReaderImpl({required this.markdown});

  /// Where the outline comes from.
  final MarkdownDataSource markdown;

  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) => markdown
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
  /// Written out although one to one, so a parser reporting something the
  /// product has no word for breaks here.
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
  /// Exhaustive over [MarkdownParserFailure] with no default branch; a broken
  /// parser lands on the fallback because the product has no word for it.
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
