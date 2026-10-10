/// The branch on each recent row, read from git.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/spaces/recent_branch_data_source.dart';
import 'package:tom_domain/tom_domain.dart';
// For the failure vocabulary only (Decision 25).
import 'package:tom_infra/tom_infra.dart';

/// [RecentBranchRepository] over [RecentBranchDataSource].
///
/// A folder that is gone or no longer a repository is an answer — the row
/// shows no branch; anything else git says is recorded, never raised.
final class RecentBranchRepositoryImpl implements RecentBranchRepository {
  /// Creates a repository over [branches].
  const RecentBranchRepositoryImpl({
    required this.branches,
    required this.observability,
  });

  /// Where the branch is read.
  final RecentBranchDataSource branches;

  /// Where a failure nobody handles is recorded.
  final Observability observability;

  @override
  Future<Result<BranchNameValueObject?, Never>> branchOf(
    RecentSpaceEntity recent,
  ) async {
    final Result<String, GitClientFailure> read = await branches.branchOf(
      recent.root,
    );
    switch (read) {
      case Success<String, GitClientFailure>(:final String value):
        return Success<BranchNameValueObject?, Never>(
          BranchNameValueObject.tryParse(value),
        );
      // Neither is worth recording: one is a folder that changed, the other
      // the person saying no to the question.
      case Failure<String, GitClientFailure>(
        failure: GitClientNotARepository() || GitClientCommandDenied(),
      ):
        break;
      case Failure<String, GitClientFailure>(:final GitClientFailure failure):
        await observability.capture(failure, StackTrace.current, layer: 'data');
    }
    return const Success<BranchNameValueObject?, Never>(null);
  }
}
