/// Bringing the remote's commits into this branch.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Merges what the tracked remote has into the current branch.
///
/// The one action here that **does** change files on disk, which is why it
/// is never the thing a button does by accident
/// (`docs/product/git-workflow/push-pull/doc.md`).
///
/// `GitMergeConflict` is not an error to report but a state to resolve: both
/// sides changed the same lines, and the product asks rather than picking.
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
