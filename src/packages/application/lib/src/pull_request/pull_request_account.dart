/// Which of the machine's GitHub accounts a pull request is asked as.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The account [git]'s repository is used with on [project] — the one
/// somebody chose, else the first that may push there, else the first
/// (`docs/product/workspace/the-account/doc.md`); null when the machine
/// holds none.
///
/// A question nobody could answer is "none", as before. The one failure is
/// the person refusing a question on the way: that is not "no account", and
/// must not send the caller on to the next thing as if it were.
Future<Result<GithubAccountValueObject?, PullRequestHostFailure>>
pullRequestAccount({
  required GitRepository git,
  required GithubAccountRepository github,
  required RemoteProjectValueObject project,
  AccountChoiceService choice = const AccountChoiceService(),
}) async {
  AppFailure? refused;
  T? heard<T extends Object>(Result<T?, AppFailure> asked) {
    if (asked case Failure<T?, AppFailure>(
      :final AppFailure failure,
    ) when failure.isDenial) {
      refused ??= failure;
    }
    return asked.valueOrNull;
  }

  final List<GithubAccountValueObject> accounts =
      heard(await github.accounts()) ?? const <GithubAccountValueObject>[];
  final GithubAccountValueObject? account = refused != null
      ? null
      : await choice.choose(
          accounts,
          heard(await git.chosenAccount()),
          (GithubAccountValueObject account) async =>
              heard(await github.access(account, project))?.canPush ?? false,
        );
  return switch (refused) {
    final AppFailure cause =>
      Failure<GithubAccountValueObject?, PullRequestHostFailure>(
        PullRequestHostDenied(cause: cause),
      ),
    null => Success<GithubAccountValueObject?, PullRequestHostFailure>(account),
  };
}
