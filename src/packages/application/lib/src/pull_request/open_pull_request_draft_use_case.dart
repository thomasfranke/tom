/// Opening the pull request draft a branch already has, or starting it.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The draft for a branch, read from `.git/tom/pull-request/<branch>.md`
/// and written from git the first time ([Decision
/// 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
///
/// The seed is written here, by the reader, so opening the control twice
/// never seeds twice: the second time there is a file.
final class OpenPullRequestDraftUseCase with UseCase {
  /// Creates the use case.
  const OpenPullRequestDraftUseCase({
    required this.draftsFor,
    required this.gitFor,
    required this.observability,
    this.drafts = const PullRequestDraftService(),
  });

  /// How to reach a space's drafts.
  final DocumentRepositoryFor draftsFor;

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  /// What a draft starts as.
  final PullRequestDraftService drafts;

  @override
  final Observability observability;

  /// Where [branch]'s draft is, relative to the drafts folder: its name's
  /// slashes are folders.
  static SpaceRelativePathValueObject pathFor(BranchNameValueObject branch) =>
      SpaceRelativePathValueObject('${branch.value}.md');

  /// [branch]'s draft, seeded from its commits over [base] when it has none.
  Future<Result<DocumentEntity, AppFailure>> open(
    SpaceEntity space,
    BranchNameValueObject branch,
    BranchNameValueObject base,
  ) => guard<DocumentEntity, AppFailure>(() async {
    final DocumentRepository repository = draftsFor(space);
    final SpaceRelativePathValueObject path = pathFor(branch);
    final Result<DocumentEntity, DocumentFailure> read = await repository.read(
      path,
    );
    if (read case Failure<DocumentEntity, DocumentFailure>(
      failure: DocumentNotFound(),
    )) {
      final Result<List<CommitEntity>, GitFailure> commits = await gitFor(
        space,
      ).commitsSince(base);
      if (commits case Failure<List<CommitEntity>, GitFailure>(
        failure: final GitFailure failure,
      )) {
        return Failure<DocumentEntity, AppFailure>(failure);
      }
      final DocumentEntity seeded = DocumentEntity(
        path: path,
        content: drafts.seed(
          (commits as Success<List<CommitEntity>, GitFailure>).value,
        ),
      );
      return (await repository.create(
        seeded,
      )).map((_) => seeded).mapFailure<AppFailure>((DocumentFailure f) => f);
    }
    return read.mapFailure<AppFailure>((DocumentFailure f) => f);
  });
}
