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
  ///
  /// **A branch that tracks nothing is published to `origin` and tracked
  /// from then on**, read from the status first: a plain push of a new
  /// branch is refused by a default git, and somebody who made the branch
  /// here has no terminal to set its upstream from.
  Future<Result<void, AppFailure>> push(SpaceEntity space) => guard(() async {
    final GitRepository git = gitFor(space);
    final Result<GitStatusValueObject, GitFailure> reading = await git.status();
    return switch (reading) {
      Failure<GitStatusValueObject, GitFailure>(
        failure: final GitFailure failure,
      ) =>
        Failure<void, GitFailure>(failure),
      Success<GitStatusValueObject, GitFailure>(
        value: GitStatusValueObject(
          upstream: null,
          branch: final BranchNameValueObject branch,
        ),
      ) =>
        await git.publish(branch),
      // Tracked, or detached — which a plain push refuses in git's words.
      Success<GitStatusValueObject, GitFailure>() => await git.push(),
    };
  });
}
