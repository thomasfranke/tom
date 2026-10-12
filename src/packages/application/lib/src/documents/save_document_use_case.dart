/// Writing the editor's buffer back to the file it came from.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// One document written to disk, which is the moment the file becomes the
/// truth again.
///
/// The write is atomic below this, so a crash mid-save leaves the old file
/// or the new one, never half of either.
final class SaveDocumentUseCase with UseCase {
  /// Creates the use case.
  const SaveDocumentUseCase({
    required this.documentsFor,
    required this.observability,
  });

  /// How to reach the documents of a space.
  final DocumentRepositoryFor documentsFor;

  @override
  final Observability observability;

  /// Writes [document] where its own path says, inside [space].
  ///
  /// [replacing] is the text the buffer was read as. Given, **the disk is
  /// asked first**: a file that no longer holds it was changed by somebody
  /// else, and the answer is [DocumentExternalChangeConflict] with nothing
  /// written (`docs/product/editor/source-mode/doc.md`). A file that is gone
  /// is written again, since that overwrites nobody's work.
  Future<Result<void, AppFailure>> save(
    SpaceEntity space,
    DocumentEntity document, {
    String? replacing,
  }) => guard(() async {
    final DocumentRepository documents = documentsFor(space);
    if (replacing != null &&
        await _changedSince(documents, document.path, replacing)) {
      return Failure<void, DocumentFailure>(
        DocumentExternalChangeConflict(document.path.value),
      );
    }
    return documents.write(document);
  });

  /// Whether the file at [path] holds something other than [read].
  ///
  /// Text that stopped being text counts; a disk that will not say does not,
  /// because the write after it reports that refusal in its own words.
  static Future<bool> _changedSince(
    DocumentRepository documents,
    SpaceRelativePathValueObject path,
    String read,
  ) async => switch (await documents.read(path)) {
    Success<DocumentEntity, DocumentFailure>(
      value: final DocumentEntity onDisk,
    ) =>
      onDisk.content != read,
    Failure<DocumentEntity, DocumentFailure>(failure: DocumentNotUtf8()) =>
      true,
    Failure<DocumentEntity, DocumentFailure>() => false,
  };
}
