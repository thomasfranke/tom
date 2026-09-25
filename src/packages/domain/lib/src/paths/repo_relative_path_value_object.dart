/// A path as git reports it: relative to the repository root.
library;

import 'package:tom_domain/src/paths/relative_path_syntax_rule.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';

/// A path relative to the repository root, with `/` separators.
///
/// A distinct type from [SpaceRelativePathValueObject] so that confusing the
/// two is a compile error rather than something a user finds ([Decision
/// 15](../../../../../../docs/technical/decisions/015-ddd-is-applied-selectively.md));
/// an `extension type` per [Decision
/// 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md).
extension type const RepoRelativePathValueObject._(String value) {
  /// [value] as a path, throwing [ArgumentError] when it is not one.
  ///
  /// Parsing untrusted output goes through [tryParse] instead.
  factory RepoRelativePathValueObject(String value) =>
      tryParse(value) ??
      (throw ArgumentError.value(
        value,
        'value',
        'not a repository-relative path',
      ));

  /// [value] as a path, or null when it is not one.
  ///
  /// Git output that does not look like a path is a record to skip, not an
  /// exception; the rules are [isRelativePathSyntax], shared with
  /// [SpaceRelativePathValueObject].
  static RepoRelativePathValueObject? tryParse(String value) =>
      isRelativePathSyntax(value) ? RepoRelativePathValueObject._(value) : null;

  /// The last segment, the file or folder name; never empty.
  String get name => value.split('/').last;
}
