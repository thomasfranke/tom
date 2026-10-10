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

  /// Brings [space]'s remote commits into the current branch, answering how
  /// many arrived — 0 when it was already level
  /// (`docs/product/git-workflow/push-pull/when-it-works/doc.md`).
  ///
  /// The count is read around the pull, each reading guarded on its own: a
  /// count git cannot give is null, never a failure, because the pull has
  /// already landed on disk and saying it failed would be the lie.
  Future<Result<int?, AppFailure>> pull(SpaceEntity space) => guard(() async {
    final GitRepository git = gitFor(space);
    final Result<CommitShaValueObject?, AppFailure> before = await guard(
      git.head,
    );
    final Result<void, GitFailure> pulled = await git.pull();
    if (pulled case Failure<void, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<int?, AppFailure>(failure);
    }
    if (before case Success<CommitShaValueObject?, AppFailure>(
      value: final CommitShaValueObject? since,
    )) {
      final Result<int, AppFailure> arrived = await guard(
        () => git.upstreamCommitsSince(since),
      );
      if (arrived case Success<int, AppFailure>(value: final int count)) {
        return Success<int?, AppFailure>(count);
      }
    }
    return const Success<int?, AppFailure>(null);
  });
}
