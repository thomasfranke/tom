/// The token behind one of the machine's GitHub accounts.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/account/credentials_data_source.dart';
import 'package:tom_data/src/account/github_account_parser.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// Asks the tool an account was read from for its token — the one step
/// every GitHub repository here takes before it asks `gh` anything.
///
/// The token never leaves `tom_data`: it goes from here into the `gh` call
/// it is for ([Decision
/// 35](../../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
final class GithubTokenReader {
  /// Creates the reader.
  const GithubTokenReader({
    required this.credentials,
    this.parser = const GithubAccountParser(),
  });

  /// Where tokens come from.
  final CredentialsDataSource credentials;

  /// Reads a credential helper's answer.
  final GithubAccountParser parser;

  /// [account]'s token on [host], or null when its tool holds none — an SSH
  /// key never does.
  ///
  /// A tool that does not answer holds none; the one failure is the person
  /// refusing the question, which is not "no token" and must not read as it.
  Future<Result<String?, CredentialsFailure>> tokenOf(
    GithubAccountValueObject account,
    String host,
  ) async {
    final Result<String?, CredentialsFailure> asked = switch (account.source) {
      AccountSourceEnum.gh => (await credentials.ghToken(
        host,
        account.login,
      )).map((String it) => it.isEmpty ? null : it),
      AccountSourceEnum.git => (await credentials.gitCredential(
        host,
      )).map(parser.credentialToken),
      AccountSourceEnum.ssh => const Success<String?, CredentialsFailure>(null),
    };
    return switch (asked) {
      Failure<String?, CredentialsFailure>(
        failure: CredentialsCommandDenied(),
      ) ||
      Success<String?, CredentialsFailure>() => asked,
      Failure<String?, CredentialsFailure>() =>
        const Success<String?, CredentialsFailure>(null),
    };
  }
}
