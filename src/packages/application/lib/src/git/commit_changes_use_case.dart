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
  ///
  /// **A detached `HEAD` is refused here**, because git would commit onto no
  /// branch and the commit would be reachable from nothing the moment `HEAD`
  /// moved — which is the one thing this product promises never happens.
  Future<Result<void, AppFailure>> commit(SpaceEntity space, String message) =>
      guard(() async {
        final GitRepository git = gitFor(space);
        final Result<GitStatusValueObject, GitFailure> reading = await git
            .status();

        switch (reading) {
          case Failure<GitStatusValueObject, GitFailure>(
            failure: final GitFailure failure,
          ):
            return Failure<void, GitFailure>(failure);
          case Success<GitStatusValueObject, GitFailure>(
            value: final GitStatusValueObject status,
          ):
            if (status.isDetached) {
              return const Failure<void, GitFailure>(GitDetachedHead());
            }
        }
        return git.commit(message);
      });
}
