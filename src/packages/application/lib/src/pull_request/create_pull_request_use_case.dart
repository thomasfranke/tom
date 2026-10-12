/// Opening the pull request on the host, without the browser.
library;

import 'package:tom_application/src/pull_request/pull_request_account.dart';
import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Opens the branch's pull request through `gh`, as the repository's own
/// account, with the draft's title and body
/// (`docs/product/git-workflow/pull-request/opening-it/doc.md`).
///
/// **The draft is never deleted**: it stays what the pull request was
/// opened with ([Decision
/// 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
final class CreatePullRequestUseCase with UseCase {
  /// Creates the use case.
  const CreatePullRequestUseCase({
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

  /// Proposes [head] onto [base] on [project] with [title] and [body], and
  /// answers the pull request as the host then lists it.
  Future<Result<OpenedPullRequestValueObject, AppFailure>> create(
    SpaceEntity space,
    RemoteProjectValueObject project, {
    required BranchNameValueObject base,
    required BranchNameValueObject head,
    required String title,
    required String body,
  }) => guard<OpenedPullRequestValueObject, PullRequestHostFailure>(() async {
    final Result<GithubAccountValueObject?, PullRequestHostFailure> asked =
        await pullRequestAccount(
          git: gitFor(space),
          github: accountsFor(space),
          project: project,
        );
    if (asked case Failure<GithubAccountValueObject?, PullRequestHostFailure>(
      :final PullRequestHostFailure failure,
    )) {
      return Failure<OpenedPullRequestValueObject, PullRequestHostFailure>(
        failure,
      );
    }
    final GithubAccountValueObject? account = asked.valueOrNull;
    if (account == null) {
      return const Failure<
        OpenedPullRequestValueObject,
        PullRequestHostFailure
      >(PullRequestHostUnavailable());
    }
    final PullRequestHostRepository host = hostFor(space);
    final Result<OpenedPullRequestValueObject, PullRequestHostFailure> created =
        await host.create(
          account,
          project,
          base: base,
          head: head,
          title: title,
          body: body,
        );
    if (created
        case Success<OpenedPullRequestValueObject, PullRequestHostFailure>(
          value: final OpenedPullRequestValueObject opened,
        )) {
      // Asked again, so the page shows what the host holds — an answer
      // that does not come back still leaves the one just created.
      final OpenedPullRequestValueObject? listed = (await host.openFrom(
        account,
        project,
        head,
      )).valueOrNull;
      return Success<OpenedPullRequestValueObject, PullRequestHostFailure>(
        listed ?? opened,
      );
    }
    return created;
  });
}
