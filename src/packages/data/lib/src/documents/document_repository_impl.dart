/// The domain's document contract, fulfilled by the filesystem capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_failure.dart';
import 'package:tom_domain/tom_domain.dart';

/// [DocumentRepository] over the [Filesystem] capability.
///
/// Two translations, and nothing else. Paths: the capability works in
/// absolute paths because it knows nothing about spaces, and the domain
/// works in paths relative to the space root — [Space] is what converts, and
/// holding one is what makes this repository belong to a space. Failures: a
/// [FilesystemFailure] is technical and names an absolute path, a
/// [DocumentFailure] is the product's vocabulary and names the document the
/// user asked for.
///
/// The disk is read on every call. There is no cache here to go stale, which
/// is the whole reason editing a space alongside VS Code is a supported way
/// to work rather than a race
/// ([flows](../../../../../../docs/technical/flows.md)).
final class DocumentRepositoryImpl implements DocumentRepository {
  /// Creates a repository over [filesystem], for [space].
  const DocumentRepositoryImpl({required this.filesystem, required this.space});

  /// What reads and writes the disk.
  final Filesystem filesystem;

  /// The space every path on this repository is relative to.
  final Space space;

  @override
  Future<Result<Document, DocumentFailure>> read(SpaceRelativePath path) =>
      filesystem
          .readFile(space.absolutePathOf(path))
          .map((String text) => Document(path: path, content: text))
          .mapFailure(
            (FilesystemFailure failure) => _asDocumentFailure(failure, path),
          );

  @override
  Future<Result<void, DocumentFailure>> write(Document document) => filesystem
      .writeFile(space.absolutePathOf(document.path), document.content)
      .mapFailure(
        (FilesystemFailure failure) =>
            _asDocumentFailure(failure, document.path),
      );

  /// What the filesystem reported, about the document the caller asked for.
  ///
  /// Exhaustive over [FilesystemFailure] with no default branch, so a new
  /// way for a disk to refuse breaks this and not a user's save.
  ///
  /// The path comes from [asked] rather than from the failure: the
  /// capability answers in absolute paths, and the product's vocabulary is
  /// relative to the space root. They name the same file — this repository
  /// is what built the absolute one a line earlier — so the conversion is a
  /// substitution and not a guess.
  ///
  /// `DocumentExternalChangeConflict` is produced by nothing here: the disk
  /// cannot know an editor holds unsaved edits. It is the save flow's
  /// answer, after comparing what it read with what it is about to replace
  /// ([Decision
  /// 10](../../../../../../docs/technical/decisions/010-watcher-and-git-cooperate-by-protocol.md)).
  /// Every variant carries the technical failure as its cause, so the
  /// absolute path, the `errno` and whatever the adapter knew survive into a
  /// bug report without the product's vocabulary naming any of them.
  static DocumentFailure _asDocumentFailure(
    FilesystemFailure failure,
    SpaceRelativePath asked,
  ) => switch (failure) {
    FilesystemEntryNotFound() => DocumentNotFound(asked.value, cause: failure),
    FilesystemAccessDenied() => DocumentPermissionDenied(
      asked.value,
      cause: failure,
    ),
    FilesystemNotUtf8() => DocumentNotUtf8(asked.value, cause: failure),
    FilesystemOperationFailed() => DocumentOperationFailed(
      asked.value,
      cause: failure,
    ),
  };
}
