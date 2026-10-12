/// The domain's account contract, over the machine's tools.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/account/credentials_data_source.dart';
import 'package:tom_data/src/account/github_account_parser.dart';
import 'package:tom_data/src/account/github_api_data_source.dart';
import 'package:tom_data/src/account/github_token_reader.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// [GithubAccountRepository] over [CredentialsDataSource] and
/// [GithubApiDataSource]: the one place a token exists, between the tool
/// that held it and the `gh api` call it is handed to — never above
/// ([Decision 35](../../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
final class GithubAccountRepositoryImpl implements GithubAccountRepository {
  /// Creates the repository.
  const GithubAccountRepositoryImpl({
    required this.credentials,
    required this.api,
    this.parser = const GithubAccountParser(),
  });

  /// Where logins and tokens come from.
  final CredentialsDataSource credentials;

  /// Where GitHub is asked.
  final GithubApiDataSource api;

  /// Reads every tool's answer.
  final GithubAccountParser parser;

  /// The one host there is for now.
  static const String host = 'github.com';

  /// A tool that does not answer holds nothing, so the popover's answer to
  /// "nobody could say" is an empty list. The one failure is the person
  /// refusing a question: that is not "no account", and asking stops there.
  @override
  Future<Result<List<GithubAccountValueObject>, AccountFailure>>
  accounts() async {
    final Map<String, AccountSourceEnum> found = <String, AccountSourceEnum>{};
    final Result<String, CredentialsFailure> asked = await credentials
        .ghAccounts(host);
    if (_refused(asked) case final AccountFailure refused) {
      return Failure<List<GithubAccountValueObject>, AccountFailure>(refused);
    }
    for (final String login in parser.ghLogins(asked.valueOrNull ?? '', host)) {
      found.putIfAbsent(login, () => AccountSourceEnum.gh);
    }
    final Result<String, CredentialsFailure> filled = await credentials
        .gitCredential(host);
    if (_refused(filled) case final AccountFailure refused) {
      return Failure<List<GithubAccountValueObject>, AccountFailure>(refused);
    }
    final String? fill = filled.valueOrNull;
    final String? git = fill == null ? null : parser.credentialLogin(fill);
    if (git != null) {
      found.putIfAbsent(git, () => AccountSourceEnum.git);
    }
    final String? greeting = (await credentials.sshGreeting(host)).valueOrNull;
    final String? ssh = greeting == null ? null : parser.sshLogin(greeting);
    if (ssh != null) {
      found.putIfAbsent(ssh, () => AccountSourceEnum.ssh);
    }
    return Success<List<GithubAccountValueObject>, AccountFailure>(
      List<GithubAccountValueObject>.unmodifiable(<GithubAccountValueObject>[
        for (final MapEntry<String, AccountSourceEnum> it in found.entries)
          GithubAccountValueObject(login: it.key, source: it.value),
      ]),
    );
  }

  @override
  Future<Result<RepositoryAccessValueObject?, AccountFailure>> access(
    GithubAccountValueObject account,
    RemoteProjectValueObject project,
  ) async {
    final Result<String?, CredentialsFailure> held = await GithubTokenReader(
      credentials: credentials,
      parser: parser,
    ).tokenOf(account, host);
    if (_refused(held) case final AccountFailure refused) {
      return Failure<RepositoryAccessValueObject?, AccountFailure>(refused);
    }
    final String? token = held.valueOrNull;
    if (token == null) {
      return const Success<RepositoryAccessValueObject?, AccountFailure>(null);
    }
    return switch (await api.repository(project.path, token: token)) {
      Success<String, GithubApiFailure>(value: final String body) =>
        Success<RepositoryAccessValueObject?, AccountFailure>(
          parser.access(body),
        ),
      // Nothing is known, which is not a failure: without `gh` there is
      // nobody to ask, and GitHub answers 404 for a private repository the
      // token cannot see.
      Failure<String, GithubApiFailure>(
        failure: GithubApiUnavailable() || GithubApiNotFound(),
      ) =>
        const Success<RepositoryAccessValueObject?, AccountFailure>(null),
      Failure<String, GithubApiFailure>(
        failure: final GithubApiFailure failure,
      ) =>
        Failure<RepositoryAccessValueObject?, AccountFailure>(
          _asAccountFailure(failure),
        ),
    };
  }

  /// The refusal in [asked], when the person said no to the question — the
  /// only way a tool's silence is not simply "it holds nothing".
  static AccountFailure? _refused<T>(Result<T, CredentialsFailure> asked) =>
      switch (asked) {
        Failure<T, CredentialsFailure>(
          failure: final CredentialsCommandDenied failure,
        ) =>
          AccountDenied(cause: failure),
        _ => null,
      };

  static AccountFailure _asAccountFailure(GithubApiFailure failure) =>
      switch (failure) {
        GithubApiUnreachable() => AccountUnreachable(cause: failure),
        GithubApiRefused() => AccountRefused(cause: failure),
        GithubApiCommandDenied() => AccountDenied(cause: failure),
        GithubApiUnavailable() ||
        GithubApiNotFound() ||
        GithubApiPullRequestExists() ||
        GithubApiOperationFailed() => AccountOperationFailed(cause: failure),
      };
}
