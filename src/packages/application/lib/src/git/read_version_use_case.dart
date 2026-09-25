/// A document as one commit left it.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// A document's text at a revision, which is what a history entry opens.
///
/// It answers source rather than diff text because the version is rendered
/// like any other document (`docs/product/git-workflow/file-history/doc.md`).
final class ReadVersionUseCase with UseCase {
  /// Creates the use case.
  const ReadVersionUseCase({required this.gitFor, required this.observability});

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// [path] inside [space], as of [revision].
  Future<Result<DocumentEntity, AppFailure>> read(
    SpaceEntity space,
    CommitShaValueObject revision,
    SpaceRelativePathValueObject path,
  ) => guard(() async {
    final Result<String, GitFailure> read = await gitFor(
      space,
    ).contentAt(revision: revision.value, path: space.toRepoRelative(path));
    // A document with the working copy's path, so the version's relative
    // links resolve where the working copy's do.
    return switch (read) {
      Success<String, GitFailure>(value: final String content) =>
        Success<DocumentEntity, GitFailure>(
          DocumentEntity(path: path, content: content),
        ),
      Failure<String, GitFailure>(failure: final GitFailure failure) =>
        Failure<DocumentEntity, GitFailure>(failure),
    };
  });
}
