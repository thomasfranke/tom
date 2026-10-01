/// What a branch is called.
library;

/// A branch's short name: `main`, `feat/rendered-diff-v0`, `origin/main`.
///
/// Short rather than the full ref, because `refs/heads/` is plumbing; an
/// `extension type` per [Decision
/// 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md).
extension type const BranchNameValueObject._(String value) {
  /// [value] as a branch name, throwing [ArgumentError] when it is not one.
  ///
  /// Parsing git output goes through [tryParse] instead.
  factory BranchNameValueObject(String value) =>
      tryParse(value) ??
      (throw ArgumentError.value(value, 'value', 'not a branch name'));

  /// [value] as a branch name, or null when it is not one.
  ///
  /// A strict subset of `git check-ref-format --branch`, the part a person
  /// trips over in a dialog: not empty, no whitespace, none of `~^:?*[\`,
  /// no `..` or `@{`, no empty segment, and no segment starting with `.`,
  /// ending with `.` or ending in `.lock` (git applies those per component,
  /// so `feat/.wip` fails like `.wip`). Control characters and a lone `@`
  /// are left to git, since no dialog produces them by accident.
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
