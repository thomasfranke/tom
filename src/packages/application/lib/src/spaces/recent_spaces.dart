/// Reading and pruning the list Home offers.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The spaces to offer going back to, most recent first.
///
/// One click back into a space is the reason Home has a list at all
/// (`docs/product/home/doc.md`). Nothing here checks whether the folders are
/// still there: a row whose folder went away is still shown, because the
/// product's answer to that is to offer to forget it rather than to hide it
/// — and checking would mean touching the disk once per row of a list the
/// user may not click.
final class ListRecentSpaces with UseCase {
  /// Creates the use case.
  const ListRecentSpaces({required this.recents, required this.observability});

  /// Where the list is kept.
  final RecentSpacesRepository recents;

  @override
  final Observability observability;

  /// The remembered spaces.
  Future<Result<List<RecentSpace>>> call() => guard(recents.list);
}

/// Drops one space from the list Home offers.
///
/// What the user reaches for when a row points at a folder that is gone, and
/// the only way anything leaves the list other than falling off the end of
/// it. Forgetting does not touch the folder — a space TOM forgets is a space
/// the user can still open by picking it again.
final class ForgetRecentSpace with UseCase {
  /// Creates the use case.
  const ForgetRecentSpace({required this.recents, required this.observability});

  /// Where the list is kept.
  final RecentSpacesRepository recents;

  @override
  final Observability observability;

  /// Forgets the space at [root].
  Future<Result<void>> call(String root) => guard(() => recents.forget(root));
}
