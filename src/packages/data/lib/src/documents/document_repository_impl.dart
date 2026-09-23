/// The domain's document contract, fulfilled by the filesystem capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/documents/document_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabulary only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [DocumentRepository] over [DocumentDataSource].
///
/// Two translations, and nothing else. Paths: the source works in absolute
/// paths because the disk does, and the domain works in paths relative to
/// the space root — [SpaceEntity] is what converts, and holding one is what
/// makes this repository belong to a space. Failures: a
/// [FilesystemFailure] is technical and names an absolute path, a
/// [DocumentFailure] is the product's vocabulary and names the document the
/// user asked for.
final class DocumentRepositoryImpl implements DocumentRepository {
  /// Creates a repository over [documents], for [space].
  const DocumentRepositoryImpl({required this.documents, required this.space});

  /// Where a document's text is read and written.
  final DocumentDataSource documents;

  /// The space every path on this repository is relative to.
  final SpaceEntity space;

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) => documents
      .read(space.absolutePathOf(path))
      .map((String text) => DocumentEntity(path: path, content: text))
      .mapFailure(
        (FilesystemFailure failure) => _asDocumentFailure(failure, path),
      );

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) =>
      documents
          .write(space.absolutePathOf(document.path), document.content)
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
    SpaceRelativePathValueObject asked,
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
