/// Putting changes into the index, and taking them back out.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Moves whole files in and out of the index.
///
/// Both directions in one use case because they are one decision made twice:
/// a row's checkbox stages or unstages the same path, and splitting them
/// would put the same wiring in two files.
///
/// **Whole files only** — there is no hunk-level staging
/// (`docs/product/git-workflow/commit/doc.md`).
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

  /// Adds [paths] to [space]'s index.
  ///
  /// An empty list succeeds and does nothing: "stage the selection" with
  /// nothing selected is not an error.
  Future<Result<void, AppFailure>> stage(
    SpaceEntity space,
    List<RepoRelativePathValueObject> paths,
  ) => guard(() => gitFor(space).stage(paths));

  /// Takes [paths] back out, leaving the working tree alone.
  Future<Result<void, AppFailure>> unstage(
    SpaceEntity space,
    List<RepoRelativePathValueObject> paths,
  ) => guard(() => gitFor(space).unstage(paths));
}
