/// Reading where a pull request would go.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The remote's project, if its host is one the app knows, the branch the
/// remote calls its own, and the branch the repository is on.
final class ReadPullRequestTargetUseCase with UseCase {
  /// Creates the use case.
  const ReadPullRequestTargetUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Where a pull request from [space]'s repository would be opened.
  Future<Result<PullRequestTargetValueObject, AppFailure>> read(
    SpaceEntity space,
  ) => guard<PullRequestTargetValueObject, GitFailure>(() async {
    final GitRepository git = gitFor(space);
    final Result<String?, GitFailure> address = await git.remoteAddress();
    if (address case Failure<String?, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<PullRequestTargetValueObject, GitFailure>(failure);
    }
    final String? url = (address as Success<String?, GitFailure>).value;
    final Result<GitStatusValueObject, GitFailure> status = await git.status();
    if (status case Failure<GitStatusValueObject, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<PullRequestTargetValueObject, GitFailure>(failure);
    }
    final GitStatusValueObject here =
        (status as Success<GitStatusValueObject, GitFailure>).value;
    return (await git.defaultBranch()).map(
      (BranchNameValueObject? base) => PullRequestTargetValueObject(
        project: url == null ? null : RemoteProjectValueObject.tryParse(url),
        defaultBranch: base,
        hasRemote: url != null,
        branch: here.isDetached ? null : here.branch,
        isDetached: here.isDetached,
      ),
    );
  });
}
