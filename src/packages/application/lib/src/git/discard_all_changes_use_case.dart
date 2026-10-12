/// Going back to the last commit.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// `Discard all changes`, from the git column's menu, after a confirmation
/// that names how many documents go back
/// (`docs/product/git-workflow/git-menu/doc.md`).
///
/// What git never committed is not this action's to lose: an untracked file
/// is untouched, and an added one is kept as untracked.
final class DiscardAllChangesUseCase with UseCase {
  /// Creates the use case.
  const DiscardAllChangesUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Puts every tracked file of [space]'s repository back as `HEAD` has it.
  ///
  /// **Refused in two states, here and not only by the menu that hides it**,
  /// because the list a menu was drawn from can be stale and git itself
  /// refuses neither. Mid-merge it would end the merge and write over the
  /// conflicted files — `GitMergeConflict`, since `Abort the pull` is the
  /// way back. Before the first commit it would unstage everything and then
  /// fail — `GitNoCommitsYet`.
  Future<Result<void, AppFailure>> discard(SpaceEntity space) => guard(
    () async {
      final GitRepository git = gitFor(space);
      switch (await git.mergeState()) {
        case Failure<MergeStateValueObject, GitFailure>(
          failure: final GitFailure failure,
        ):
          return Failure<void, GitFailure>(failure);
        case Success<MergeStateValueObject, GitFailure>(
          value: MergeStateValueObject(inProgress: true),
        ):
          return const Failure<void, GitFailure>(GitMergeConflict(<String>[]));
        case Success<MergeStateValueObject, GitFailure>():
      }
      switch (await git.head()) {
        case Failure<CommitShaValueObject?, GitFailure>(
          failure: final GitFailure failure,
        ):
          return Failure<void, GitFailure>(failure);
        case Success<CommitShaValueObject?, GitFailure>(value: null):
          return const Failure<void, GitFailure>(GitNoCommitsYet());
        case Success<CommitShaValueObject?, GitFailure>():
      }
      return git.discardAll();
    },
  );
}
