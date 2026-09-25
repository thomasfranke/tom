/// The bar above everything: what space is open, and the global actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/branches/branches_control_widget.dart';
import 'package:tom_desktop/screens/branches/branches_design.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_remote_actions_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The bar above everything: `repository / folder`, the branch control and
/// the remote actions.
///
/// Repository and folder both, because a space is a folder and three
/// checkouts all have a `docs/`.
class ShellTopBarWidget extends ConsumerWidget {
  /// Creates the top bar.
  const ShellTopBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SpaceSessionState? session = ref.watch(spaceSessionProvider);
    final TomColors colors = TomColors.of(context);
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
            : Row(
                children: <Widget>[
                  Text(
                    SpaceEntity.nameOfFolder(session.space.repositoryRoot),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '/',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                  Text(
                    session.space.name,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: BranchesDesign.gap),
                  const BranchesControlWidget(),
                  const Spacer(),
                  const ShellRemoteActionsWidget(),
                ],
              ),
      ),
    );
  }
}
