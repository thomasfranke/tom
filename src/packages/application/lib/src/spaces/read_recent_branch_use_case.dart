/// Reading the branch a remembered space was left on.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The branch on a recent space's row
/// (`docs/product/home/recent-spaces/doc.md`) — coming back to the wrong
/// branch is the surprise Home can prevent.
final class ReadRecentBranchUseCase with UseCase {
  /// Creates the use case.
  const ReadRecentBranchUseCase({
    required this.branches,
    required this.observability,
  });

  /// Where the branch is read.
  final RecentBranchRepository branches;

  @override
  final Observability observability;

  /// The branch [recent] is on, or null when it is on none.
  Future<Result<BranchNameValueObject?, AppFailure>> read(
    RecentSpaceEntity recent,
  ) => guard(() => branches.branchOf(recent));
}
