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
  Future<Result<void, AppFailure>> discard(SpaceEntity space) =>
      guard(() => gitFor(space).discardAll());
}
