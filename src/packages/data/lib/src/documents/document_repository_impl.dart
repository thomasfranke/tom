/// The domain's document contract, fulfilled by the filesystem capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

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
  Future<Result<Document>> read(SpaceRelativePath path) async {
    final Result<String> content = await filesystem.readFile(
      space.absolutePathOf(path),
    );
    return switch (content) {
      Success<String>(value: final String text) => Success<Document>(
        Document(path: path, content: text),
      ),
      Failure<String>(failure: final AppFailure failure) => Failure<Document>(
        _asDocumentFailure(failure, path),
      ),
    };
  }

  @override
  Future<Result<void>> write(Document document) async {
    final Result<void> written = await filesystem.writeFile(
      space.absolutePathOf(document.path),
      document.content,
    );
    return switch (written) {
      Success<void>() => const Success<void>(null),
      Failure<void>(failure: final AppFailure failure) => Failure<void>(
        _asDocumentFailure(failure, document.path),
      ),
    };
  }

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
  static AppFailure _asDocumentFailure(
    AppFailure failure,
    SpaceRelativePath asked,
  ) => switch (failure) {
    final FilesystemFailure filesystemFailure => switch (filesystemFailure) {
      FilesystemEntryNotFound() => DocumentNotFound(asked.value),
      FilesystemAccessDenied() => DocumentPermissionDenied(asked.value),
      FilesystemNotUtf8() => DocumentNotUtf8(asked.value),
      FilesystemOperationFailed(description: final String description) =>
        DocumentOperationFailed(asked.value, description),
    },
    // Unreachable by the capability's contract: `Filesystem` returns nothing
    // else. Passed through rather than relabelled as a document failure it
    // is not.
    _ => failure,
  };
}
