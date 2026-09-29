/// What the document is compared against, and the surface that changes it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/compare/compare_design.dart';
import 'package:tom_desktop/screens/compare/widgets/compare_popover_widget.dart';
import 'package:tom_desktop/screens/history/history_words.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The base of the comparison, said where the diff is read.
///
/// A popover anchored to its trigger, the pattern the branch switcher set
/// ([Decision 6](../../../../../../docs/technical/decisions/006-no-navigation-package.md)).
/// **The base is the space's, not the document's** — it lives on the session
/// and outlives whatever is open, so clicking the next file keeps the
/// comparison (`docs/product/diff/branch-diff/doc.md`). What is scoped to one
/// file is where the diff is *drawn*; the control draws nothing with no
/// document open because there is nothing on screen to measure.
class CompareControlWidget extends ConsumerStatefulWidget {
  /// Creates the control.
  const CompareControlWidget({super.key});

  @override
  ConsumerState<CompareControlWidget> createState() =>
      _CompareControlWidgetState();
}

class _CompareControlWidgetState extends ConsumerState<CompareControlWidget> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();

  /// Puts the surface away, and tells the notifier it went.
  void _close() {
    if (_portal.isShowing) {
      _portal.hide();
      ref.read(compareProvider.notifier).dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    // The surface goes away when the base actually changed, which is the one
    // thing it was opened to do.
    ref.listen<RevisionValueObject?>(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.comparingAgainst,
      ),
      (RevisionValueObject? before, RevisionValueObject? after) {
        if (before != after) {
          _close();
        }
      },
    );
    final ({bool hasDocument, RevisionValueObject? base, bool marking})
    showing = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => (
          hasDocument: session?.openDocument != null,
          base: session?.comparingAgainst,
          marking: session?.showingDiff ?? true,
        ),
      ),
    );
    if (!showing.hasDocument) {
      return const SizedBox.shrink();
    }
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (BuildContext context) => Positioned(
          width: CompareDesign.popoverWidth,
          child: CompositedTransformFollower(
            link: _link,
            // Hung from the control's right edge, because the control sits at
            // the right of the bar and a popover anchored left would run off
            // the window on a narrow one.
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, CompareDesign.popoverTop),
            child: ComparePopoverWidget(onDismissed: _close),
          ),
        ),
        child: _TriggerWidget(
          base: showing.base,
          isMarking: showing.marking,
          onPressed: _portal.toggle,
        ),
      ),
    );
  }
}

/// The control in the bar: what is being compared against, or the offer to.
class _TriggerWidget extends StatelessWidget {
  const _TriggerWidget({
    required this.base,
    required this.isMarking,
    required this.onPressed,
  });

  final RevisionValueObject? base;

  /// Whether the preview is drawing what changed.
  final bool isMarking;

  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<RevisionValueObject?>('base', base))
      ..add(DiagnosticsProperty<bool>('isMarking', isMarking))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    // The base is named beside the chip, not inside it: the chip is 62 points
    // wide and a branch name is not
    // (`design/screens/desktop/git-diff/comparing-dark.svg`).
    // The chip is lit while the marks are being drawn, and the name beside it
    // only while there is a base to name.
    final bool chosen = base != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (chosen && isMarking) ...<Widget>[
          // Flexible so the ellipsis it asks for can actually happen: in a
          // row that sizes to its children, a name simply grows.
          Flexible(
            child: Text(
              compareLabelOf(base),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: CompareDesign.label,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: colors.added,
              ),
            ),
          ),
          const SizedBox(width: CompareDesign.chipGap),
        ],
        SizedBox(
          width: CompareDesign.chipWidth,
          height: CompareDesign.chipHeight,
          child: Material(
            color: isMarking ? colors.addedSoft : Colors.transparent,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isMarking ? colors.added : colors.borderStrong,
              ),
              borderRadius: BorderRadius.circular(CompareDesign.chipRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Center(
                child: Text(
                  'Diff',
                  style: TextStyle(
                    fontSize: CompareDesign.label,
                    height: 1.4,
                    color: isMarking ? colors.added : colors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// What the control says: the base it is on, or the offer to pick one.
///
/// A branch by name and a commit by its abbreviated sha and age, which is
/// how the history panel names one — the same fact should read the same way
/// in both places.
String compareLabelOf(RevisionValueObject? base) => switch (base) {
  null => 'Compare against…',
  RevisionBranch(:final BranchEntity branch) =>
    'Compared to ${branch.name.value}',
  RevisionCommit(:final CommitEntity commit) =>
    'Compared to ${commit.sha.short} · ${whenInWords(commit.date)}',
};
