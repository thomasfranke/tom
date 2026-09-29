/// The three controls at the right of the top bar.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Theme, then the two column toggles — one set, read left to right
/// (`docs/product/workspace/columns/doc.md`).
///
/// The theme control sits with them rather than in a menu, drawn in their
/// grammar so the three read as one group rather than as a control that
/// wandered in.
class WorkspaceControlsWidget extends ConsumerWidget {
  /// Creates the group.
  const WorkspaceControlsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WorkspaceState state = ref.watch(workspaceProvider);
    final WorkspaceNotifier notifier = ref.read(workspaceProvider.notifier);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _TapWidget(
          tooltip: isDark ? 'Light theme' : 'Dark theme',
          // What it switches to is read off the theme actually drawn, so the
          // first press after opening is never the one that changes nothing.
          onPressed: () => notifier.chooseTheme(
            isDark ? ThemeChoiceEnum.light : ThemeChoiceEnum.dark,
          ),
          child: TomThemeToggleWidget(
            isDark: isDark,
            size: WorkspaceDesign.themeBox,
            stroke: WorkspaceDesign.toggleStroke,
          ),
        ),
        const SizedBox(width: WorkspaceDesign.themeGap),
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
