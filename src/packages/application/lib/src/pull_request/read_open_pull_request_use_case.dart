/// Asking the host whether the branch already has a pull request.
library;

import 'package:tom_application/src/pull_request/pull_request_account.dart';
import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The pull request open from a branch, as the repository's own account
/// (`docs/product/git-workflow/pull-request/opening-it/doc.md`).
///
/// [PullRequestHostUnavailable] when there is no way to ask — no account,
/// no token, no `gh` — which the page answers with the host's own page.
final class ReadOpenPullRequestUseCase with UseCase {
  /// Creates the use case.
  const ReadOpenPullRequestUseCase({
    required this.gitFor,
    required this.accountsFor,
    required this.hostFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  /// How to reach the machine's GitHub accounts for a space.
  final GithubAccountRepositoryFor accountsFor;

  /// How to reach the host's pull requests for a space.
  final PullRequestHostRepositoryFor hostFor;

  @override
  final Observability observability;

  /// The pull request open from [head] on [project], or null when none is.
  Future<Result<OpenedPullRequestValueObject?, AppFailure>> read(
    SpaceEntity space,
    RemoteProjectValueObject project,
    BranchNameValueObject head,
  ) => guard<OpenedPullRequestValueObject?, PullRequestHostFailure>(() async {
    final Result<GithubAccountValueObject?, PullRequestHostFailure> asked =
        await pullRequestAccount(
          git: gitFor(space),
          github: accountsFor(space),
          project: project,
        );
    if (asked case Failure<GithubAccountValueObject?, PullRequestHostFailure>(
      :final PullRequestHostFailure failure,
    )) {
      return Failure<OpenedPullRequestValueObject?, PullRequestHostFailure>(
        failure,
      );
    }
    final GithubAccountValueObject? account = asked.valueOrNull;
    if (account == null) {
      return const Failure<
        OpenedPullRequestValueObject?,
        PullRequestHostFailure
      >(PullRequestHostUnavailable());
    }
    return hostFor(space).openFrom(account, project, head);
  });
}
