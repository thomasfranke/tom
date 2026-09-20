/// What a branch is called.
library;

/// A branch's short name — `main`, `feat/rendered-diff-v0`, `origin/main`.
///
/// Short rather than the full ref: the product shows and switches by the name
/// a person types, and `refs/heads/` in front of it is plumbing.
///
/// An `extension type` rather than a Freezed class, per [Decision
/// 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md).
extension type const BranchName._(String value) {
  /// Wraps [value], which must be a name git would accept.
  ///
  /// Throws [ArgumentError] when it is not. Parsing git output goes through
  /// [tryParse] instead.
  factory BranchName(String value) =>
      tryParse(value) ??
      (throw ArgumentError.value(value, 'value', 'not a branch name'));

  /// [value] as a branch name, or null when it is not one.
  ///
  /// The rules checked are the ones `git check-ref-format` enforces that a
  /// person plausibly trips over: no leading or trailing `/`, no `..`, no
  /// whitespace, no `~^:?*[`, and not ending in `.lock`. The full grammar
  /// lives in git and is not worth restating — this catches the mistakes a
  /// branch dialog produces.
  static BranchName? tryParse(String value) {
    if (value.isEmpty ||
        value.startsWith('/') ||
        value.endsWith('/') ||
        value.endsWith('.lock') ||
        value.contains('..') ||
        _forbidden.hasMatch(value)) {
      return null;
    }
    return BranchName._(value);
  }

  static final RegExp _forbidden = RegExp(r'[\s~^:?*\[\\]');
}
