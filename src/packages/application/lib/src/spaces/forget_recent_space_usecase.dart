/// Dropping one space from the list Home offers.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Drops one space from the list Home offers.
///
/// What the user reaches for when a row points at a folder that is gone, and
/// the only way anything leaves the list other than falling off the end.
///
/// Forgetting does not touch the folder: a space TOM forgets is a space the
/// user can still open by picking it again.
final class ForgetRecentSpaceUseCase with UseCase {
  /// Creates the use case.
  const ForgetRecentSpaceUseCase({
    required this.recents,
    required this.observability,
  });

  /// Where the list is kept.
  final RecentSpacesRepository recents;

  @override
  final Observability observability;

  /// Forgets the space at [root].
  Future<Result<void, AppFailure>> forget(String root) =>
      guard(() => recents.forget(root));
}
