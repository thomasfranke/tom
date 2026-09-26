/// Finding a document by what is written in it.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The documents of a space whose contents match what was typed.
///
/// Contents and not names
/// (`docs/product/search/full-text-search/what-is-searched/doc.md`);
/// the index is local and already built, so this never reaches the network
/// and never reads the disk.
final class SearchSpaceUseCase with UseCase {
  /// Creates the use case.
  const SearchSpaceUseCase({
    required this.searchFor,
    required this.observability,
  });

  /// How to reach the index of the space being searched.
  final SearchRepositoryFor searchFor;

  @override
  final Observability observability;

  /// What in [space] matches [terms], best first and at most [limit] of them.
  Future<Result<List<SearchHitValueObject>, AppFailure>> find(
    SpaceEntity space,
    String terms, {
    required int limit,
  }) => guard(() => searchFor(space).find(terms, limit: limit));
}
