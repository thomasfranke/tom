/// The commits that touched one document.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Reads the history of one file, newest first.
///
/// **Scoped to the document, not the repository**
/// (`docs/product/git-workflow/file-history/doc.md`): the question the panel
/// answers is "who changed *this*", and a repository-wide log is a different
/// and much longer answer.
///
/// The path is converted here because that is where the [SpaceEntity] is:
/// the app navigates in space-relative paths and git speaks
/// repository-relative ones, and [SpaceEntity] is the only converter.
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

  /// The commits that changed [path] inside [space].
  ///
  /// [limit] caps how many come back; a document with a thousand commits is
  /// a list nobody scrolls, and the panel asks for what it can draw.
  Future<Result<List<CommitEntity>, AppFailure>> read(
    SpaceEntity space,
    SpaceRelativePathValueObject path, {
    int? limit,
  }) => guard(
    () => gitFor(space).history(path: space.toRepoRelative(path), limit: limit),
  );
}
