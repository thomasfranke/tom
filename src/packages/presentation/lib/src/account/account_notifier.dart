/// Drives the account button: who commits, which GitHub account, and what
/// it may do here.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/account/account_providers.dart';
import 'package:tom_presentation/src/account/account_state.dart';
import 'package:tom_presentation/src/commands/command_action_enum.dart';
import 'package:tom_presentation/src/commands/command_scope.dart';
import 'package:tom_presentation/src/pull_request/pull_request_providers.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'account_notifier.g.dart';

/// The account of the open space — or the machine's, on Home — read when
/// the space opens or closes, on the git menu's `Reload`, and after a choice
/// (`docs/product/workspace/the-account/doc.md`).
///
/// Kept alive because the button is in the top bar and the popover comes
/// and goes: a reading that died with the popover would be asked for again
/// every time it opened, each time a round of `gh` and `ssh`.
@Riverpod(keepAlive: true)
class AccountNotifier extends _$AccountNotifier {
  /// Reads the summary.
  ReadAccountUseCase get readAccount => ref.read(readAccountProvider);

  /// Records a choice.
  ChooseAccountUseCase get chooseAccount => ref.read(chooseAccountProvider);

  /// Opens the repository's page.
  OpenUrlUseCase get openUrl => ref.read(openUrlProvider);

  /// Which reading is the current one, so an answer about the space just
  /// left cannot land over the next one's.
  int _generation = 0;

  @override
  AccountState build() {
    // The repository, not the space: going from Home to a folder with none
    // is the same machine's account, and is not asked for twice.
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => _repositoryOf(session?.space),
      ),
    );
    // With no space, the machine's: Home carries the button too, and who
    // commits is a question before any repository is open. Scheduled, not
    // awaited: `build` answers synchronously.
    unawaited(Future<void>.microtask(() => _read(space)));
    return const AccountState(isReading: true);
  }

  /// Reads everything again — the git menu's `Reload`.
  Future<void> reload() =>
      _read(_repositoryOf(ref.read(spaceSessionProvider)?.space));

  /// [space] when git can be asked about it; a folder with no repository is
  /// answered as Home is, with the machine's account and no repository
  /// section (`docs/product/workspace/without-a-repository/doc.md`).
  static SpaceEntity? _repositoryOf(SpaceEntity? space) =>
      (space?.hasRepository ?? false) ? space : null;

  /// Uses [account] in this repository from now on, and reads what it may
  /// do here.
  Future<void> choose(GithubAccountValueObject account) async {
    final SpaceEntity? space = _repositoryOf(
      ref.read(spaceSessionProvider)?.space,
    );
    if (space == null || account == state.summary?.chosen) {
      return;
    }
    await CommandScope.run(
      CommandActionEnum.chooseAccount,
      () => chooseAccount.choose(space, account),
    );
    if (ref.mounted) {
      await _read(space);
    }
  }

  /// Opens the repository's page on GitHub in the browser.
  Future<void> openRepository() async {
    final RemoteProjectValueObject? project = state.summary?.project;
    if (project != null) {
      await openUrl.open(project.page);
    }
  }

  /// Reads git's half, then the accounts — one action, so one plan.
  Future<void> _read(SpaceEntity? space) =>
      CommandScope.run(CommandActionEnum.readAccount, () => _readBoth(space));

  Future<void> _readBoth(SpaceEntity? space) async {
    final int generation = ++_generation;
    state = state.copyWith(isReading: true);
    bool isCurrent() =>
        ref.mounted &&
        generation == _generation &&
        _repositoryOf(ref.read(spaceSessionProvider)?.space) == space;

    // Before the first answer, git's half goes up at once: `gh` checks its
    // tokens online, and "no credentials" meanwhile would be a wrong answer.
    AccountSummaryValueObject? local = state.local;
    if (state.summary == null && local == null) {
      local = (await readAccount.readLocal(space)).valueOrNull;
      if (!isCurrent()) {
        return;
      }
      state = state.copyWith(local: local);
    }
    final Result<AccountSummaryValueObject, AppFailure> read = await readAccount
        .read(space, local: state.summary == null ? local : null);
    if (!isCurrent()) {
      return;
    }
    // Refused, the popover keeps what it knew: a no is not "nobody is here".
    if (read case Failure<AccountSummaryValueObject, AppFailure>(
      failure: AppFailure(isDenial: true),
    )) {
      state = state.copyWith(isReading: false);
      return;
    }
    // Only the unexpected fails, and the popover's answer to it is the same
    // as to everything else it cannot know: nothing is known past git's half.
    state = AccountState(
      summary: switch (read) {
        Success<AccountSummaryValueObject, AppFailure>(
          value: final AccountSummaryValueObject summary,
        ) =>
          summary,
        Failure<AccountSummaryValueObject, AppFailure>() => local,
      },
    );
  }
}
