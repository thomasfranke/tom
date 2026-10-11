/// The head of the panel under the document.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Tabs, what the chosen panel says after them, and the `×` that closes the
/// region (`docs/product/workspace/commands/doc.md`).
///
/// Tabs even with one panel, unlike the right column's switch: the region is
/// built for a second one, and a lone tab still names what is open.
class WorkspaceBottomHeadWidget extends ConsumerWidget {
  /// Creates the head over [panels], with [chosen] underlined.
  const WorkspaceBottomHeadWidget({
    required this.panels,
    required this.chosen,
    super.key,
  });

  /// The region's panels, in the registry's order.
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
    return Container(
      height: WorkspaceDesign.bottomHead + 1,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.only(left: WorkspaceDesign.bottomTabsInset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final PanelDescriptor each in panels) ...<Widget>[
            _TabWidget(panel: each, isChosen: each.id == chosen.id),
            if (each != panels.last)
              const SizedBox(width: WorkspaceDesign.bottomTabsGap),
          ],
          // Expanded, so a long folder after the terminal's tab is cut short
          // rather than pushing the `×` off the panel, and left-aligned: what
          // the panel says starts right after the tabs.
          if (chosen.summary case final WidgetBuilder summary)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: summary(context),
              ),
            )
          else
            const Spacer(),
          Tooltip(
            message: context.l10n.workspaceClosePanel,
            child: InkWell(
              onTap: ref.read(workspaceProvider.notifier).toggleBottom,
              borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
              // The glyph at the box's left, so it lands where the board
              // puts it and the target runs on to the panel's edge.
              child: SizedBox(
                width: WorkspaceDesign.bottomClose,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TomGlyphWidget(
                    glyph: TomGlyphEnum.close,
                    // The glyph's own 14: 10 by 10 of ink, as the board's.
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One tab, underlined at the head's foot when it is the one showing.
class _TabWidget extends ConsumerWidget {
  const _TabWidget({required this.panel, required this.isChosen});

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
          ref.read(workspaceProvider.notifier).showBottomPanel(panel.id),
      child: Stack(
        children: <Widget>[
          Center(
            child: Text(
              panel.title(context),
              maxLines: 1,
              style: TextStyle(
                fontSize: WorkspaceDesign.bottomTabsLabel,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: isChosen ? colors.textPrimary : colors.textSecondary,
              ),
            ),
          ),
          if (isChosen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: WorkspaceDesign.tabsUnderline,
              child: ColoredBox(color: colors.accent),
            ),
        ],
      ),
    );
  }
}
