/// Reading the list Home offers.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The spaces to offer going back to, most recent first.
///
/// One click back into a space is the reason Home has a list at all
/// (`docs/product/home/doc.md`).
///
/// Nothing here checks whether the folders are still there: a row whose
/// folder went away is still shown, because the product's answer to that is
/// to offer to forget it — and checking would mean touching the disk once
/// per row of a list the user may not click.
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
  Future<Result<List<RecentSpace>, AppFailure>> list() => guard(recents.list);
}
