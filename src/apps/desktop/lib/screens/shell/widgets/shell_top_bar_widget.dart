/// The bar above everything: what space is open, and the global actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/branches/branches_control_widget.dart';
import 'package:tom_desktop/screens/branches/branches_design.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_remote_actions_widget.dart';
import 'package:tom_desktop/screens/spaces/space_menu_control_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_controls_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The bar above everything: the breadcrumb, the branch control and the
/// remote actions.
///
/// It holds no text of its own — each of the three says what it is for, and
/// the breadcrumb is also the way out of the space.
class ShellTopBarWidget extends ConsumerWidget {
  /// Creates the top bar.
  const ShellTopBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SpaceSessionState? session = ref.watch(spaceSessionProvider);
    return SizedBox(
      height: TomMetrics.topBar,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TomMetrics.pad + TomMetrics.chromeInset,
        ),
        child: session == null
            // What the design draws with no space open; the shell only shows
            // with one anyway.
            ? const SizedBox.shrink()
            : const Row(
                children: <Widget>[
                  // The breadcrumb is also the way out of the space, so it
                  // is a control rather than a label
                  // (`docs/product/workspace/leaving-a-space/doc.md`).
                  SpaceMenuControlWidget(),
                  SizedBox(width: BranchesDesign.gap),
                  BranchesControlWidget(),
                  Spacer(),
                  ShellRemoteActionsWidget(),
                  SizedBox(width: WorkspaceDesign.themeGap),
                  WorkspaceControlsWidget(),
                ],
              ),
      ),
    );
  }
}
