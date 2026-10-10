/// The GitHub logins this machine already holds, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/credentials/credentials_failure.dart';

/// Asks `gh`, git's credential helper and `ssh` who the person is on a host
/// — **asks, never stores, never prompts** ([Decision
/// 35](../../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
///
/// Text crosses it, as git's does: each method states the format it returns.
/// A program that is not installed, or that holds nothing for the host, is
/// an empty answer rather than a failure.
abstract interface class Credentials {
  /// Every account `gh` holds for [host].
  ///
  /// `gh auth status --hostname host --json hosts` verbatim; from a `gh` too
  /// old for `--json`, its text report with both streams joined. Empty when
  /// `gh` is not installed.
  Future<Result<String, CredentialsFailure>> ghAccounts(String host);

  /// The token `gh` holds for [login] on [host], trimmed, or empty when it
  /// holds none.
  Future<Result<String, CredentialsFailure>> ghToken(String host, String login);

  /// What `git credential fill` answers for `https://host`, run in [folder]
  /// so a repository's own helper is asked too: `key=value` lines verbatim,
  /// or empty when no helper has one.
  Future<Result<String, CredentialsFailure>> gitCredential(
    String host, {
    required String folder,
  });

  /// What `ssh -T git@host` wrote on its error stream, verbatim — GitHub's
  /// greeting names the login — or empty when `ssh` is not installed.
  ///
  /// Batch mode: a key behind a passphrase, or a host not yet known, is a
  /// refusal and never a question.
  Future<Result<String, CredentialsFailure>> sshGreeting(String host);
}
