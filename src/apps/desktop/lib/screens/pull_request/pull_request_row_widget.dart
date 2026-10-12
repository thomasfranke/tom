/// The control that opens the branch's pull request, at the top of the tree.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// `Pull request`: a shortcut to the branch's draft, read as a document row
/// and lit like one while it is open, with a hairline under it that says it
/// is not a file in the space
/// (`docs/product/git-workflow/pull-request/the-control/doc.md`).
///
/// **Always drawn**, and unavailable where there is nothing to propose —
/// muted, with the reason under its name and the whole sentence in its
/// tooltip (`git-pull-request/pull-request-row-states-dark.svg`). A folder
/// with no repository draws it muted with no reason: the one git control
/// that stays, because a shortcut that vanishes is one somebody hunts for
/// (`docs/product/workspace/without-a-repository/doc.md`).
class PullRequestRowWidget extends ConsumerWidget {
  /// Creates the row.
  const PullRequestRowWidget({super.key});

  /// What the row takes from the top of the tree when it can act.
  static const double extent =
      PullRequestDesign.rowTop +
      PullRequestDesign.rowHeight +
      PullRequestDesign.ruleGap +
      1 +
      PullRequestDesign.afterRule;

  /// What it takes when it carries a reason under its name.
  static const double unavailableExtent =
      extent + PullRequestDesign.reasonHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GitStatusValueObject? git = ref.watch(
      spaceSessionProvider.select((SpaceSessionState? session) => session?.git),
    );
    final ({PullRequestAvailabilityEnum availability, String? base}) read = ref
        .watch(
          pullRequestProvider.select(
            (PullRequestState state) => (
              availability: state.availability(git),
              base: state.target?.defaultBranch?.value,
            ),
          ),
        );
    final bool isOpen = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.pullRequest != null,
      ),
    );
    final bool canAct =
        read.availability == PullRequestAvailabilityEnum.available;
    final ({String short, String whole})? reason = _reason(
      context.l10n,
      read.availability,
      read.base,
    );
    final double rowHeight = reason == null
        ? PullRequestDesign.rowHeight
        : PullRequestDesign.rowHeight + PullRequestDesign.reasonHeight;
    // With a reason under it, the name rises to make room.
    final double nameLine = reason == null
        ? PullRequestDesign.rowHeight
        : PullRequestDesign.nameLine;
    final TomColors colors = TomColors.of(context);
    final Color ink = canAct ? colors.textPrimary : colors.textMuted;
    final Widget label = Text(
      context.l10n.panelPullRequest,
      maxLines: 1,
      style: TextStyle(
        fontSize: 12.5,
        height: 1.4,
        fontWeight: isOpen ? FontWeight.w600 : FontWeight.w500,
        color: isOpen ? colors.accent : ink,
      ),
    );
    final Widget row = Material(
      color: isOpen ? colors.accentSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        // Unavailable is not pressable: the reason is the answer, and a
        // press that did nothing would ask the question again.
        onTap: canAct
            ? () => ref.read(pullRequestProvider.notifier).open()
            : null,
        // Measured from the fill's edge, which is the row's inset in.
        child: Stack(
          children: <Widget>[
            // The bar the tree's open row wears, for the same reason.
            if (isOpen)
              Positioned(
                left: 0,
                top: (rowHeight - FileTreeDesign.barHeight) / 2,
                width: FileTreeDesign.barWidth,
                height: FileTreeDesign.barHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            Positioned(
              left: PullRequestDesign.glyphLeft - FileTreeDesign.rowInset,
              top: 0,
              height: nameLine,
              child: Center(
                child: TomGlyphWidget(
                  glyph: TomGlyphEnum.branch,
                  color: canAct ? colors.accent : colors.textMuted,
                  size: PullRequestDesign.glyph,
                ),
              ),
            ),
            Positioned(
              left: PullRequestDesign.labelLeft - FileTreeDesign.rowInset,
              right: 0,
              top: 0,
              height: nameLine,
              child: Align(alignment: Alignment.centerLeft, child: label),
            ),
            if (reason != null)
              Positioned(
                left: PullRequestDesign.labelLeft - FileTreeDesign.rowInset,
                right: 0,
                top: PullRequestDesign.reasonTop,
                child: Text(
                  reason.short,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: colors.textMuted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return SizedBox(
      height: reason == null ? extent : unavailableExtent,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: FileTreeDesign.rowInset,
            right: FileTreeDesign.rowInset,
            top: PullRequestDesign.rowTop,
            height: rowHeight,
            child: reason == null
                ? row
                : Tooltip(message: reason.whole, child: row),
          ),
          Positioned(
            left: PullRequestDesign.ruleInset,
            right: PullRequestDesign.ruleInset,
            top:
                PullRequestDesign.rowTop +
                rowHeight +
                PullRequestDesign.ruleGap,
            height: 1,
            child: ColoredBox(color: colors.border),
          ),
        ],
      ),
    );
  }

  /// What an unavailable row says under its name, and in its tooltip; null
  /// when there is no reason to give — the row can act, or git is still
  /// answering.
  static ({String short, String whole})? _reason(
    AppLocalizations l10n,
    PullRequestAvailabilityEnum availability,
    String? base,
  ) => switch (availability) {
    PullRequestAvailabilityEnum.available ||
    PullRequestAvailabilityEnum.reading ||
    PullRequestAvailabilityEnum.noRepository => null,
    PullRequestAvailabilityEnum.onBase => (
      short: l10n.pullRequestOnBase(base ?? ''),
      whole: l10n.pullRequestOnBaseWhy(base ?? ''),
    ),
    PullRequestAvailabilityEnum.unknownHost => (
      short: l10n.pullRequestUnknownHost,
      whole: l10n.pullRequestUnknownHostWhy,
    ),
    PullRequestAvailabilityEnum.noRemote => (
      short: l10n.pullRequestNoRemote,
      whole: l10n.pullRequestNoRemoteWhy,
    ),
    PullRequestAvailabilityEnum.detached => (
      short: l10n.pullRequestDetached,
      whole: l10n.pullRequestDetachedWhy,
    ),
    PullRequestAvailabilityEnum.noBase => (
      short: l10n.pullRequestNoBase,
      whole: l10n.pullRequestNoBaseWhy,
    ),
    PullRequestAvailabilityEnum.unreadable => (
      short: l10n.pullRequestUnreadable,
      whole: l10n.pullRequestUnreadableWhy,
    ),
  };
}
