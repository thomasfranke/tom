/// The switch at the head of the right column.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/bootstrap/panel_descriptor.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// `Changes · History`, in place of the caption that named one panel
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        WorkspaceDesign.switchInsetX,
        WorkspaceDesign.switchTop,
        WorkspaceDesign.switchInsetX,
        WorkspaceDesign.switchTop,
      ),
      child: SizedBox(
        height: WorkspaceDesign.switchHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(WorkspaceDesign.switchRadius),
          ),
          child: Row(
            children: <Widget>[
              for (final PanelDescriptor each in panels)
                Expanded(
                  child: _SegmentWidget(
                    panel: each,
                    isChosen: each.id == chosen.id,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One of them, raised when it is the one showing.
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
    return Padding(
      padding: const EdgeInsets.all(
        WorkspaceDesign.switchInset - WorkspaceDesign.switchStroke,
      ),
      child: Material(
        color: isChosen ? colors.surfaceRaised : Colors.transparent,
        borderRadius: BorderRadius.circular(WorkspaceDesign.switchTileRadius),
        child: InkWell(
          onTap: () =>
              ref.read(workspaceProvider.notifier).showAsidePanel(panel.id),
          borderRadius: BorderRadius.circular(WorkspaceDesign.switchTileRadius),
          child: Center(
            child: Text(
              panel.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: WorkspaceDesign.switchLabel,
                height: 1.4,
                fontWeight: isChosen ? FontWeight.w600 : FontWeight.w400,
                color: isChosen ? colors.textPrimary : colors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
