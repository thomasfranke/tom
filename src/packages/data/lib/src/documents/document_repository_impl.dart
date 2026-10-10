/// The domain's document contract, fulfilled by the filesystem capability.
library;

import 'dart:typed_data';

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/documents/document_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabulary only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [DocumentRepository] over [DocumentDataSource].
///
/// Two translations: relative paths into absolute ones under [root], and a
/// [FilesystemFailure] into a [DocumentFailure]. The root is a folder rather
/// than a space because a pull request draft is a document outside one
/// ([Decision 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
final class DocumentRepositoryImpl implements DocumentRepository {
  /// Creates a repository over [documents], for the folder at [root].
  const DocumentRepositoryImpl({required this.documents, required this.root});

  /// Where a document's text is read and written.
  final DocumentDataSource documents;

  /// The absolute folder every path on this repository is relative to: a
  /// space's root, or the drafts folder inside `.git/`.
  final String root;

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) => documents
      .read(_absolute(path))
      .map((String text) => DocumentEntity(path: path, content: text))
      .mapFailure(
        (FilesystemFailure failure) => _asDocumentFailure(failure, path),
      );

  @override
  Future<Result<Uint8List, DocumentFailure>> readBytes(
    SpaceRelativePathValueObject path,
  ) => documents
      .readBytes(_absolute(path))
      .mapFailure(
        (FilesystemFailure failure) => _asDocumentFailure(failure, path),
      );

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) =>
      documents
          .create(_absolute(document.path), document.content)
          .mapFailure(
            (FilesystemFailure failure) =>
                _asDocumentFailure(failure, document.path),
          );

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) =>
      documents
          .write(_absolute(document.path), document.content)
          .mapFailure(
            (FilesystemFailure failure) =>
                _asDocumentFailure(failure, document.path),
          );

  /// [path] under [root], in the separator [root] is written in.
  String _absolute(SpaceRelativePathValueObject path) {
    final String separator = root.contains(r'\') ? r'\' : '/';
    final String base = root.endsWith('/') || root.endsWith(r'\')
        ? root.substring(0, root.length - 1)
        : root;
    return '$base$separator${path.value.replaceAll('/', separator)}';
  }

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
    FilesystemAlreadyExists() => DocumentAlreadyExists(
      asked.value,
      cause: failure,
    ),
    FilesystemOperationFailed() => DocumentOperationFailed(
      asked.value,
      cause: failure,
    ),
  };
}
