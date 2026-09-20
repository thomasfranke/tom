/// A path as git reports it: relative to the repository root.
library;

/// A path relative to the repository root, with `/` separators.
///
/// The most probable bug in this application is path confusion — `root`
/// against `repositoryRoot`, relative against absolute ([Decision
/// 15](../../../../../../docs/technical/decisions/015-ddd-is-applied-selectively.md)).
/// A distinct type is what makes passing the wrong one a compile error
/// instead of something a user finds.
///
/// An `extension type` rather than a Freezed class: a single-field wrapper
/// has nothing to gain from a generated `copyWith`, and this one costs
/// nothing at runtime ([Decision
/// 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md)).
extension type const RepoRelativePath._(String value) {
  /// Wraps [value], which must be relative and use `/` separators.
  ///
  /// Throws [ArgumentError] when it is not — the invariant is checked once,
  /// here, and never again. Parsing untrusted output goes through
  /// [tryParse] instead, which answers null rather than throwing.
  factory RepoRelativePath(String value) =>
      tryParse(value) ??
      (throw ArgumentError.value(
        value,
        'value',
        'not a repository-relative path',
      ));

  /// [value] as a path, or null when it is not one.
  ///
  /// The door a parser uses: git output that does not look like a path is a
  /// record to skip, not an exception to throw across a boundary.
  static RepoRelativePath? tryParse(String value) {
    if (value.isEmpty || value.startsWith('/') || value.contains(r'\')) {
      return null;
    }
    return RepoRelativePath._(value);
  }

  /// The last segment — the file or folder name.
  String get name => value.split('/').last;
}
