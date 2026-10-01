/// Splitting markdown into the constructs it is made of.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/src/markdown_parser/markdown_parser_failure.dart';

/// Finds the block-level constructs of a markdown text.
///
/// **Text in, positions out.** No parse tree crosses this contract, which is
/// what stops a package type reaching the domain ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)).
abstract interface class MarkdownParser {
  /// The outline of [markdown].
  ///
  /// The format, exactly: lines zero-based and inclusive, counted over
  /// `markdown.split('\n')`; spans in document order, never overlapping, top
  /// level (a list is one span, a table is one span); a line belonging to no
  /// construct — blank, a link reference definition — in no span. A construct
  /// the parser cannot place is left out, so an outline is always a truthful
  /// subset; failing is reserved for a parser that broke.
  Future<Result<MarkdownOutlineDto, MarkdownParserFailure>> outline(
    String markdown,
  );
}
