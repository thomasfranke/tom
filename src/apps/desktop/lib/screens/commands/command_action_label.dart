/// What an action is called in the commands panel.
library;

import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// The words for a [CommandActionEnum], which presentation only names.
extension CommandActionLabel on CommandActionEnum {
  /// This action, in the window's language.
  String label(AppLocalizations l10n) => switch (this) {
    CommandActionEnum.openSpace => l10n.commandAction_openSpace,
    CommandActionEnum.cloneRepository => l10n.commandAction_cloneRepository,
    CommandActionEnum.readRecentBranch => l10n.commandAction_readRecentBranch,
    CommandActionEnum.readRepository => l10n.commandAction_readRepository,
    CommandActionEnum.readBranches => l10n.commandAction_readBranches,
    CommandActionEnum.readDiffBase => l10n.commandAction_readDiffBase,
    CommandActionEnum.readHistory => l10n.commandAction_readHistory,
    CommandActionEnum.readVersion => l10n.commandAction_readVersion,
    CommandActionEnum.stage => l10n.commandAction_stage,
    CommandActionEnum.unstage => l10n.commandAction_unstage,
    CommandActionEnum.commit => l10n.commandAction_commit,
    CommandActionEnum.discard => l10n.commandAction_discard,
    CommandActionEnum.discardAll => l10n.commandAction_discardAll,
    CommandActionEnum.fetch => l10n.commandAction_fetch,
    CommandActionEnum.pull => l10n.commandAction_pull,
    CommandActionEnum.push => l10n.commandAction_push,
    CommandActionEnum.abortPull => l10n.commandAction_abortPull,
    CommandActionEnum.switchBranch => l10n.commandAction_switchBranch,
    CommandActionEnum.createBranch => l10n.commandAction_createBranch,
    CommandActionEnum.readPullRequest => l10n.commandAction_readPullRequest,
    CommandActionEnum.createPullRequest => l10n.commandAction_createPullRequest,
    CommandActionEnum.readAccount => l10n.commandAction_readAccount,
    CommandActionEnum.chooseAccount => l10n.commandAction_chooseAccount,
  };
}
