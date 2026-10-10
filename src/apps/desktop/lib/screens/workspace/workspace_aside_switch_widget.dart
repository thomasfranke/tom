/// The switch at the head of the right column.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// `Git · History`, as tabs, in place of the caption that named one panel
/// (`docs/product/workspace/columns/doc.md`).
///
/// It names no panel: the segments are the registered panels' own titles, so
/// a third one from any module is a third segment
/// ([Decision 12](../../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).
/// A caption says what you are looking at; this says that and what else
/// there is.
class WorkspaceAsideSwitchWidget extends ConsumerWidget {
  /// Creates the switch over [panels], with [chosen] raised.
  const WorkspaceAsideSwitchWidget({
    required this.panels,
    required this.chosen,
    super.key,
  });

  /// The right column's panels, in the order the registry gave them.
  final List<PanelDescriptor> panels;

  /// Which one is showing.
  final PanelDescriptor chosen;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<PanelDescriptor>('panels', panels))
      ..add(DiagnosticsProperty<PanelDescriptor>('chosen', chosen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    // Tabs, not a segmented control: a 1b board draws the right column's
    // head as names with the chosen one underlined, the way an IDE's tool
    // window does, and a rule under the row.
    return Container(
      height: WorkspaceDesign.tabsHeight,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.only(left: WorkspaceDesign.tabsInset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // The tabs take what the actions leave and scroll past it, so a
          // third panel from a module never pushes the menu off the column.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final PanelDescriptor each in panels) ...<Widget>[
                    _SegmentWidget(panel: each, isChosen: each.id == chosen.id),
                    const SizedBox(width: WorkspaceDesign.tabsGap),
                  ],
                ],
              ),
            ),
          ),
          // Flush with the column's edge: where the actions sit inside that is
          // the panel's measurement, not the switch's.
          if (chosen.actions case final WidgetBuilder actions)
            Center(child: actions(context)),
        ],
      ),
    );
  }
}

/// One of them, underlined when it is the one showing.
class _SegmentWidget extends ConsumerWidget {
  const _SegmentWidget({required this.panel, required this.isChosen});

  final PanelDescriptor panel;
  final bool isChosen;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<PanelDescriptor>('panel', panel))
      ..add(DiagnosticsProperty<bool>('isChosen', isChosen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return InkWell(
      onTap: () =>
          ref.read(workspaceProvider.notifier).showAsidePanel(panel.id),
      child: Stack(
        children: <Widget>[
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  panel.title(context),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: WorkspaceDesign.tabsLabel,
                    height: 1.4,
                    fontWeight: isChosen ? FontWeight.w600 : FontWeight.w500,
                    color: isChosen ? colors.textPrimary : colors.textMuted,
                  ),
                ),
                // Inside the segment, so the underline runs under both.
                if (panel.badge case final WidgetBuilder badge) ...<Widget>[
                  const SizedBox(width: WorkspaceDesign.tabsBadgeGap),
                  badge(context),
                ],
              ],
            ),
          ),
          if (isChosen)
            Positioned(
              left: 0,
              right: 0,
              bottom: WorkspaceDesign.tabsUnderlineBottom,
              height: WorkspaceDesign.tabsUnderline,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
