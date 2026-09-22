/// What the application may ask of the documents in a space.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/documents/document_entity.dart';
import 'package:tom_domain/src/documents/document_failure.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';

/// The markdown files of one space.
///
/// One instance per space, and every path on it is relative to that space's
/// root — never to the repository, which is git's business and a different
/// type ([SpaceRelativePathValueObject] against `RepoRelativePathValueObject`).
///
/// **The file on disk is the truth.** There is no cache to invalidate here
/// and no open-document state: a read goes to the disk, a write lands on it,
/// and what the editor holds between the two is the editor's buffer, not
/// this repository's ([Decision
/// 10](../../../../../../docs/technical/decisions/010-watcher-and-git-cooperate-by-protocol.md)).
abstract interface class DocumentRepository {
  /// Reads the document at [path].
  ///
  /// Fails with `DocumentNotFound` when nothing is there — which is ordinary
  /// rather than exceptional, since files move under an open editor — and
  /// with `DocumentNotUtf8` for a file TOM cannot read back losslessly, and
  /// therefore refuses to open at all rather than filling with replacement
  /// characters a save would write over the bytes they stood for.
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  );

  /// Writes [document] where its path says, creating or replacing the file.
  ///
  /// Folders on the way are created: saving into a folder the user just
  /// named is a create, not a missing file. The replacement is atomic —
  /// after a crash mid-save the file is what it was or what it was asked to
  /// become, never half of either.
  Future<Result<void, DocumentFailure>> write(DocumentEntity document);
}
