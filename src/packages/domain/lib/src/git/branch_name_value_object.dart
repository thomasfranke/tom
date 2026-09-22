/// What a branch is called.
library;

/// A branch's short name — `main`, `feat/rendered-diff-v0`, `origin/main`.
///
/// Short rather than the full ref: the product shows and switches by the name
/// a person types, and `refs/heads/` in front of it is plumbing.
///
/// An `extension type` rather than a Freezed class, per [Decision
/// 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md).
extension type const BranchNameValueObject._(String value) {
  /// Wraps [value], which must be a name git would accept.
  ///
  /// Throws [ArgumentError] when it is not. Parsing git output goes through
  /// [tryParse] instead.
  factory BranchNameValueObject(String value) =>
      tryParse(value) ??
      (throw ArgumentError.value(value, 'value', 'not a branch name'));

  /// [value] as a branch name, or null when it is not one.
  ///
  /// The rules checked are the ones `git check-ref-format` enforces that a
  /// person plausibly trips over in a branch dialog:
  ///
  /// - not empty, no whitespace, none of `~^:?*[\`;
  /// - no `..`, which names a range, and no `@{`, which names a reflog entry;
  /// - no empty segment — a leading `/`, a trailing `/` and a `//` in the
  ///   middle are all the same mistake;
  /// - no segment starting with `.`, ending with `.`, or ending in `.lock`.
  ///   Git applies these per component, not to the whole name, so `feat/.wip`
  ///   is refused for the same reason `.wip` is.
  ///
  /// The full grammar lives in git and is not worth restating — control
  /// characters and the lone `@` are left to git itself, because no dialog
  /// produces them by accident. What is checked here is checked so that a
  /// name a user typed fails in the dialog, with a sentence, rather than
  /// later as a raw error from `git branch`.
  static BranchNameValueObject? tryParse(String value) {
    if (value.isEmpty ||
        value.contains('..') ||
        value.contains('@{') ||
        _forbidden.hasMatch(value)) {
      return null;
    }
    for (final String segment in value.split('/')) {
      if (segment.isEmpty ||
          segment.startsWith('.') ||
          segment.endsWith('.') ||
          segment.endsWith('.lock')) {
        return null;
      }
    }
    return BranchNameValueObject._(value);
  }

  static final RegExp _forbidden = RegExp(r'[\s~^:?*\[\\]');
}
