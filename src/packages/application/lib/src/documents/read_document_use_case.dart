/// Reading a document off the disk.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Reads one document's source.
///
/// The disk is read every time. There is no cache to go stale, which is what
/// makes editing a space beside TOM a supported way to work.
///
/// It stops at the text: splitting into blocks is `SplitDocumentUseCase`,
/// because the editor needs only this half and the preview re-splits a
/// buffer that never went to disk.
final class ReadDocumentUseCase with UseCase {
  /// Creates the use case.
  const ReadDocumentUseCase({
    required this.documentsFor,
    required this.observability,
  });

  /// How to reach the documents of a space.
  final DocumentRepositoryFor documentsFor;

  @override
  final Observability observability;

  /// The document at [path] inside [space], as it is on disk.
  Future<Result<DocumentEntity, AppFailure>> read(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) => guard(() => documentsFor(space).read(path));
}
