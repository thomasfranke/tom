/// The machine's GitHub logins, through their capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where logins and tokens are asked for, as the text [Credentials]
/// documents, for the repository at [folder].
final class CredentialsDataSource {
  /// Creates a source over [credentials].
  const CredentialsDataSource({
    required this.credentials,
    required this.folder,
  });

  /// What asks `gh`, git and `ssh`.
  final Credentials credentials;

  /// The repository git's credential helper is asked in.
  final String folder;

  /// `gh auth status` for [host].
  Future<Result<String, CredentialsFailure>> ghAccounts(String host) =>
      credentials.ghAccounts(host);

  /// `gh auth token` for [login].
  Future<Result<String, CredentialsFailure>> ghToken(
    String host,
    String login,
  ) => credentials.ghToken(host, login);

  /// `git credential fill` for [host].
  Future<Result<String, CredentialsFailure>> gitCredential(String host) =>
      credentials.gitCredential(host, folder: folder);

  /// `ssh -T git@host`'s greeting.
  Future<Result<String, CredentialsFailure>> sshGreeting(String host) =>
      credentials.sshGreeting(host);
}
