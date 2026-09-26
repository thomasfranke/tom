/// Recording what is staged.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The index recorded as a commit.
///
/// It commits the index, not a selection: whatever is staged goes in, even
/// outside TOM (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
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

  /// [space]'s index committed with [message].
  ///
  /// A blank message or an empty index is refused by the panel before this,
  /// and by git if it gets here.
  Future<Result<void, AppFailure>> commit(SpaceEntity space, String message) =>
      guard(() => gitFor(space).commit(message));
}
