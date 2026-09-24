/// Recording what is staged.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Records the index as a commit.
///
/// **It commits the index, not a selection.** Whatever is staged goes in,
/// including anything staged outside TOM — which is why the panel lists what
/// the *repository* reports rather than only what the space holds
/// (`docs/product/git-workflow/commit/doc.md`).
final class CommitChangesUseCase with UseCase {
  /// Creates the use case.
  const CommitChangesUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Commits [space]'s index with [message].
  ///
  /// A message that is blank, or an index with nothing in it, is refused
  /// before this — the button is disabled — and by git if it ever gets here.
  Future<Result<void, AppFailure>> commit(SpaceEntity space, String message) =>
      guard(() => gitFor(space).commit(message));
}
