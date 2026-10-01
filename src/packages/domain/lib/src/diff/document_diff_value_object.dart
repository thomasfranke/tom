/// A document compared against another version of itself.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/diff/diff_block_value_object.dart';
import 'package:tom_domain/src/documents/parsed_document_value_object.dart';

part 'document_diff_value_object.freezed.dart';

/// What changed between two versions of one document, block by block.
///
/// Both parsed versions travel because a removed block is rendered from the
/// *old* version's scope: its link reference definitions resolve its links.
@freezed
abstract class DocumentDiffValueObject with _$DocumentDiffValueObject {
  /// A diff.
  const factory DocumentDiffValueObject({
    /// The version compared against: `HEAD`, a branch, a commit.
    required ParsedDocumentValueObject before,

    /// The version on screen, which for the working copy is the buffer.
    required ParsedDocumentValueObject after,

    /// Every block of both versions, in reading order.
    ///
    /// Handed over unmodifiable, never copied: Freezed compares collections
    /// element-wise and copies nothing.
    required List<DiffBlockValueObject> blocks,
  }) = _DocumentDiffValueObject;

  const DocumentDiffValueObject._();

  /// Whether the two versions say the same thing; an unchanged document is
  /// drawn with no diff at all
  /// (`docs/product/diff/rendered-diff/what-is-compared/doc.md`).
  bool get isUnchanged =>
      blocks.every((DiffBlockValueObject block) => !block.isChange);
}
