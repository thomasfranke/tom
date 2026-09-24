/// The branch in the top bar, and the surface it opens.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/branches/branches_design.dart';
import 'package:tom_desktop/screens/branches/widgets/branches_popover_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Which branch is checked out, and the popover that changes it.
///
/// **A popover, not a route and not a dialog.** [Decision
/// 6](../../../../../../docs/technical/decisions/006-no-navigation-package.md)
/// keeps `Navigator` for dialogs only, and this is the first non-modal
/// surface in the app: it hangs off the control that opened it, closes on a
/// click outside or on Escape, and the window behind it stays live.
///
/// It draws nothing until git has been read once. A control that cannot say
/// which branch it would be switching *from* is worse than no control.
class BranchesControlWidget extends ConsumerStatefulWidget {
  /// Creates the control.
  const BranchesControlWidget({super.key});

  @override
  ConsumerState<BranchesControlWidget> createState() =>
      _BranchesControlWidgetState();
}

class _BranchesControlWidgetState extends ConsumerState<BranchesControlWidget> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();

  /// Puts the surface away, and tells the notifier it went.
  void _close() {
    if (_portal.isShowing) {
      _portal.hide();
      ref.read(branchesProvider.notifier).dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    // The surface goes away when the branch actually changed, and on nothing
    // else — which is exactly right for both the cases that must *not* close
    // it: a switch git refused, and one waiting on an answer about unsaved
    // work. Neither moves `HEAD`, so neither gets here.
    ref.listen<BranchNameValueObject?>(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.git?.branch,
      ),
      (BranchNameValueObject? before, BranchNameValueObject? after) {
        if (before != after) {
          _close();
        }
      },
    );
    final GitStatusValueObject? git = ref.watch(
      spaceSessionProvider.select((SpaceSessionState? session) => session?.git),
    );
    if (git == null) {
      return const SizedBox.shrink();
    }
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (BuildContext context) => Positioned(
          width: BranchesDesign.popoverWidth,
          child: CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomLeft,
            // From the control's own bottom edge down to under the bar's
            // rule, which is where the wireframe hangs it.
            offset: const Offset(
              0,
              (TomMetrics.topBar - BranchesDesign.controlHeight) / 2 +
                  BranchesDesign.popoverTop,
            ),
            child: BranchesPopoverWidget(onDismissed: _close),
          ),
        ),
        child: _TriggerWidget(git: git, onPressed: _portal.toggle),
      ),
    );
  }
}

/// The box in the bar: the branch's name, and that there are others.
class _TriggerWidget extends StatelessWidget {
  const _TriggerWidget({required this.git, required this.onPressed});

  final GitStatusValueObject git;
  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<GitStatusValueObject>('git', git))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      width: BranchesDesign.controlWidth,
      height: BranchesDesign.controlHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BranchesDesign.radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                _name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: BranchesDesign.label,
                  height: 1.4,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Text('▾', style: TextStyle(fontSize: 9, color: colors.textMuted)),
          ],
        ),
      ),
    );
  }

  /// What the control says it is on.
  ///
  /// A detached `HEAD` is named as that rather than left blank, the same
  /// words the status bar uses: it is a state somebody has to get out of,
  /// not a missing value (`docs/product/git-workflow/branch-switch/doc.md`).
  String get _name => switch (git) {
    GitStatusValueObject(isDetached: true) => 'detached HEAD',
    GitStatusValueObject(branch: final BranchNameValueObject branch) =>
      branch.value,
    _ => 'no branch',
  };
}
