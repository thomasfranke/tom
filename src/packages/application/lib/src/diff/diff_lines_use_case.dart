/// What a file that is not markdown changed, line by line.
library;

import 'package:tom_application/src/diff/diff_document_use_case.dart';
import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The comparison of a text buffer against a revision of its file — the
/// line twin of `DiffDocumentUseCase`, for a file with no page to render
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
final class DiffLinesUseCase with UseCase {
  /// Creates the use case.
  const DiffLinesUseCase({
    required this.gitFor,
    required this.differ,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  /// What lines one version up against the other.
  final LineDifferService differ;

  @override
  final Observability observability;

  /// What [after] changed against [revision], `HEAD` unless told.
  ///
  /// A file the revision does not hold is every line added, not a failure.
  Future<Result<LineDiffValueObject, AppFailure>> diff({
    required SpaceEntity space,
    required DocumentEntity after,
    String revision = DiffDocumentUseCase.head,
  }) => guard<LineDiffValueObject, AppFailure>(() async {
    final Result<String, GitFailure> committed = await gitFor(
      space,
    ).contentAt(revision: revision, path: space.toRepoRelative(after.path));
    final String before;
    switch (committed) {
      case Success<String, GitFailure>(value: final String content):
        before = content;
      case Failure<String, GitFailure>(failure: GitPathNotInRevision()):
        before = '';
      case Failure<String, GitFailure>(failure: final GitFailure failure):
        return Failure<LineDiffValueObject, GitFailure>(failure);
    }
    return differ.diff(
      before: DocumentEntity(path: after.path, content: before),
      after: after,
    );
  });
}
