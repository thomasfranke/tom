/// Dropping one space from the list Home offers.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// One space dropped from the list Home offers.
///
/// Forgetting does not touch the folder; the space can be picked again.
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
