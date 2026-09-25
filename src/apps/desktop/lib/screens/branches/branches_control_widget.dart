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
/// A popover anchored to the control, not a route or a dialog
/// ([Decision 6](../../../../../../docs/technical/decisions/006-no-navigation-package.md)).
/// It draws nothing until git has been read once, since a control that
/// cannot say which branch it switches from is worse than none.
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
    // Closes when the branch actually changed and on nothing else: a refused
    // switch and a standing question about unsaved work both leave `HEAD`
    // where it is, and both must keep the surface open.
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
            // From the control's bottom edge to under the bar's rule, where
            // the wireframe hangs it.
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
  /// A detached `HEAD` is named, in the status bar's words, because it is a
  /// state to get out of rather than a missing value.
  String get _name => switch (git) {
    GitStatusValueObject(isDetached: true) => 'detached HEAD',
    GitStatusValueObject(branch: final BranchNameValueObject branch) =>
      branch.value,
    _ => 'no branch',
  };
}
