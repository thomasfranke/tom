/// Writing the editor's buffer back to the file it came from.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Writes one document to disk.
///
/// The moment the buffer stops being the app's private state and the file
/// becomes the truth again — the invariant the whole product rests on. The
/// write is atomic below this, so a crash mid-save leaves the old file or
/// the new one, never half of either.
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
