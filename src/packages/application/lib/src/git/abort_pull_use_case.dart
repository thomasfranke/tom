/// Undoing a pull that stopped in the middle.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Puts the working tree back where the conflicted pull found it.
///
/// The band's one action, and it goes through a confirmation that says what
/// it undoes — the commits already made survive, because aborting undoes the
/// merge and never the work
/// (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
final class AbortPullUseCase with UseCase {
  /// Creates the use case.
  const AbortPullUseCase({required this.gitFor, required this.observability});

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Aborts the merge [space] is in the middle of.
  ///
  /// Refused by git when there is none, which the caller avoids by reading
  /// the state first rather than by treating the refusal as an answer.
  Future<Result<void, AppFailure>> abort(SpaceEntity space) =>
      guard(() => gitFor(space).abortMerge());
}
