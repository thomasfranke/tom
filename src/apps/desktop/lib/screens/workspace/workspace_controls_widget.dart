/// The three controls at the right of the top bar.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/preferences/preferences_control_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The two column toggles, then the preferences gear — one set, read left
/// to right (`docs/product/workspace/columns/doc.md`).
///
/// ~~The theme control sits with them~~: the theme moved inside the
/// [preferences popover](../preferences/preferences_control_widget.dart) and
/// the gear took its place, so the bar still carries three
/// (`docs/product/preferences/the-popover/doc.md`).
class WorkspaceControlsWidget extends ConsumerWidget {
  /// Creates the group.
  const WorkspaceControlsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WorkspaceState state = ref.watch(workspaceProvider);
    final WorkspaceNotifier notifier = ref.read(workspaceProvider.notifier);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _TapWidget(
          tooltip: state.showingExplorer ? 'Hide explorer' : 'Show explorer',
          onPressed: notifier.toggleExplorer,
          child: TomPanelToggleWidget(
            side: TomPanelSideEnum.left,
            isOpen: state.showingExplorer,
            width: WorkspaceDesign.toggleWidth,
            height: WorkspaceDesign.toggleHeight,
            radius: WorkspaceDesign.toggleRadius,
            stroke: WorkspaceDesign.toggleStroke,
            strip: WorkspaceDesign.toggleStrip,
          ),
        ),
        const SizedBox(width: WorkspaceDesign.toggleGap),
        _TapWidget(
          tooltip: state.showingAside ? 'Hide git' : 'Show git',
          onPressed: notifier.toggleAside,
          child: TomPanelToggleWidget(
            side: TomPanelSideEnum.right,
            isOpen: state.showingAside,
            width: WorkspaceDesign.toggleWidth,
            height: WorkspaceDesign.toggleHeight,
            radius: WorkspaceDesign.toggleRadius,
            stroke: WorkspaceDesign.toggleStroke,
            strip: WorkspaceDesign.toggleStrip,
          ),
        ),
        const SizedBox(width: WorkspaceDesign.themeGap),
        // **The bar's last control, and it replaces the light/dark toggle**:
        // the theme moved inside it, so the bar trades one control for
        // another instead of squeezing a fourth into the same margin
        // (`docs/product/preferences/the-popover/doc.md`).
        const PreferencesControlWidget(),
      ],
    );
  }
}

/// One of the three: the glyph, and a target big enough to hit it.
class _TapWidget extends StatelessWidget {
  const _TapWidget({
    required this.child,
    required this.tooltip,
    required this.onPressed,
  });

  final Widget child;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('tooltip', tooltip))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(WorkspaceDesign.toggleRadius),
      child: child,
    ),
  );
}
