/// What git has to say about the rows the tree is showing.
library;

import 'package:tom_domain/tom_domain.dart';

/// Git's reading, turned into the tree's vocabulary and asked by path.
///
/// Built once per reading rather than searched per row: a status names every
/// changed file in the **repository**, and the tree draws one space.
final class FileTreeChanges {
  const FileTreeChanges._(this._files, this._folders);

  /// Nothing changed, or nothing has been read yet.
  const FileTreeChanges.none()
    : _files = const <String, FileStateEnum>{},
      _folders = const <String>{};

  /// What [status] says about the files [space] shows.
  ///
  /// **A path the space does not contain is dropped**, which is ordinary
  /// rather than exceptional: git reports the whole repository, so a space
  /// opened at `docs/` routinely hears about source files the tree has no
  /// row for ([`domain/paths.md`](../../../../../../docs/technical/domain/paths.md)).
  factory FileTreeChanges.of(SpaceEntity space, GitStatusValueObject? status) {
    if (status == null) {
      return const FileTreeChanges.none();
    }
    final Map<String, FileStateEnum> files = <String, FileStateEnum>{};
    final Set<String> folders = <String>{};
    for (final StatusEntryValueObject entry in status.entries) {
      final SpaceRelativePathValueObject? path = space.toSpaceRelative(
        entry.path,
      );
      if (path == null) {
        continue;
      }
      files[path.value] = entry.state;
      // Every folder above it holds a change, which is what a folder shows
      // instead of a letter it cannot have.
      final List<String> segments = path.value.split('/');
      for (int depth = 1; depth < segments.length; depth++) {
        folders.add(segments.take(depth).join('/'));
      }
    }
    return FileTreeChanges._(files, folders);
  }

  final Map<String, FileStateEnum> _files;
  final Set<String> _folders;

  /// Whether git had nothing to say about this space.
  bool get isEmpty => _files.isEmpty;

  /// What happened to the file at [path], or null when nothing did.
  FileStateEnum? stateOf(SpaceRelativePathValueObject path) =>
      _files[path.value];

  /// Whether anything inside the folder at [path] changed.
  ///
  /// True for the folder of a changed file at any depth: a folder cannot
  /// show letters for rows it is not showing, and opening it is what says
  /// which.
  bool holdsChange(SpaceRelativePathValueObject path) =>
      _folders.contains(path.value);
}
