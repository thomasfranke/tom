/// The bar above everything: what space is open, and the global actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/branches/branches_control_widget.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_mode_control_widget.dart';
import 'package:tom_desktop/screens/spaces/space_menu_control_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_controls_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The bar above everything: the way home and the breadcrumb, the branch
/// control, then the modes and the window's own controls.
///
/// It holds no text of its own — each control says what it is for. The
/// modes are here rather than over the document because they are a choice
/// about the whole window, like opening a column
/// (`docs/product/workspace/columns/doc.md`).
class ShellTopBarWidget extends ConsumerWidget {
  /// Creates the top bar.
  const ShellTopBarWidget({super.key});

  /// The modes to the first column toggle: the gap the window's controls
  /// keep between each other.
  static const double modesGap = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SpaceSessionState? session = ref.watch(spaceSessionProvider);
    // A version being read draws as preview and offers no other mode, so the
    // control steps out rather than showing a choice that is not one
    // (`docs/product/git-workflow/file-history/doc.md`).
    final bool readingVersion = session?.readingVersion != null;
    // The breadcrumb starts at 18 and the gear ends 14 short of the edge,
    // which is where every 1b board draws them.
    return TomBarWidget(
      height: TomMetrics.topBar,
      child: Padding(
        padding: const EdgeInsets.only(left: 18, right: 14),
        child: session == null
            // What the design draws with no space open; the shell only shows
            // with one anyway.
            ? const SizedBox.shrink()
            // A stack, not a row: the branch control is centred on the
            // window, so the breadcrumb beside it must not push it
            // ([BranchesDesign]).
            : Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // The home button and the breadcrumb: the way out of the
                  // space and the way across to another
                  // (`docs/product/workspace/leaving-a-space/doc.md`).
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: SpaceMenuControlWidget(),
                  ),
                  const BranchesControlWidget(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (!readingVersion) ...<Widget>[
                          const ShellModeControlWidget(),
                          const SizedBox(width: modesGap),
                        ],
                        const WorkspaceControlsWidget(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
