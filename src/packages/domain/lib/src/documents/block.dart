/// One top-level piece of a document.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/documents/block_kind_enum.dart';

part 'block.freezed.dart';

/// Where it is, what it says, and what kind of thing it is.
///
/// Never a parser's node: the package type could not cross into the domain
/// anyway, and structure is cheap to re-derive from [source] when something
/// needs to render it ([Spike
/// B](../../../../../../docs/technical/decisions/019-blocks-come-from-the-markdown-package.md)).
///
/// **There is no identity here.** Heading paths repeat, so `BlockDiffer`
/// aligns by position and similarity — which is why this carries no id.
@freezed
abstract class Block with _$Block {
  /// Creates a block.
  const factory Block({
    /// The first line of the block, zero-based and inclusive.
    required int startLine,

    /// The last line of the block, zero-based and inclusive.
    required int endLine,

    /// The document's own lines for that span, newline-joined.
    ///
    /// A slice of the document rather than a second copy of it: raw text and
    /// structure without duplicated state.
    required String source,

    /// What kind of block it is.
    required BlockKindEnum kind,
  }) = _Block;

  const Block._();

  /// How many lines it spans.
  int get lineCount => endLine - startLine + 1;
}
