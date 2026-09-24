/// The bar above the document area: the three modes, and the unsaved mark.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/history/history_words.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Source · Split · Preview, and whether the buffer has reached the disk.
///
/// **Chrome, not a panel.** It decides which panels the document region
/// draws, so it cannot be one of them — and it still names none of them:
/// what it writes is the mode, and a descriptor is what says which panels
/// that mode includes.
///
/// Tabs with a rule under the current one rather than a segmented control:
/// the wireframe draws them that way, and a filled control here would
/// compete with the document for the eye.
class ShellModeBarWidget extends ConsumerWidget {
  /// Creates the bar.
  const ShellModeBarWidget({super.key});

  /// Left edge to the first tab, and the gap between two of them.
  ///
  /// A gap rather than the wireframe's pitch: a fixed column would clip the
  /// longest label the day the interface font changes, and the drawing's
  /// 80 is that gap plus a word.
  static const double _inset = 28;
  static const double _gap = 32;

  /// The rule under the current tab, which is as wide as its label.
  static const double _ruleHeight = 2;

  /// Label to rule.
  static const double _ruleGap = 5;

  /// The dot that says the buffer and the file disagree.
  static const double _dot = 8;

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
    final DocumentModeEnum mode =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.mode,
          ),
        ) ??
        DocumentModeEnum.split;
    return SizedBox(
      height: TomMetrics.modeBar,
      child: Row(
        children: <Widget>[
          const SizedBox(width: _inset),
          for (final DocumentModeEnum each in DocumentModeEnum.values)
            Padding(
              padding: const EdgeInsets.only(right: _gap),
              child: _ModeTabWidget(mode: each, isCurrent: each == mode),
            ),
          const Spacer(),
          const _UnsavedMarkWidget(),
          const SizedBox(width: TomMetrics.pad),
        ],
      ),
    );
  }
}

/// The bar while a past version is on screen, instead of the three modes.
///
/// **It replaces them rather than joining them**: the modes choose between
/// source and preview, and there is no source for a commit — you cannot
/// type into the past. What the bar owes instead is which version this is
/// and the way back, which is the one control here
/// (`docs/product/git-workflow/file-history/doc.md`).
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

/// One mode, as a tab.
class _ModeTabWidget extends ConsumerWidget {
  const _ModeTabWidget({required this.mode, required this.isCurrent});

  final DocumentModeEnum mode;
  final bool isCurrent;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<DocumentModeEnum>('mode', mode))
      ..add(DiagnosticsProperty<bool>('isCurrent', isCurrent));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return InkWell(
      onTap: () => ref.read(spaceSessionProvider.notifier).look(mode),
      // The tab is exactly its label wide, so the rule under it is too.
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _labels[mode]!,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isCurrent ? colors.textPrimary : colors.textMuted,
              ),
            ),
            const SizedBox(height: ShellModeBarWidget._ruleGap),
            // The rule is the state, and the weight above it says the same
            // thing a second way — colour is never the only signal.
            SizedBox(
              height: ShellModeBarWidget._ruleHeight,
              child: isCurrent ? ColoredBox(color: colors.accent) : null,
            ),
          ],
        ),
      ),
    );
  }

  /// What each mode is called on screen.
  static const Map<DocumentModeEnum, String> _labels =
      <DocumentModeEnum, String>{
        DocumentModeEnum.source: 'Source',
        DocumentModeEnum.split: 'Split',
        DocumentModeEnum.preview: 'Preview',
      };
}

/// The gap between the buffer and the file, named where the editing happens.
///
/// Absent while the two agree: a mark that is always there is a mark nobody
/// reads. The tree and the status bar say the same thing in their own words
/// — three places, because the one thing a text editor may never do is lose
/// work quietly.
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
    // A refused save is not the same news as an unwritten edit: the first
    // needs doing something about, the second only needs the shortcut the
    // status bar spells out.
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
