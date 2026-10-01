/// The bar above the document area: the three modes, and the unsaved mark.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/compare/compare_control_widget.dart';
import 'package:tom_desktop/screens/compare/compare_design.dart';
import 'package:tom_desktop/screens/editor/editor_toolbar_widget.dart';
import 'package:tom_desktop/screens/history/history_words.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_mode_control_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Source · Split · Preview, and whether the buffer has reached the disk.
///
/// Chrome, not a panel: it decides which panels the document region draws
/// and still names none, because what it writes is the mode and the
/// descriptor says which panels that includes.
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
  static const double _inset = 28;
  static const double _gap = 32;

  /// The mode control to the `Diff` chip, which `screens/measurements.md`
  /// fixes at 24 with the chip 9 from the document's right edge.
  static const double _chipGap = 24;

  /// The chip's right edge to the document container's.
  ///
  /// Nine, not the window's padding: both ends of this row are measured from
  /// the pane, so they travel when a column opens
  /// (`docs/design/screens/measurements.md`).
  static const double _chipInset = 9;

  /// The dot that says the buffer and the file disagree.
  static const double _dot = 8;

  /// What the row keeps for itself at the right, whatever is in it.
  ///
  /// The two gaps, the modes, the chip and its inset — the **chip's own
  /// label is not in it**, because what the tools are given must not change
  /// when somebody picks a branch to compare against.
  static const double _rightMinimum =
      _gap +
      _gap +
      ShellModeControlWidget.trackWidth +
      _chipGap +
      CompareDesign.chipWidth +
      _chipInset;

  /// What the tools are given, which is never more than they need.
  ///
  /// The unsaved mark keeps only its dot here: with the git column open the
  /// row has fifteen points to spare over the thirteen buttons and the `⋯`,
  /// and the boards put that mark on the tab anyway.
  static double _toolsRoom(double row) => math.max(
    0,
    math.min(EditorToolbarWidget.widthOfAll, row - _rightMinimum - _dot),
  );

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
    // A sunken strip, not the page: every board draws the row above the
    // document `surface_sunken` over the document container's width, which
    // is what makes the toolbar's raised tiles read as buttons.
    return _StripWidget(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints row) => Row(
          children: <Widget>[
            // **Measured, not flexed.** The tools' shape must not answer to
            // what shares the row with them: an `Unsaved` that appeared on
            // the first keystroke was taking seventy points off the bar and
            // collapsing a whole group with it
            // (`docs/product/editor/formatting-shortcuts/doc.md`).
            SizedBox(
              width: _toolsRoom(row.maxWidth),
              child: const EditorToolbarWidget(),
            ),
            const SizedBox(width: _gap),
            // Between the two ends rather than at the right: the boards put
            // this on the tab, and there are no tabs yet — at the right it
            // would take the chip off the pane's edge.
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
            // **Both ends are anchored to the pane, not to the window.** The
            // modes used to be centred on the window; a centred control in a
            // full row is one the buttons run into
            // (`docs/product/workspace/columns/doc.md`).
            const ShellModeControlWidget(),
            const SizedBox(width: _chipGap),
            const CompareControlWidget(),
            const SizedBox(width: _chipInset),
          ],
        ),
      ),
    );
  }
}

/// The row's own surface: sunken, the document area's width, 36 tall.
class _StripWidget extends StatelessWidget {
  const _StripWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: TomMetrics.modeBar,
    child: ColoredBox(color: TomColors.of(context).surfaceSunken, child: child),
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
              'Reading '
              '${commit.sha.short} · '
              '${commit.author.name} · '
              '${whenInWords(commit.date)}',
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
          // Offered over a version too: comparing two commits is the same
          // question asked from the past (`docs/product/diff/branch-diff/doc.md`).
          const CompareControlWidget(),
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
            child: const Text('Back to now'),
          ),
          const SizedBox(width: TomMetrics.pad),
        ],
      ),
    );
  }
}

/// The gap between the buffer and the file, named where the editing happens.
///
/// Absent while the two agree, because a mark always there is never read.
class _UnsavedMarkWidget extends ConsumerWidget {
  const _UnsavedMarkWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ({bool isDirty, bool refused}) mark = ref.watch(
      editorProvider.select(
        (EditorState state) => (
          isDirty: state.isDirty,
          refused: state is EditorReady && state.saveFailure != null,
        ),
      ),
    );
    if (!mark.isDirty && !mark.refused) {
      return const SizedBox.shrink();
    }
    final TomColors colors = TomColors.of(context);
    // A refused save is different news from an unwritten edit: the first
    // needs doing something about.
    final Color colour = mark.refused ? colors.removed : colors.modified;
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
        // The word is what goes first when the row is short: the dot is the
        // mark and the status bar already says it in full.
        Flexible(
          child: Text(
            mark.refused ? 'Not saved' : 'Unsaved',
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
