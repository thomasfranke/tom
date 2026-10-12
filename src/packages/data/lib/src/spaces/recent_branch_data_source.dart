/// Asking git which branch a remembered folder is on.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where a recent space's branch comes from: a client made for its folder.
///
/// Apart from `GitDataSource`, which holds the client of a space that is
/// open; one instance for the app.
final class RecentBranchDataSource {
  /// Creates a source making clients with [gitClientFor].
  const RecentBranchDataSource({required this.gitClientFor});

  /// How to get a git client for a folder nobody has opened this run.
  final GitClientFor gitClientFor;

  /// The branch [folder] is on, short, or empty on a detached `HEAD`.
  Future<Result<String, GitClientFailure>> branchOf(String folder) =>
      gitClientFor(folder).currentBranch();
}
