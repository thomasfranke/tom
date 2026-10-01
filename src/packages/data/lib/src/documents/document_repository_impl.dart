/// The domain's document contract, fulfilled by the filesystem capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/documents/document_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabulary only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [DocumentRepository] over [DocumentDataSource].
///
/// Two translations: space-relative paths into absolute ones, which is why it
/// holds a [SpaceEntity], and a [FilesystemFailure] into a [DocumentFailure].
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
  /// Exhaustive with no default branch, so a new way for a disk to refuse
  /// breaks this rather than a save; the path is [asked] because the failure
  /// names the absolute one. `DocumentExternalChangeConflict` is the save
  /// flow's, not the disk's ([Decision
  /// 10](../../../../../../docs/technical/decisions/010-watcher-and-git-cooperate-by-protocol.md)).
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
