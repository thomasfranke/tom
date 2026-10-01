/// Push, Fetch and Pull, at the foot of the column they act on.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The three remote actions, under the commit button, in the order the work
/// happens: stage, describe, commit, then publish.
///
/// **The top bar carries no git action** — a button that acts on the
/// repository belongs beside what it acts on — and there is no separate
/// drift indicator, because a number next to a button that already owns it
/// is the same fact twice
/// (`docs/product/git-workflow/push-pull/the-controls/doc.md`).
///
/// **`Pull` is a button of its own.** Keeping it only inside the rejection
/// meant the one way to catch up was to be refused first; the band still
/// offers it inline, which is the answer to what just happened rather than
/// the action available at any time.
class ChangesRemoteWidget extends ConsumerWidget {
  /// Creates the three.
  const ChangesRemoteWidget({super.key});

  /// What `Push` is wide: the column's content, edge to edge.
  static const double pushWidth = 248;

  /// What each of the two under it is wide.
  static const double halfWidth = 120;

  /// Their height.
  static const double height = 40;

  /// The gap between the two on the bottom row.
  static const double gap = 8;

  /// The commit line above to `Push`.
  static const double aboveGap = 14;

  /// `Push` to the row under it.
  static const double rowGap = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GitStatusValueObject? git = ref.watch(
      spaceSessionProvider.select((SpaceSessionState? session) => session?.git),
    );
    if (git == null) {
      // Nothing has read git yet: a button that cannot say what it would do
      // is worse than no button.
      return const SizedBox.shrink();
    }
    final RemoteState remote = ref.watch(remoteProvider);
    final RemoteNotifier notifier = ref.read(remoteProvider.notifier);
    return Column(
      children: <Widget>[
        const SizedBox(height: aboveGap),
        _ActionWidget(
          label: 'Push',
          // The verb and the number, with nothing between them; the arrow is
          // the glyph before it.
          count: git.ahead,
          glyph: TomGlyphEnum.push,
          action: RemoteActionEnum.push,
          remote: remote,
          width: pushWidth,
          isPrimary: true,
          // Nothing to publish is said by the button, not reported after.
          onPressed: git.ahead == 0
              ? null
              : () => unawaited(notifier.push()),
        ),
        const SizedBox(height: rowGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _ActionWidget(
              label: 'Fetch',
              // Never a count: it is the button somebody presses to find
              // out, and a number on it would answer its own question.
              glyph: TomGlyphEnum.fetch,
              action: RemoteActionEnum.fetch,
              remote: remote,
              width: halfWidth,
              onPressed: () => unawaited(notifier.fetch()),
            ),
            const SizedBox(width: gap),
            _ActionWidget(
              label: 'Pull',
              count: git.behind,
              glyph: TomGlyphEnum.pull,
              action: RemoteActionEnum.pull,
              remote: remote,
              width: halfWidth,
              onPressed: () => unawaited(notifier.pull()),
            ),
          ],
        ),
      ],
    );
  }
}

/// One of the three, unavailable while any of them is running.
class _ActionWidget extends StatelessWidget {
  const _ActionWidget({
    required this.label,
    required this.glyph,
    required this.action,
    required this.remote,
    required this.width,
    required this.onPressed,
    this.count = 0,
    this.isPrimary = false,
  });

  final String label;
  final TomGlyphEnum glyph;
  final RemoteActionEnum action;
  final RemoteState remote;
  final double width;
  final VoidCallback? onPressed;
  final int count;
  final bool isPrimary;

  /// The gap between the glyph and the words; the glyph itself is the
  /// set's own 16.
  static const double glyphGap = 10;

  /// What the words are drawn at.
  static const double labelSize = 13;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(EnumProperty<TomGlyphEnum>('glyph', glyph))
      ..add(EnumProperty<RemoteActionEnum>('action', action))
      ..add(DiagnosticsProperty<RemoteState>('remote', remote))
      ..add(DoubleProperty('width', width))
      ..add(IntProperty('count', count))
      ..add(DiagnosticsProperty<bool>('isPrimary', isPrimary))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final bool isThisOne =
        remote is RemoteWorking && (remote as RemoteWorking).action == action;
    // The pressed one names itself so nothing has to guess which of the
    // three is in flight; the other two only go dim.
    final String text = isThisOne
        ? '${_working[action]}…'
        : (count > 0 ? '$label ($count)' : label);
    final bool enabled = !remote.isBusy && onPressed != null;
    final Color ink = isPrimary && enabled
        ? colors.surfaceRaised
        : (enabled ? colors.textSecondary : colors.textMuted);
    return SizedBox(
      width: width,
      height: ChangesRemoteWidget.height,
      child: isPrimary
          ? FilledButton(
              onPressed: remote.isBusy ? null : onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.surfaceRaised,
                disabledBackgroundColor: colors.surfaceSunken,
                disabledForegroundColor: colors.textMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TomMetrics.radius),
                ),
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: _label(text, ink),
            )
          : OutlinedButton(
              onPressed: remote.isBusy ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textSecondary,
                disabledForegroundColor: colors.textMuted,
                side: BorderSide(
                  // A lighter edge when it cannot be pressed: the outline is
                  // the only thing a secondary button has to dim.
                  color: enabled ? colors.borderStrong : colors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TomMetrics.radius),
                ),
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: _label(text, ink),
            ),
    );
  }

  /// The glyph and the words, centred together rather than each on its own.
  ///
  /// The size is on the `Text` and not only on the button's `textStyle`:
  /// a style set through `styleFrom` does not reach a `Text` nested inside a
  /// `Row`, and the label came out large enough to overflow the board's 120.
  Widget _label(String text, Color ink) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      TomGlyphWidget(glyph: glyph, color: ink),
      const SizedBox(width: glyphGap),
      // Flexible so a label longer than the board's width shrinks the row
      // instead of throwing. It never happens in the app — but a widget test
      // has no vendored font, so every character measures its font size
      // square and `Pull (3)` comes out twice as wide as IBM Plex draws it.
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            color: ink,
          ),
        ),
      ),
    ],
  );

  /// What each says while it is the one running.
  static const Map<RemoteActionEnum, String> _working =
      <RemoteActionEnum, String>{
        RemoteActionEnum.fetch: 'Fetching',
        RemoteActionEnum.pull: 'Pulling',
        RemoteActionEnum.push: 'Pushing',
      };
}
