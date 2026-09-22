/// A path as git reports it: relative to the repository root.
library;

import 'package:tom_domain/src/paths/relative_path_syntax_rule.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';

/// A path relative to the repository root, with `/` separators.
///
/// The most probable bug in this application is path confusion — `root`
/// against `repositoryRoot` ([SpaceRelativePathValueObject] is the other side),
/// relative against absolute ([Decision
/// 15](../../../../../../docs/technical/decisions/015-ddd-is-applied-selectively.md)).
/// A distinct type is what makes passing the wrong one a compile error
/// instead of something a user finds.
///
/// An `extension type` rather than a Freezed class: a single-field wrapper
/// has nothing to gain from a generated `copyWith`, and this one costs
/// nothing at runtime ([Decision
/// 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md)).
extension type const RepoRelativePathValueObject._(String value) {
  /// Wraps [value], which must be relative and use `/` separators.
  ///
  /// Throws [ArgumentError] when it is not — the invariant is checked once,
  /// here, and never again. Parsing untrusted output goes through
  /// [tryParse] instead, which answers null rather than throwing.
  factory RepoRelativePathValueObject(String value) =>
      tryParse(value) ??
      (throw ArgumentError.value(
        value,
        'value',
        'not a repository-relative path',
      ));

  /// [value] as a path, or null when it is not one.
  ///
  /// The door a parser uses: git output that does not look like a path is a
  /// record to skip, not an exception to throw across a boundary. It is also
  /// the door a person's typing will come through, so the rules are the
  /// invariant itself rather than a sanity check — they are listed on
  /// [isRelativePathSyntax], and shared with
  /// [SpaceRelativePathValueObject] so that relaxing one cannot silently
  /// leave the other behind.
  static RepoRelativePathValueObject? tryParse(String value) =>
      isRelativePathSyntax(value) ? RepoRelativePathValueObject._(value) : null;

  /// The last segment — the file or folder name.
  ///
  /// Never empty: [tryParse] refuses a path with an empty segment.
  String get name => value.split('/').last;
}
