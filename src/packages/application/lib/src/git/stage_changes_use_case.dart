/// Putting changes into the index, and taking them back out.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Whole files moved in and out of the index; there is no hunk-level staging
/// (`docs/product/git-workflow/commit/doc.md`).
///
/// Both directions in one use case because a row's checkbox is one control.
final class StageChangesUseCase with UseCase {
  /// Creates the use case.
  const StageChangesUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// [paths] added to [space]'s index; an empty list succeeds and does nothing.
  Future<Result<void, AppFailure>> stage(
    SpaceEntity space,
    List<RepoRelativePathValueObject> paths,
  ) => guard(() => gitFor(space).stage(paths));

  /// [paths] taken back out of the index, the working tree left alone.
  Future<Result<void, AppFailure>> unstage(
    SpaceEntity space,
    List<RepoRelativePathValueObject> paths,
  ) => guard(() => gitFor(space).unstage(paths));
}
