/// One top-level piece of a document.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/documents/block_kind_enum.dart';

part 'block_value_object.freezed.dart';

/// Where it is, what it says, and what kind of thing it is.
///
/// Never a parser's node, and **no identity**: heading paths repeat, so
/// `BlockDifferService` aligns by position and similarity ([Spike
/// B](../../../../../../docs/technical/decisions/019-blocks-come-from-the-markdown-package.md)).
@freezed
abstract class BlockValueObject with _$BlockValueObject {
  /// A block.
  const factory BlockValueObject({
    /// The first line of the block, zero-based and inclusive.
    required int startLine,

    /// The last line of the block, zero-based and inclusive.
    required int endLine,

    /// The document's own lines for that span, newline-joined.
    required String source,

    /// What kind of block it is.
    required BlockKindEnum kind,
  }) = _BlockValueObject;

  const BlockValueObject._();

  /// How many lines it spans.
  int get lineCount => endLine - startLine + 1;
}
