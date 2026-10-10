/// Putting one file of the changes list back.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The ↶ at the end of a row of the changes list, once its confirmation was
/// answered (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
///
/// How far back the file goes is [DiscardKindEnum.of]'s; a conflicted file
/// is refused here as well as never offered, since resolving it is the way
/// out.
final class DiscardChangeUseCase with UseCase {
  /// Creates the use case.
  const DiscardChangeUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Discards [entry] in [space]'s repository, a rename's old name with it.
  Future<Result<void, AppFailure>> discard(
    SpaceEntity space,
    StatusEntryValueObject entry,
  ) => guard(() async {
    final DiscardKindEnum? kind = DiscardKindEnum.of(entry);
    if (kind == null) {
      return Failure<void, GitFailure>(
        GitFailure.mergeConflict(<String>[entry.path.value]),
      );
    }
    return gitFor(space).discard(kind, <RepoRelativePathValueObject>[
      entry.path,
      ?entry.previousPath,
    ]);
  });
}
