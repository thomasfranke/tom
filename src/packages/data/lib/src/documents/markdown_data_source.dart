/// Getting a markdown document's structure.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/markdown_parser/markdown_outline_dto.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where a document's outline comes from.
///
/// Thin, and declared anyway: a cache per document would belong here
/// ([Decision
/// 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md)).
final class MarkdownDataSource {
  /// Creates a source over [parser].
  const MarkdownDataSource({required this.parser});

  /// What finds the constructs.
  final MarkdownParser parser;

  /// Where each top-level construct of [markdown] begins and ends.
  Future<Result<MarkdownOutlineDto, MarkdownParserFailure>> outline(
    String markdown,
  ) => parser.outline(markdown);
}
