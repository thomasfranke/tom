/// The bar above the document area: the three modes, and the unsaved mark.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/compare/compare_control_widget.dart';
import 'package:tom_desktop/screens/compare/compare_design.dart';
import 'package:tom_desktop/screens/editor/editor_toolbar_widget.dart';
import 'package:tom_desktop/screens/history/history_words.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_mode_control_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The row above the document: the formatting tools, whether the buffer has
/// reached the disk, and the `Diff` chip.
///
/// Chrome, not a panel. The modes it used to carry are the top bar's now
/// ([ShellModeControlWidget]); what is left is anchored to the pane at both
/// ends, because every one of it is about the document under it.
class ShellModeBarWidget extends ConsumerWidget {
  /// Creates the bar, inset by the columns beside it.
  const ShellModeBarWidget({
    this.leftInset = 0,
    this.rightInset = 0,
    super.key,
  });

  /// How wide the column to the left of this bar is, or 0 when it is closed.
  ///
  /// Kept although nothing reads it any more: the modes used to be centred
  /// on the window and needed it. The shell still hands it in, and the day
  /// something in this row is measured against the window again it is here.
  final double leftInset;

  /// How wide the column to the right is, or 0 when it is closed.
  final double rightInset;

  /// Left edge to the first thing in the bar, and the gap between two of them.
  static const double _inset = 16;
  static const double _gap = 16;

  /// The chip's right edge to the document island's.
  ///
  /// Measured from the pane, not the window: both ends of this row travel
  /// when a column opens (`docs/design/screens/measurements.md`).
  static const double _chipInset = 12;

  /// The dot that says the buffer and the file disagree.
  static const double _dot = 8;

  /// What the row keeps for itself at the right, whatever is in it.
  ///
  /// The two gaps, the chip and its inset — the **chip's own label is not in
  /// it**, because what the tools are given must not change when a switch
  /// brings a base to name.
  static const double _rightMinimum =
      _gap + _gap + CompareDesign.chipWidth + _chipInset;

  /// What the tools are given, which is never more than they need.
  ///
  /// The unsaved mark keeps only its dot here: with the git column open the
  /// row has fifteen points to spare over the thirteen buttons and the `⋯`,
  /// and the boards put that mark on the tab anyway.
  static double _toolsRoom(double row) => math.max(
    0,
    math.min(EditorToolbarWidget.widthOfAll, row - _rightMinimum - _dot),
  );

  /// What is left for the base's name beside the chip: the row less the
  /// tools, the fixed right group and the unsaved dot.
  static double _labelRoom(double row) =>
      row - _toolsRoom(row) - _rightMinimum - _dot;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('leftInset', leftInset))
      ..add(DoubleProperty('rightInset', rightInset));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CommitEntity? reading = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.readingVersion,
      ),
    );
    if (reading != null) {
      return _VersionBarWidget(commit: reading);
    }
    // On the island itself: the 1b toolbar is flat glyphs, and a hairline
    // under the row is all that separates it from the document.
    return _StripWidget(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints row) => Row(
          children: <Widget>[
            // **Measured, not flexed.** The tools' shape must not answer to
            // what shares the row with them: a word that appeared beside
            // them was taking seventy points off the bar and collapsing a
            // whole group with it
            // (`docs/product/editor/formatting-shortcuts/doc.md`).
            SizedBox(
              width: _toolsRoom(row.maxWidth),
              child: const EditorToolbarWidget(),
            ),
            const SizedBox(width: _gap),
            // Between the two ends rather than at the right, where it would
            // take the chip off the pane's edge.
            //
            // **The slack lives here**, which is what keeps the right group
            // flush right, lets the word go when the row is short, and
            // absorbs the chip's own label instead of overflowing on it.
            const Expanded(
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  maxWidth: double.infinity,
                  child: _UnsavedMarkWidget(),
                ),
              ),
            ),
            const SizedBox(width: _gap),
            // **Both ends are anchored to the pane, not to the window**: the
            // tools at its left edge, the chip at its right. The modes left
            // this row for the top bar (`docs/product/workspace/columns/doc.md`).
            // The base's name gets what the row has left, so it ends in an
            // ellipsis instead of pushing the row off the island.
            CompareControlWidget(labelRoom: _labelRoom(row.maxWidth)),
            const SizedBox(width: _chipInset),
          ],
        ),
      ),
    );
  }
}

/// The row's own surface: the island's, the document area's width, 36 tall.
class _StripWidget extends StatelessWidget {
  const _StripWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: TomMetrics.modeBar,
    child: ColoredBox(color: TomColors.of(context).surfaceRaised, child: child),
  );
}

/// The bar while a past version is on screen: which version, and the way
/// back (`docs/product/git-workflow/file-history/doc.md`).
///
/// It replaces the modes rather than joining them, because there is no
/// source for a commit.
class _VersionBarWidget extends ConsumerWidget {
  const _VersionBarWidget({required this.commit});

  final CommitEntity commit;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<CommitEntity>('commit', commit));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return _StripWidget(
      child: Row(
        children: <Widget>[
          const SizedBox(width: ShellModeBarWidget._inset),
          Expanded(
            child: Text(
              context.l10n.shellReadingVersion(
                commit.sha.short,
                commit.author.name,
                whenInWords(context.l10n, commit.date),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: ShellModeBarWidget._gap),
          // The chip stays, because it is the space's switch and the boards
          // draw it here; the base is not named, because a version is the
          // past and is compared against nothing
          // (`docs/product/diff/rendered-diff/what-is-compared/doc.md`).
          const CompareControlWidget(labelRoom: 0),
          const SizedBox(width: ShellModeBarWidget._gap),
          TextButton(
            onPressed: () => ref.read(historyProvider.notifier).closeVersion(),
            style: TextButton.styleFrom(
              foregroundColor: colors.accent,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(context.l10n.shellBackToNow),
          ),
          const SizedBox(width: TomMetrics.pad),
        ],
      ),
    );
  }
}

/// A save that was refused, named where the editing happens.
///
/// Nothing for an edit that is only unwritten: the tab's dot says that, and
/// a refusal is the one thing a dot cannot say
/// (`docs/product/editor/source-mode/doc.md`).
class _UnsavedMarkWidget extends ConsumerWidget {
  const _UnsavedMarkWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool refused = ref.watch(
      editorProvider.select(
        (EditorState state) =>
            state is EditorReady && state.saveFailure != null,
      ),
    );
    if (!refused) {
      return const SizedBox.shrink();
    }
    final Color colour = TomColors.of(context).removed;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: ShellModeBarWidget._dot,
          height: ShellModeBarWidget._dot,
          child: DecoratedBox(
            decoration: BoxDecoration(color: colour, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 8),
        // The word is what goes first when the row is short.
        Flexible(
          child: Text(
            context.l10n.shellNotSaved,
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
            style: TextStyle(fontSize: 13, height: 1.4, color: colour),
          ),
        ),
      ],
    );
  }
}
