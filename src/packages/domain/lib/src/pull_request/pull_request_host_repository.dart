/// What the application may ask the host about a branch's pull request.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/account/github_account_value_object.dart';
import 'package:tom_domain/src/git/branch_name_value_object.dart';
import 'package:tom_domain/src/pull_request/opened_pull_request_value_object.dart';
import 'package:tom_domain/src/pull_request/pull_request_host_failure.dart';
import 'package:tom_domain/src/pull_request/remote_project_value_object.dart';

/// The pull requests of one space's repository on its host, asked as one of
/// the machine's accounts ([Decision
/// 35](../../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
///
/// [PullRequestHostUnavailable] whenever there is no way to ask — the page's
/// cue to keep the host's own page as its one action.
abstract interface class PullRequestHostRepository {
  /// The pull request open from [head] on [project], or null when none is.
  Future<Result<OpenedPullRequestValueObject?, PullRequestHostFailure>>
  openFrom(
    GithubAccountValueObject account,
    RemoteProjectValueObject project,
    BranchNameValueObject head,
  );

  /// Opens a pull request from [head] onto [base] on [project] with [title]
  /// and [body] — or answers the one [head] already has.
  Future<Result<OpenedPullRequestValueObject, PullRequestHostFailure>> create(
    GithubAccountValueObject account,
    RemoteProjectValueObject project, {
    required BranchNameValueObject base,
    required BranchNameValueObject head,
    required String title,
    required String body,
  });
}
