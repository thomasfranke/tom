/// Asking git whether a merge is still in progress.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Whether the repository is sitting mid-merge, and what git drafted for it.
///
/// Read rather than remembered, because the state belongs to the repository
/// and not to the session: closing the window and opening it again has to
/// find the same conflict, with the same sentence explaining the `C` marks
/// (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
final class ReadMergeStateUseCase with UseCase {
  /// Creates the use case.
  const ReadMergeStateUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// The merge [space] is in the middle of, or one that is not in progress.
  Future<Result<MergeStateValueObject, AppFailure>> read(SpaceEntity space) =>
      guard(() => gitFor(space).mergeState());
}
