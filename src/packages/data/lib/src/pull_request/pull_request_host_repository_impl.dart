/// The domain's pull request host contract, over `gh`.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/account/github_api_data_source.dart';
import 'package:tom_data/src/account/github_token_reader.dart';
import 'package:tom_data/src/pull_request/github_pull_request_parser.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// [PullRequestHostRepository] for the clone at [folder], through `gh` with
/// the account's own token ([Decision
/// 35](../../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
///
/// GitHub only: any other host is [PullRequestHostUnavailable], and so is an
/// account whose tool holds no token.
final class PullRequestHostRepositoryImpl implements PullRequestHostRepository {
  /// Creates the repository.
  const PullRequestHostRepositoryImpl({
    required this.tokens,
    required this.api,
    required this.folder,
    this.parser = const GithubPullRequestParser(),
  });

  /// Where an account's token comes from.
  final GithubTokenReader tokens;

  /// Where GitHub is asked.
  final GithubApiDataSource api;

  /// The repository's root, where `gh` runs.
  final String folder;

  /// Reads what `gh` answers.
  final GithubPullRequestParser parser;

  @override
  Future<Result<OpenedPullRequestValueObject?, PullRequestHostFailure>>
  openFrom(
    GithubAccountValueObject account,
    RemoteProjectValueObject project,
    BranchNameValueObject head,
  ) async {
    final Result<String, PullRequestHostFailure> held = await _tokenFor(
      account,
      project,
    );
    if (held case Failure<String, PullRequestHostFailure>(
      failure: final PullRequestHostFailure failure,
    )) {
      return Failure<OpenedPullRequestValueObject?, PullRequestHostFailure>(
        failure,
      );
    }
    final String token =
        (held as Success<String, PullRequestHostFailure>).value;
    return switch (await api.openPullRequests(
      folder,
      repository: project.path,
      head: head.value,
      token: token,
    )) {
      Success<String, GithubApiFailure>(value: final String json) =>
        Success<OpenedPullRequestValueObject?, PullRequestHostFailure>(
          parser.openPullRequests(json).firstOrNull,
        ),
      Failure<String, GithubApiFailure>(
        failure: final GithubApiFailure failure,
      ) =>
        Failure<OpenedPullRequestValueObject?, PullRequestHostFailure>(
          _asHostFailure(failure),
        ),
    };
  }

  @override
  Future<Result<OpenedPullRequestValueObject, PullRequestHostFailure>> create(
    GithubAccountValueObject account,
    RemoteProjectValueObject project, {
    required BranchNameValueObject base,
    required BranchNameValueObject head,
    required String title,
    required String body,
  }) async {
    final Result<String, PullRequestHostFailure> held = await _tokenFor(
      account,
      project,
    );
    if (held case Failure<String, PullRequestHostFailure>(
      failure: final PullRequestHostFailure failure,
    )) {
      return Failure<OpenedPullRequestValueObject, PullRequestHostFailure>(
        failure,
      );
    }
    final String token =
        (held as Success<String, PullRequestHostFailure>).value;
    final Result<String, GithubApiFailure> created = await api
        .createPullRequest(
          folder,
          repository: project.path,
          base: base.value,
          head: head.value,
          title: title,
          body: body,
          token: token,
        );
    final String? address = switch (created) {
      Success<String, GithubApiFailure>(value: final String printed) => printed,
      // One already open is the answer to "open one", not a refusal.
      Failure<String, GithubApiFailure>(
        failure: GithubApiPullRequestExists(:final String address),
      ) =>
        address,
      Failure<String, GithubApiFailure>() => null,
    };
    final OpenedPullRequestValueObject? opened = address == null
        ? null
        : parser.created(address, title);
    if (opened != null) {
      return Success<OpenedPullRequestValueObject, PullRequestHostFailure>(
        opened,
      );
    }
    return Failure<OpenedPullRequestValueObject, PullRequestHostFailure>(
      switch (created) {
        Failure<String, GithubApiFailure>(
          failure: final GithubApiFailure failure,
        ) =>
          _asHostFailure(failure),
        // `gh` said it worked and printed no address it could be found at.
        Success<String, GithubApiFailure>() =>
          const PullRequestHostOperationFailed(),
      },
    );
  }

  /// [account]'s token: there is no way to ask when [project] is not on
  /// GitHub or the account's tool holds none, and the person refusing the
  /// question is a refusal, not "no token".
  Future<Result<String, PullRequestHostFailure>> _tokenFor(
    GithubAccountValueObject account,
    RemoteProjectValueObject project,
  ) async {
    if (project.host != RemoteHostEnum.github) {
      return const Failure<String, PullRequestHostFailure>(
        PullRequestHostUnavailable(),
      );
    }
    return switch (await tokens.tokenOf(account, project.host.domain)) {
      Success<String?, CredentialsFailure>(value: final String token) =>
        Success<String, PullRequestHostFailure>(token),
      Success<String?, CredentialsFailure>() =>
        const Failure<String, PullRequestHostFailure>(
          PullRequestHostUnavailable(),
        ),
      Failure<String?, CredentialsFailure>(
        failure: final CredentialsFailure failure,
      ) =>
        Failure<String, PullRequestHostFailure>(
          PullRequestHostDenied(cause: failure),
        ),
    };
  }

  static PullRequestHostFailure _asHostFailure(GithubApiFailure failure) =>
      switch (failure) {
        GithubApiUnavailable() => PullRequestHostUnavailable(cause: failure),
        GithubApiUnreachable() => PullRequestHostUnreachable(cause: failure),
        GithubApiRefused() => PullRequestHostRefused(cause: failure),
        GithubApiCommandDenied() => PullRequestHostDenied(cause: failure),
        GithubApiNotFound() ||
        GithubApiPullRequestExists() ||
        GithubApiOperationFailed() => PullRequestHostOperationFailed(
          cause: failure,
        ),
      };
}
