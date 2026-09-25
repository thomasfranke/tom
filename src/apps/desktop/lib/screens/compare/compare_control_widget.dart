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
/// It draws nothing with no document open: a base is per document, because
/// the comparison is scoped to one file (`docs/product/diff/branch-diff/doc.md`).
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
    final ({bool hasDocument, RevisionValueObject? base}) showing = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => (
          hasDocument: session?.openDocument != null,
          base: session?.comparingAgainst,
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
        child: _TriggerWidget(base: showing.base, onPressed: _portal.toggle),
      ),
    );
  }
}

/// The control in the bar: what is being compared against, or the offer to.
class _TriggerWidget extends StatelessWidget {
  const _TriggerWidget({required this.base, required this.onPressed});

  final RevisionValueObject? base;
  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<RevisionValueObject?>('base', base))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    // The chosen base is emphasised and the offer is not: one is a state
    // somebody put the window in, the other is a control nobody has used.
    final bool chosen = base != null;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: chosen ? colors.accent : colors.textMuted,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: TextStyle(
          fontSize: CompareDesign.label,
          height: 1.4,
          fontWeight: chosen ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      child: Text(
        compareLabelOf(base),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
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
