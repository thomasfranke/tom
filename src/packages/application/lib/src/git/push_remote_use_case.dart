/// Publishing this branch's commits.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The current branch's commits sent to its remote.
///
/// `GitPushRejected` is a named failure because somebody has to act on it:
/// the remedy is a pull
/// (`docs/product/git-workflow/push-pull/when-it-fails/doc.md`).
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
