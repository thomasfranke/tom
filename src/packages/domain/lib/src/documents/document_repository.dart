/// What the application may ask of the documents in a space.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/documents/document_entity.dart';
import 'package:tom_domain/src/documents/document_failure.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';

/// The markdown files of one space.
///
/// One instance per space, every path relative to the space root. No cache
/// and no open-document state: a read goes to the disk, a write lands on it,
/// and the buffer in between is the editor's ([Decision
/// 10](../../../../../../docs/technical/decisions/010-watcher-and-git-cooperate-by-protocol.md)).
abstract interface class DocumentRepository {
  /// The document at [path].
  ///
  /// `DocumentNotFound` when nothing is there, `DocumentNotUtf8` for a file
  /// that cannot be read back losslessly (see [DocumentFailure]).
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  );

  /// Writes [document] where its path says, creating or replacing the file.
  ///
  /// Folders on the way are created, and the replacement is atomic: after a
  /// crash mid-save the file is what it was or what it was asked to become.
  Future<Result<void, DocumentFailure>> write(DocumentEntity document);
}
