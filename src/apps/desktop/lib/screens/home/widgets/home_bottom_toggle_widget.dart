/// The bar's toggle for the panel under the content, on Home.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The middle toggle of the workspace's three, alone: Home has no columns,
/// but the Commands panel is reachable from it the same way.
class HomeBottomToggleWidget extends ConsumerWidget {
  /// Creates the toggle.
  const HomeBottomToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isOpen = ref.watch(
      workspaceProvider.select((WorkspaceState it) => it.showingBottom),
    );
    return Tooltip(
      message: isOpen
          ? context.l10n.workspaceHideBottom
          : context.l10n.workspaceShowBottom,
      child: InkWell(
        onTap: ref.read(workspaceProvider.notifier).toggleBottom,
        borderRadius: BorderRadius.circular(WorkspaceDesign.toggleRadius),
        child: TomPanelToggleWidget(
          side: TomPanelSideEnum.bottom,
          isOpen: isOpen,
          width: WorkspaceDesign.toggleWidth,
          height: WorkspaceDesign.toggleHeight,
          radius: WorkspaceDesign.toggleRadius,
          stroke: WorkspaceDesign.toggleStroke,
          strip: WorkspaceDesign.toggleStripBottom,
        ),
      ),
    );
  }
}
