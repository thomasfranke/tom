/// The name git gives an object.
library;

/// A commit's full 40-character object name.
///
/// Full rather than abbreviated, because an abbreviation is a display choice
/// ([short]); an `extension type` per [Decision
/// 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md).
extension type const CommitShaValueObject._(String value) {
  /// [value] as a sha, throwing [ArgumentError] when it is not one.
  ///
  /// Parsing git output goes through [tryParse] instead.
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
