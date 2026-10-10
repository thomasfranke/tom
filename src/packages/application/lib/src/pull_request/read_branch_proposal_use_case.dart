/// Reading what a pull request onto a base would carry.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The branch's commits over a base and the paths they changed — the
/// `Pull request` segment's reading.
final class ReadBranchProposalUseCase with UseCase {
  /// Creates the use case.
  const ReadBranchProposalUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// What `HEAD` proposes onto [base].
  Future<Result<BranchProposalValueObject, AppFailure>> read(
    SpaceEntity space,
    BranchNameValueObject base,
  ) => guard<BranchProposalValueObject, GitFailure>(() async {
    final GitRepository git = gitFor(space);
    final Result<List<CommitEntity>, GitFailure> commits = await git
        .commitsSince(base);
    if (commits case Failure<List<CommitEntity>, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<BranchProposalValueObject, GitFailure>(failure);
    }
    return (await git.changesSince(base)).map(
      // Handed over unmodifiable: the proposal is a value, read by the page.
      (List<BranchChangeValueObject> changes) => BranchProposalValueObject(
        commits: List<CommitEntity>.unmodifiable(
          (commits as Success<List<CommitEntity>, GitFailure>).value,
        ),
        changes: List<BranchChangeValueObject>.unmodifiable(changes),
      ),
    );
  });
}
