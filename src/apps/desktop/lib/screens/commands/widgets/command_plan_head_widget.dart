/// What a plan is called, above its first command.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/commands/command_action_label.dart';
import 'package:tom_desktop/screens/commands/commands_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// `Discard all changes · 2 commands`, or `… · stopped · 1 of 2 ran` once
/// somebody denied one (`docs/product/git-workflow/approvals/doc.md`).
class CommandPlanHeadWidget extends StatelessWidget {
  /// Creates the head of [plan], drawn from [state].
  const CommandPlanHeadWidget({
    required this.state,
    required this.plan,
    required this.action,
    super.key,
  });

  /// What the panel lists.
  final CommandsState state;

  /// The plan's number.
  final int plan;

  /// What it is called.
  final CommandActionEnum action;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<CommandsState>('state', state))
      ..add(IntProperty('plan', plan))
      ..add(EnumProperty<CommandActionEnum>('action', action));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TomColors colors = TomColors.of(context);
    final int total = state.planOf(plan).length;
    final bool stopped = state.isStopped(plan);
    final String name = action.label(l10n);
    return SizedBox(
      height: CommandsDesign.headHeight,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(
            left: CommandsDesign.timeLeft,
            bottom: CommandsDesign.headBottom,
          ),
          child: Text(
            stopped
                ? l10n.commandsPlanStopped(name, state.ranIn(plan), total)
                : l10n.commandsPlanHead(name, total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: CommandsDesign.small,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: stopped ? colors.removed : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
