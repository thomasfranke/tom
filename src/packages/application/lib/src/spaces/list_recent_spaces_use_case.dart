/// Reading the list Home offers.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The spaces to offer going back to, most recent first
/// (`docs/product/home/recent-spaces/doc.md`).
///
/// Nothing here checks that the folders still exist: a row whose folder went
/// away is shown, and the product's answer is to offer to forget it.
final class ListRecentSpacesUseCase with UseCase {
  /// Creates the use case.
  const ListRecentSpacesUseCase({
    required this.recents,
    required this.observability,
  });

  /// Where the list is kept.
  final RecentSpacesRepository recents;

  @override
  final Observability observability;

  /// The remembered spaces.
  Future<Result<List<RecentSpaceEntity>, AppFailure>> list() =>
      guard(recents.list);
}
