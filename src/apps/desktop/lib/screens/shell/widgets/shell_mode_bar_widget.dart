/// The bar above the document area: the three modes, and the unsaved mark.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/compare/compare_control_widget.dart';
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
  /// Handed in because the control is centred on the **window**, not on this
  /// bar: it must not move when a column opens
  /// (`docs/product/workspace/columns/doc.md`).
  final double leftInset;

  /// How wide the column to the right is, or 0 when it is closed.
  final double rightInset;

  /// Left edge to the first thing in the bar, and the gap between two of them.
  static const double _inset = 28;
  static const double _gap = 32;

  /// The dot that says the buffer and the file disagree.
  static const double _dot = 8;

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
    // Where the window's centre falls inside this bar, which is what the
    // control is centred on.
    final double centre = MediaQuery.sizeOf(context).width / 2 - leftInset;
    // What is left of the bar to the right of that control. Without it the
    // group at the right grows leftwards into the modes and draws over them:
    // a long branch name is longer than the room there happens to be.
    final double room =
        MediaQuery.sizeOf(context).width -
        leftInset -
        rightInset -
        (centre + ShellModeControlWidget.trackWidth / 2) -
        TomMetrics.pad -
        _gap;
    return SizedBox(
      height: TomMetrics.modeBar,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: centre - ShellModeControlWidget.trackWidth / 2,
            top: 0,
            bottom: 0,
            child: const Center(child: ShellModeControlWidget()),
          ),
          Positioned(
            right: TomMetrics.pad,
            top: 0,
            bottom: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: room > 0 ? room : 0),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(child: CompareControlWidget()),
                  SizedBox(width: _gap),
                  _UnsavedMarkWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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
    return SizedBox(
      height: TomMetrics.modeBar,
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
        Text(
          mark.refused ? 'Not saved' : 'Unsaved',
          style: TextStyle(fontSize: 13, height: 1.4, color: colour),
        ),
      ],
    );
  }
}
