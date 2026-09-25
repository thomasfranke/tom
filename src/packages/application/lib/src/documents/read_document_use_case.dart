/// Reading a document off the disk.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// One document's source, read off the disk every time.
///
/// No cache to go stale, so editing a space beside TOM is supported. It
/// stops at the text; splitting is `SplitDocumentUseCase`, because the
/// preview re-splits a buffer that never went to disk.
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
