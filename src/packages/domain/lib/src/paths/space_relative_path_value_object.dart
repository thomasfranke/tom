/// A path as the app navigates it: relative to the space root.
library;

import 'package:tom_domain/src/paths/relative_path_syntax_rule.dart';

/// A path relative to the space root, with `/` separators.
///
/// A space is a folder, not a repository ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)):
/// the user often opens `docs/` inside a code repository, so the file tree,
/// the editor, the watcher and the search index all speak this path while
/// git speaks [RepoRelativePathValueObject]. Two types rather than one
/// `String` because
/// handing git a space-relative path — or showing the user a
/// repository-relative one — is the most probable bug in this application,
/// and `SpaceEntity` is the only place allowed to convert between them.
///
/// An `extension type` rather than a Freezed class, for the same reason as
/// [RepoRelativePathValueObject]: a single-field wrapper has nothing to gain
/// from a generated `copyWith` ([Decision
/// 16](../../../../../../docs/technical/decisions/016-freezed-is-mandatory-for-immutable-data.md)).
extension type const SpaceRelativePathValueObject._(String value) {
  /// Wraps [value], which must be relative and use `/` separators.
  ///
  /// Throws [ArgumentError] when it is not — the invariant is checked once,
  /// here, and never again. A path read off the disk goes through [tryParse]
  /// instead, which answers null rather than throwing.
  factory SpaceRelativePathValueObject(String value) =>
      tryParse(value) ??
      (throw ArgumentError.value(value, 'value', 'not a space-relative path'));

  /// [value] as a path, or null when it is not one.
  ///
  /// The door a directory listing uses: an entry that does not look like a
  /// path inside the space is one to skip, not an exception to throw across
  /// a boundary. The rules are listed on [isRelativePathSyntax].
  static SpaceRelativePathValueObject? tryParse(String value) =>
      isRelativePathSyntax(value)
      ? SpaceRelativePathValueObject._(value)
      : null;

  /// The last segment — the file or folder name.
  ///
  /// Never empty: [tryParse] refuses a path with an empty segment.
  String get name => value.split('/').last;

  /// The path [reference] names when written inside this document, or null
  /// when it points outside the space.
  ///
  /// How a link or an image in a document is read: relative to the folder
  /// the document is in, the way every markdown renderer resolves it, and
  /// from the space root when it starts with `/`. `.` and `..` are folded
  /// here — this is the one place `..` is welcome, because it is resolved
  /// before it can become a segment — and a reference that climbs above the
  /// root has left the space, which nothing may follow.
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

  /// Whether this path names a markdown file.
  ///
  /// The file tree shows everything and the editor opens only this
  /// (`docs/product/navigation/file-tree/doc.md`), so the question is asked
  /// often enough to belong on the type rather than at each call site.
  bool get isMarkdown => value.toLowerCase().endsWith('.md');
}
