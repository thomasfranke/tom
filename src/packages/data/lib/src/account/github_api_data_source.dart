/// GitHub's API, through its capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where GitHub is asked, as the JSON [GithubApi] documents.
final class GithubApiDataSource {
  /// Creates a source over [api].
  const GithubApiDataSource({required this.api});

  /// What reaches GitHub.
  final GithubApi api;

  /// `GET /repos/{path}` as [token].
  Future<Result<String, GithubApiFailure>> repository(
    String path, {
    required String token,
  }) => api.repository(path, token: token);

  /// The open pull requests from [head] on [repository], as JSON.
  Future<Result<String, GithubApiFailure>> openPullRequests(
    String folder, {
    required String repository,
    required String head,
    required String token,
  }) => api.openPullRequests(
    folder,
    repository: repository,
    head: head,
    token: token,
  );

  /// Opens one from [head] onto [base]; the address `gh` printed.
  Future<Result<String, GithubApiFailure>> createPullRequest(
    String folder, {
    required String repository,
    required String base,
    required String head,
    required String title,
    required String body,
    required String token,
  }) => api.createPullRequest(
    folder,
    repository: repository,
    base: base,
    head: head,
    title: title,
    body: body,
    token: token,
  );
}
