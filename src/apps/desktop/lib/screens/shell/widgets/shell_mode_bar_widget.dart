/// The bar above the document area: the three modes, and the unsaved mark.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/compare/compare_control_widget.dart';
import 'package:tom_desktop/screens/history/history_words.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Source · Split · Preview, and whether the buffer has reached the disk.
///
/// Chrome, not a panel: it decides which panels the document region draws
/// and still names none, because what it writes is the mode and the
/// descriptor says which panels that includes.
class ShellModeBarWidget extends ConsumerWidget {
  /// Creates the bar.
  const ShellModeBarWidget({super.key});

  /// Left edge to the first tab, and the gap between two of them.
  ///
  /// A gap rather than the wireframe's pitch of 80, which is this plus a
  /// word: a fixed column would clip the longest label when the font changes.
  static const double _inset = 28;
  static const double _gap = 32;

  /// The rule under the current tab, as wide as its label.
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
          const CompareControlWidget(),
          const SizedBox(width: _gap),
          const _UnsavedMarkWidget(),
          const SizedBox(width: TomMetrics.pad),
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
            // The rule and the weight say the same thing: colour is never the
            // only signal.
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
