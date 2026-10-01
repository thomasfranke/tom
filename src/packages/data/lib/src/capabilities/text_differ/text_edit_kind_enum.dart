/// What an alignment decided about one pair of entries.
library;

/// The four verdicts a text alignment can reach.
///
/// The capability's vocabulary; `SequenceEditKindEnum` is the domain's.
enum TextEditKindEnum {
  /// Both sides hold it, letter for letter.
  equal,

  /// Both sides hold it, written differently.
  changed,

  /// Only the new side holds it.
  added,

  /// Only the old side holds it.
  removed,
}
