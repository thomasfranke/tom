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
  Future<Result<void, AppFailure>> save(
    SpaceEntity space,
    DocumentEntity document,
  ) => guard(() => documentsFor(space).write(document));
}
