/// The name git gives an object.
library;

/// A commit's full 40-character object name.
///
/// Full rather than abbreviated: an abbreviation is a display choice, and a
/// repository large enough to make a 7-character prefix ambiguous is exactly
/// the one where it matters. [short] is how the UI asks for fewer.
///
/// An `extension type` rather than a Freezed class, per [Decision
/// 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md).
extension type const CommitShaValueObject._(String value) {
  /// Wraps [value], which must be 40 hexadecimal characters.
  ///
  /// Throws [ArgumentError] when it is not. Parsing git output goes through
  /// [tryParse] instead.
  factory CommitShaValueObject(String value) =>
      tryParse(value) ??
      (throw ArgumentError.value(value, 'value', 'not a full commit sha'));

  /// [value] as a sha, or null when it is not one.
  static CommitShaValueObject? tryParse(String value) =>
      _hex.hasMatch(value) ? CommitShaValueObject._(value) : null;

  static final RegExp _hex = RegExp(r'^[0-9a-f]{40}$');

  /// The first seven characters, which is what a commit list shows.
  String get short => value.substring(0, 7);
}
