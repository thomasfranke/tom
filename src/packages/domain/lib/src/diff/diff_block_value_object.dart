/// One block, and what happened to it between two versions.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/documents/block_value_object.dart';

part 'diff_block_value_object.freezed.dart';

/// A block paired with what the diff decided about it.
///
/// Sealed rather than a block carrying a flag: only [DiffBlockModified] has
/// two sides, and a `switch` over these is what the preview draws
/// (`docs/product/diff/rendered-diff/doc.md`).
@freezed
sealed class DiffBlockValueObject with _$DiffBlockValueObject {
  /// In both versions, letter for letter.
  const factory DiffBlockValueObject.unchanged(BlockValueObject block) =
      DiffBlockUnchanged;

  /// In the new version only.
  const factory DiffBlockValueObject.added(BlockValueObject block) =
      DiffBlockAdded;

  /// In the old version only.
  const factory DiffBlockValueObject.removed(BlockValueObject block) =
      DiffBlockRemoved;

  /// The same block, written differently.
  ///
  /// Both sides travel, which is what a word-level diff inside the block
  /// will need (v2) and what lets the UI render either one today.
  const factory DiffBlockValueObject.modified({
    required BlockValueObject before,
    required BlockValueObject after,
  }) = DiffBlockModified;

  const DiffBlockValueObject._();

  /// The side the preview draws: the new text, or what is gone.
  BlockValueObject get drawn => switch (this) {
    DiffBlockUnchanged(block: final BlockValueObject block) ||
    DiffBlockAdded(block: final BlockValueObject block) ||
    DiffBlockRemoved(block: final BlockValueObject block) => block,
    DiffBlockModified(after: final BlockValueObject after) => after,
  };

  /// Whether this block is one the reader has to be shown a mark against.
  bool get isChange => this is! DiffBlockUnchanged;
}
