/// Which of the machine's GitHub accounts a repository is used with.
library;

import 'package:tom_domain/src/account/github_account_value_object.dart';

/// The rule, in order: the account somebody chose for this repository, then
/// the first that may push there, then the first
/// (`docs/product/workspace/the-account/doc.md`).
final class AccountChoiceService {
  /// Creates the service.
  const AccountChoiceService();

  /// The account [recorded] names, if the machine still holds it — a login
  /// removed from `gh` falls back to the rule rather than to nothing.
  GithubAccountValueObject? recorded(
    List<GithubAccountValueObject> accounts,
    String? recorded,
  ) {
    for (final GithubAccountValueObject account in accounts) {
      if (account.login == recorded) {
        return account;
      }
    }
    return null;
  }

  /// The whole rule: [recorded], else [fallback].
  Future<GithubAccountValueObject?> choose(
    List<GithubAccountValueObject> accounts,
    String? recordedLogin,
    Future<bool> Function(GithubAccountValueObject account) canPush,
  ) async =>
      recorded(accounts, recordedLogin) ?? await fallback(accounts, canPush);

  /// The first of [accounts] [canPush] answers yes for, else the first.
  Future<GithubAccountValueObject?> fallback(
    List<GithubAccountValueObject> accounts,
    Future<bool> Function(GithubAccountValueObject account) canPush,
  ) async {
    // One at a time and stopping at the first: each answer is a request.
    for (final GithubAccountValueObject account in accounts) {
      if (await canPush(account)) {
        return account;
      }
    }
    return accounts.isEmpty ? null : accounts.first;
  }
}
