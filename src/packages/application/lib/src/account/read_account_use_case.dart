/// Reading who the person is, here and on GitHub.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Everything the account popover says about a space's repository, or about
/// the machine on Home (`docs/product/workspace/the-account/doc.md`).
///
/// **Never fails for want of an answer**: an identity git does not have, a
/// tool that holds no login and a GitHub that cannot be reached are each
/// "nothing is known", which the popover says rather than an error.
final class ReadAccountUseCase with UseCase {
  /// Creates the use case.
  const ReadAccountUseCase({
    required this.gitFor,
    required this.accountsFor,
    required this.machineGit,
    required this.machineAccounts,
    required this.observability,
    this.choice = const AccountChoiceService(),
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  /// How to reach the machine's GitHub accounts for a space.
  final GithubAccountRepositoryFor accountsFor;

  /// Git outside any repository — the machine's own identity, for Home.
  final GitRepository machineGit;

  /// The machine's GitHub accounts outside any repository, for Home.
  final GithubAccountRepository machineAccounts;

  /// Which account is used.
  final AccountChoiceService choice;

  @override
  final Observability observability;

  /// What git alone answers for [space]: who commits and the GitHub project,
  /// with no account and no access.
  ///
  /// Git answers at once and `gh` checks its tokens online, so this is what
  /// the popover shows while [read] is still out.
  Future<Result<AccountSummaryValueObject, AppFailure>> readLocal(
    SpaceEntity? space,
  ) => guard<AccountSummaryValueObject, AccountFailure>(() async {
    final _Heard heard = _Heard();
    return heard.answer(await _local(space, heard));
  });

  /// The summary for [space], or for the machine with no space open — which
  /// has no repository, so no project and no access. With [local], git's
  /// half as [readLocal] answered it, which is not asked again.
  ///
  /// The one failure for want of an answer is the person refusing a
  /// question: `AccountDenied`, so what was known before can be kept rather
  /// than replaced by "nothing is known".
  Future<Result<AccountSummaryValueObject, AppFailure>> read(
    SpaceEntity? space, {
    AccountSummaryValueObject? local,
  }) => guard<AccountSummaryValueObject, AccountFailure>(() async {
    final _Heard heard = _Heard();
    final GitRepository git = space == null ? machineGit : gitFor(space);
    final GithubAccountRepository github = space == null
        ? machineAccounts
        : accountsFor(space);
    final AccountSummaryValueObject known = local ?? await _local(space, heard);
    final RemoteProjectValueObject? project = known.project;
    final List<GithubAccountValueObject> accounts =
        heard.of(await github.accounts()) ?? const <GithubAccountValueObject>[];
    // Refused already: nothing more is asked on top of a no.
    if (heard.refused != null) {
      return heard.answer(known);
    }

    // Each account's access is a request, asked once whatever needs it.
    final Map<String, RepositoryAccessValueObject?> asked =
        <String, RepositoryAccessValueObject?>{};
    Future<RepositoryAccessValueObject?> accessOf(
      GithubAccountValueObject account,
    ) async {
      if (project == null) {
        return null;
      }
      if (asked.containsKey(account.login)) {
        return asked[account.login];
      }
      return asked[account.login] = heard.of(
        await github.access(account, project),
      );
    }

    final GithubAccountValueObject? chosen =
        choice.recorded(
          accounts,
          space == null ? null : heard.of(await git.chosenAccount()),
        ) ??
        await choice.fallback(
          accounts,
          (GithubAccountValueObject account) async =>
              (await accessOf(account))?.canPush ?? false,
        );
    return heard.answer(
      known.copyWith(
        accounts: accounts,
        chosen: chosen,
        access: chosen == null ? null : await accessOf(chosen),
      ),
    );
  });

  /// Git's half of the summary: the identity, and `origin` when it is on
  /// GitHub.
  Future<AccountSummaryValueObject> _local(
    SpaceEntity? space,
    _Heard heard,
  ) async {
    final GitRepository git = space == null ? machineGit : gitFor(space);
    final CommitIdentityValueObject identity =
        heard.of(await git.commitIdentity()) ??
        const CommitIdentityValueObject();
    final String? address = space == null
        ? null
        : heard.of(await git.remoteAddress());
    final RemoteProjectValueObject? remote = address == null
        ? null
        : RemoteProjectValueObject.tryParse(address);
    return AccountSummaryValueObject(
      identity: identity,
      project: remote?.host == RemoteHostEnum.github ? remote : null,
    );
  }
}

/// What a reading heard: every answer nobody could give is nothing, and a
/// question the person refused is remembered, because that is not nothing.
final class _Heard {
  /// The first refusal among the answers, or null.
  AppFailure? refused;

  /// What [asked] holds, or null — noting a refusal on the way.
  T? of<T extends Object>(Result<T?, AppFailure> asked) {
    if (asked case Failure<T?, AppFailure>(
      :final AppFailure failure,
    ) when failure.isDenial) {
      refused ??= failure;
    }
    return asked.valueOrNull;
  }

  /// [summary], unless a question on the way to it was refused.
  Result<AccountSummaryValueObject, AccountFailure> answer(
    AccountSummaryValueObject summary,
  ) => switch (refused) {
    final AppFailure cause =>
      Failure<AccountSummaryValueObject, AccountFailure>(
        AccountDenied(cause: cause),
      ),
    null => Success<AccountSummaryValueObject, AccountFailure>(summary),
  };
}
