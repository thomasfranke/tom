/// What an alignment decided about one pair of entries.
library;

/// The four verdicts a text alignment can reach.
///
/// The capability's vocabulary, not the domain's: this one is about entries
/// of a sequence, and `SequenceEditKindEnum` is the same four once they are
/// about a document.
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
