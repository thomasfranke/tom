/// A path as the app navigates it: relative to the space root.
library;

import 'package:tom_domain/src/paths/relative_path_syntax_rule.dart';

/// A path relative to the space root, with `/` separators.
///
/// A space is a folder, not a repository ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)),
/// so the tree, the editor and the search speak this while git speaks
/// `RepoRelativePathValueObject`, and `SpaceEntity` is the only converter;
/// an `extension type` per [Decision
/// 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md).
extension type const SpaceRelativePathValueObject._(String value) {
  /// [value] as a path, throwing [ArgumentError] when it is not one.
  ///
  /// A path read off the disk goes through [tryParse] instead.
  factory SpaceRelativePathValueObject(String value) =>
      tryParse(value) ??
      (throw ArgumentError.value(value, 'value', 'not a space-relative path'));

  /// [value] as a path, or null when it is not one.
  ///
  /// A listing entry that does not look like a path is one to skip, not an
  /// exception; the rules are [isRelativePathSyntax].
  static SpaceRelativePathValueObject? tryParse(String value) =>
      isRelativePathSyntax(value)
      ? SpaceRelativePathValueObject._(value)
      : null;

  /// The last segment, the file or folder name; never empty.
  String get name => value.split('/').last;

  /// The path [reference] names when written inside this document, or null
  /// when it points outside the space.
  ///
  /// Relative to the document's folder, or to the space root after a leading
  /// `/`. The one place `..` is folded rather than refused, and a reference
  /// that climbs above the root has left the space.
  SpaceRelativePathValueObject? resolve(String reference) {
    final bool fromRoot = reference.startsWith('/');
    final List<String> segments = fromRoot
        ? <String>[]
        : (value.split('/')..removeLast());
    for (final String segment in reference.split('/')) {
      switch (segment) {
        case '' || '.':
          continue;
        case '..':
          if (segments.isEmpty) {
            return null;
          }
          segments.removeLast();
        default:
          segments.add(segment);
      }
    }
    return tryParse(segments.join('/'));
  }

  /// Whether this path names a markdown file, the one thing the editor opens
  /// (`docs/product/navigation/file-tree/what-is-shown/doc.md`).
  bool get isMarkdown => value.toLowerCase().endsWith('.md');
}
