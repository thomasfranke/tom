/// Bringing the remote's commits into this branch.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The tracked remote's commits merged into the current branch.
///
/// The one remote action that changes files on disk, so it is never a
/// button's accident
/// (`docs/product/git-workflow/push-pull/the-controls/doc.md`); a
/// `GitMergeConflict` is a state to resolve, not an error to report.
final class PullRemoteUseCase with UseCase {
  /// Creates the use case.
  const PullRemoteUseCase({required this.gitFor, required this.observability});

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Brings [space]'s remote commits into the current branch.
  Future<Result<void, AppFailure>> pull(SpaceEntity space) =>
      guard(() => gitFor(space).pull());
}
