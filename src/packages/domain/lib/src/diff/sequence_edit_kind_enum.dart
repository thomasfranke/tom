/// What an alignment decided about one pair of entries.
library;

/// The four things that can happen to an entry of a sequence.
///
/// The aligner's vocabulary, not the product's; `DiffBlockValueObject` is
/// the same four verdicts once they are about blocks.
enum SequenceEditKindEnum {
  /// Both sides hold it, letter for letter.
  equal,

  /// Both sides hold it, written differently.
  changed,

  /// Only the new side holds it.
  added,

  /// Only the old side holds it.
  removed,
}
