/// What the commands panel says after the tabs.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/commands/commands_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// `N this session` — every command since the window opened, the ones the
/// list has already let go of included.
class CommandsCountWidget extends ConsumerWidget {
  /// Creates the count.
  const CommandsCountWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final int waiting = ref.watch(
      commandsProvider.select((CommandsState it) => it.waiting),
    );
    final int total = ref.watch(
      commandsProvider.select((CommandsState it) => it.total),
    );
    // Asked only while something waits, which is a gate that has read the
    // preferences already: a panel that never waited needs none wired.
    final GitApprovalModeEnum mode = waiting == 0
        ? GitApprovalModeEnum.automatic
        : ref.watch(
            preferencesProvider.select(
              (PreferencesValueObject it) => it.gitApprovals,
            ),
          );
    // While something waits the head says who is asking and how many, in
    // the place of the session's count (`approvals/doc.md`).
    return Padding(
      padding: const EdgeInsets.only(left: CommandsDesign.countLead),
      child: Text(
        waiting > 0
            ? l10n.commandsWaitingCount(switch (mode) {
                GitApprovalModeEnum.automatic => l10n.gitModeAutomatic,
                GitApprovalModeEnum.semi => l10n.gitModeSemi,
                GitApprovalModeEnum.manual => l10n.gitModeManual,
              }, waiting)
            : l10n.commandsThisSession(total),
        maxLines: 1,
        style: TextStyle(
          fontSize: CommandsDesign.count,
          height: 1.3,
          color: TomColors.of(context).textMuted,
        ),
      ),
    );
  }
}
