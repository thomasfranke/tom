/// The commits that touched one document.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The history of one file, newest first.
///
/// Scoped to the document, not the repository
/// (`docs/product/git-workflow/file-history/doc.md`). The path is converted
/// here because [SpaceEntity] is the only converter and this is where it is.
final class ReadFileHistoryUseCase with UseCase {
  /// Creates the use case.
  const ReadFileHistoryUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// The commits that changed [path] inside [space], at most [limit] of them.
  Future<Result<List<CommitEntity>, AppFailure>> read(
    SpaceEntity space,
    SpaceRelativePathValueObject path, {
    int? limit,
  }) => guard(
    () => gitFor(space).history(path: space.toRepoRelative(path), limit: limit),
  );
}
