/// What the document is compared against, and the chip that turns the marks
/// on and off.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/compare/compare_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The `Diff` chip, and the base named beside it.
///
/// **A press only turns the marks off and on**: the base is nobody's choice,
/// it is the branch the checked-out one came from
/// (`docs/product/diff/rendered-diff/turning-it-off/doc.md`). Nothing is drawn
/// with no document open, no repository, a text file or a deleted one.
class CompareControlWidget extends ConsumerWidget {
  /// Creates the control, the base's name given at most [labelRoom].
  const CompareControlWidget({this.labelRoom = double.infinity, super.key});

  /// The least a name is worth drawing in.
  static const double _leastLabel = 48;

  /// How wide the base's name beside the chip may be; under the least a name
  /// can be read in, it is not drawn and the chip's tooltip carries it.
  final double labelRoom;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('labelRoom', labelRoom));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ({bool hasMarks, BranchRefValueObject? base, bool marking}) showing =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => (
              // No repository, nothing to compare with: the chip goes too
              // (`docs/product/workspace/without-a-repository/doc.md`).
              // A text file's marks are not the chip's to turn off: they are
              // all its tab has to say (`commit/opening-a-change/doc.md`).
              hasMarks:
                  session?.onScreen != null &&
                  session!.space.hasRepository &&
                  !session.isSourceOnly &&
                  !_isGone(session),
              // The branch alone: the fork point under it is the preview's.
              base: session?.comparingAgainst?.branch,
              marking: session?.showingDiff ?? true,
            ),
          ),
        );
    if (!showing.hasMarks) {
      return const SizedBox.shrink();
    }
    final TomColors colors = TomColors.of(context);
    final bool marking = showing.marking;
    // The base is named beside the chip, not inside it: the chip is 62 points
    // wide and a branch name is not
    // (`design/screens/desktop/git-diff/comparing-dark.svg`).
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showing.base != null &&
            marking &&
            labelRoom - CompareDesign.chipGap >= _leastLabel) ...<Widget>[
          // Bounded by what the bar says is left, so a long name ends in an
          // ellipsis instead of pushing the row off the island.
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: labelRoom - CompareDesign.chipGap,
            ),
            child: Text(
              compareLabelOf(context.l10n, showing.base),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: CompareDesign.label,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: colors.accent,
              ),
            ),
          ),
          const SizedBox(width: CompareDesign.chipGap),
        ],
        // The name in the tooltip as well: the 1b row rarely has room for it
        // beside the chip, and the board draws the chip alone.
        // On, a chosen control (`accent_soft`, `accent`); off, a control at
        // rest (`border_strong`, `text_secondary`) — never `text_muted`,
        // which reads as unavailable on a chip that can always be pressed.
        Tooltip(
          message: compareLabelOf(context.l10n, showing.base),
          child: SizedBox(
            width: CompareDesign.chipWidth,
            height: CompareDesign.chipHeight,
            child: Material(
              color: marking ? colors.accentSoft : Colors.transparent,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: marking ? colors.accent : colors.borderStrong,
                ),
                borderRadius: BorderRadius.circular(CompareDesign.chipRadius),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: ref.read(spaceSessionProvider.notifier).toggleDiff,
                child: Center(
                  child: Text(
                    context.l10n.compareDiff,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: marking ? colors.accent : colors.textSecondary,
                    ),
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

/// Whether git reports the document on screen deleted: turning its marks off
/// would leave an empty page, since every block of it is the removal.
///
/// Git's reading, as the strip's `(deleted)` reads it, rather than the
/// editor's, so the chip never makes a buffer exist.
bool _isGone(SpaceSessionState session) =>
    session.git?.entries.any(
      (StatusEntryValueObject entry) =>
          entry.state == FileStateEnum.deleted &&
          DocumentTab.of(session.space, entry.path) == session.onScreen,
    ) ??
    false;

/// What the control says the document is compared against: the branch it
/// came from by the name git resolves, or the last commit.
String compareLabelOf(AppLocalizations l10n, BranchRefValueObject? base) =>
    switch (base) {
      null => l10n.compareToLastCommit,
      final BranchRefValueObject branch => l10n.compareTo(branch.spec),
    };
