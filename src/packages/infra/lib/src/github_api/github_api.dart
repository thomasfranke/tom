/// GitHub, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/github_api/github_api_failure.dart';

/// What TOM asks of GitHub: what a token may do on a repository, the pull
/// request a branch already has, and opening one.
///
/// Only with a token the machine already held, which is handed to the
/// request and never kept ([Decision
/// 35](../../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
/// Answers cross it verbatim. A [repository] is `owner/name` on the host.
abstract interface class GithubApi {
  /// `GET /repos/{path}` as [token]: the body, JSON verbatim — its
  /// `permissions` object is the token's on that repository.
  Future<Result<String, GithubApiFailure>> repository(
    String path, {
    required String token,
  });

  /// The open pull requests from [head] on [repository], asked from the
  /// clone at [folder]: a JSON array verbatim, each entry carrying
  /// `number`, `url` and `title` — `[]` when there is none.
  Future<Result<String, GithubApiFailure>> openPullRequests(
    String folder, {
    required String repository,
    required String head,
    required String token,
  });

  /// Opens a pull request from [head] onto [base] on [repository], from the
  /// clone at [folder], with [title] and [body]: what was printed, verbatim
  /// and trimmed — the new pull request's address.
  ///
  /// [GithubApiPullRequestExists] when [head] already has one.
  Future<Result<String, GithubApiFailure>> createPullRequest(
    String folder, {
    required String repository,
    required String base,
    required String head,
    required String title,
    required String body,
    required String token,
  });
}
