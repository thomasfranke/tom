/// A document as one commit left it.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Reads a document's text at a revision.
///
/// What a history entry opens: the version is **rendered like any other
/// document**, not shown as diff text
/// (`docs/product/git-workflow/file-history/doc.md`), so what comes back
/// here is source and the splitting is the preview's as usual.
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
    // A document, because that is what the preview splits — and it carries
    // the path so the version's own relative links resolve where the
    // working copy's do.
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
