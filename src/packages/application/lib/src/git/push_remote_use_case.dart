/// Publishing this branch's commits.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Sends the current branch's commits to its remote.
///
/// `GitPushRejected` is the one outcome the product shows as its own — the
/// remote moved first, nothing local was lost, and the remedy is a pull
/// (`docs/product/git-workflow/push-pull/doc.md`). It is a named failure
/// rather than a silent no-op precisely because somebody has to act on it.
final class PushRemoteUseCase with UseCase {
  /// Creates the use case.
  const PushRemoteUseCase({required this.gitFor, required this.observability});

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Publishes [space]'s current branch.
  Future<Result<void, AppFailure>> push(SpaceEntity space) =>
      guard(() => gitFor(space).push());
}
