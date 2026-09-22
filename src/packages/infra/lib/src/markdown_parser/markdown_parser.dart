/// Splitting markdown into the constructs it is made of.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/markdown_parser/markdown_outline.dart';

/// Finds the block-level constructs of a markdown text.
///
/// **Text in, positions out.** No parse tree crosses this contract, which is
/// what stops a package type reaching the domain ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md))
/// and what a second implementation would have to promise.
abstract interface class MarkdownParser {
  /// The outline of [markdown].
  ///
  /// The format, exactly: lines are zero-based and inclusive, counted over
  /// `markdown.split('\n')`; spans are in document order and never overlap;
  /// a line belonging to no construct — a blank one, a link reference
  /// definition — is in no span.
  ///
  /// **Granularity is top level**: a list is one span and a table is one
  /// span, whatever they nest.
  ///
  /// A construct the parser cannot place is left out rather than guessed at,
  /// so an outline is always a truthful subset. Failing is reserved for a
  /// parser that broke.
  Future<Result<MarkdownOutline>> outline(String markdown);
}
