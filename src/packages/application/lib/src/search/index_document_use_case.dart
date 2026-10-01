/// Keeping one document's entry in the index current.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// One document filed again, for after it was written to disk.
///
/// The cheap half of indexing a space: a save changes one file, and the
/// document just saved is the one most likely to be searched for next.
final class IndexDocumentUseCase with UseCase {
  /// Creates the use case.
  const IndexDocumentUseCase({
    required this.searchFor,
    required this.observability,
  });

  /// How to reach the index of the space the document belongs to.
  final SearchRepositoryFor searchFor;

  @override
  final Observability observability;

  /// [document] of [space] filed again, replacing what was indexed for it.
  Future<Result<void, AppFailure>> index(
    SpaceEntity space,
    DocumentEntity document,
  ) => guard(() => searchFor(space).refresh(document));
}
