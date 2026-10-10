/// What asking GitHub's API can fail with.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'github_api_failure.freezed.dart';

/// GitHub did not answer what was asked.
@freezed
sealed class GithubApiFailure with _$GithubApiFailure implements AppFailure {
  /// What asks GitHub is not on this machine.
  const factory GithubApiFailure.unavailable(
    /// The program that was looked for.
    String program, {
    AppFailure? cause,
  }) = GithubApiUnavailable;

  /// No answer: no network, no name resolution, or a silence past the time
  /// given.
  const factory GithubApiFailure.unreachable(
    /// What was said about the connection. For diagnostics — never parsed.
    String description, {
    AppFailure? cause,
  }) = GithubApiUnreachable;

  /// GitHub refused the token, `401` or `403`.
  const factory GithubApiFailure.refused(
    /// The status it answered.
    int status, {
    AppFailure? cause,
  }) = GithubApiRefused;

  /// Nothing there for this token, `404` — which GitHub also answers for a
  /// private repository the token cannot see.
  const factory GithubApiFailure.notFound({AppFailure? cause}) =
      GithubApiNotFound;

  /// The branch already has an open pull request, at [address].
  const factory GithubApiFailure.pullRequestExists(
    /// The open pull request's page, as GitHub printed it.
    String address, {
    AppFailure? cause,
  }) = GithubApiPullRequestExists;

  /// The request was refused before `gh` started: somebody said no at the
  /// gate. Nothing ran, and nothing is wrong.
  @Implements<CommandDenial>()
  const factory GithubApiFailure.commandDenied(
    /// The command as it would have run.
    String command, {
    AppFailure? cause,
  }) = GithubApiCommandDenied;

  /// Any other answer.
  const factory GithubApiFailure.operationFailed(
    /// What was said on the error stream, and nothing of the body.
    String description, {
    AppFailure? cause,
  }) = GithubApiOperationFailed;
}
