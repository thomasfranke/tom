/// The domain's block contract, fulfilled by the markdown capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// [BlockReader] over the [MarkdownParser] capability.
///
/// Two translations and nothing else. Spans into blocks: the capability
/// reports where each construct is and this slices the document's own lines
/// for it, so a block's text stays a view of the document rather than a
/// second copy. Failures into the product's vocabulary.
final class MarkdownBlockReader implements BlockReader {
  /// Creates a reader over [parser].
  const MarkdownBlockReader({required this.parser});

  /// What finds the constructs.
  final MarkdownParser parser;

  @override
  Future<Result<ParsedDocument>> read(Document document) async {
    final Result<MarkdownOutline> outlined = await parser.outline(
      document.content,
    );
    return switch (outlined) {
      Success<MarkdownOutline>(value: final MarkdownOutline outline) =>
        Success<ParsedDocument>(_documentOf(document, outline)),
      Failure<MarkdownOutline>(failure: final AppFailure failure) =>
        Failure<ParsedDocument>(_asDocumentFailure(failure, document.path)),
    };
  }

  /// [outline] read back against the lines it came from.
  static ParsedDocument _documentOf(
    Document document,
    MarkdownOutline outline,
  ) {
    final List<String> lines = document.content.split('\n');
    return ParsedDocument(
      document: document,
      blocks: List<Block>.unmodifiable(<Block>[
        for (final MarkdownSpan span in outline.spans)
          Block(
            startLine: span.startLine,
            endLine: span.endLine,
            source: lines.sublist(span.startLine, span.endLine + 1).join('\n'),
            kind: _asBlockKind(span.kind),
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
  static BlockKind _asBlockKind(MarkdownSpanKind kind) => switch (kind) {
    MarkdownSpanKind.paragraph => BlockKind.paragraph,
    MarkdownSpanKind.heading => BlockKind.heading,
    MarkdownSpanKind.list => BlockKind.list,
    MarkdownSpanKind.table => BlockKind.table,
    MarkdownSpanKind.code => BlockKind.code,
    MarkdownSpanKind.quote => BlockKind.quote,
    MarkdownSpanKind.rule => BlockKind.rule,
    MarkdownSpanKind.html => BlockKind.html,
  };

  /// What the capability reported, about the document the user asked for.
  ///
  /// Exhaustive over [MarkdownParserFailure] with no default branch. A
  /// broken parser is not something the product has words for, so it lands
  /// on the fallback rather than being dressed up as a file problem.
  static AppFailure _asDocumentFailure(
    AppFailure failure,
    SpaceRelativePath path,
  ) => switch (failure) {
    final MarkdownParserFailure parserFailure => switch (parserFailure) {
      MarkdownParserFailed(description: final String description) =>
        DocumentOperationFailed(path.value, description),
    },
    // Unreachable by the capability's contract: it returns nothing else.
    _ => failure,
  };
}
