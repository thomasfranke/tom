/// One block, and what happened to it between two versions.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/documents/block_value_object.dart';

part 'diff_block_value_object.freezed.dart';

/// A block paired with what the diff decided about it.
///
/// Sealed rather than a flag on the block: only [DiffBlockModified] has two
/// sides, and the preview draws by an exhaustive `switch`.
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
  /// Both sides travel, for the word-level diff of v2.
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

  /// Whether this block gets a mark.
  bool get isChange => this is! DiffBlockUnchanged;
}
