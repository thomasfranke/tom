/// Push, Fetch and Pull, at the foot of the column they act on.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_count_widget.dart';
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
/// **`Pull` is a button of its own**, since keeping it only inside the
/// rejection meant the one way to catch up was to be refused first.
class ChangesRemoteWidget extends ConsumerWidget {
  /// Creates the three.
  const ChangesRemoteWidget({super.key});

  /// Their height.
  static const double height = 30;

  /// The gap between the two on the bottom row.
  static const double gap = 8;

  /// The commit line above to `Push`.
  static const double aboveGap = 10;

  /// `Push` to the row under it.
  static const double rowGap = 8;

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
    // What the last request said about the link: the line under the buttons,
    // and whether they stay live (`push-pull/when-the-link-is-broken/doc.md`).
    final LinkStateEnum? link = remote.link;
    final bool isReachable = link?.isPressable ?? true;
    // Ahead is counted against a remote, so with none the number goes.
    final int ahead = link == LinkStateEnum.noRemote ? 0 : git.ahead;
    final AppLocalizations l10n = context.l10n;
    // The column's own inset, as the message and the commit button have it:
    // the buttons fill what is inside it, whatever width it was dragged to.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ChangesDesign.inset),
      child: Column(
        children: <Widget>[
          const SizedBox(height: aboveGap),
          _ActionWidget(
            label: l10n.commonPush,
            // The verb and the number, with nothing between them; the arrow is
            // the glyph before it.
            count: ahead,
            glyph: TomGlyphEnum.push,
            action: RemoteActionEnum.push,
            remote: remote,
            // The column's content, edge to edge — 248 at the width the
            // column opens at, which is what the boards draw.
            width: double.infinity,
            isPrimary: true,
            // Nothing to publish is said by the button, not reported after.
            onPressed: ahead == 0 || !isReachable
                ? null
                : () => unawaited(notifier.push()),
          ),
          const SizedBox(height: rowGap),
          // Half each, less the gap: 120 at the width the column opens at.
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionWidget(
                  label: l10n.commonFetch,
                  // Never a count: it is the button somebody presses to find
                  // out, and a number on it would answer its own question.
                  glyph: TomGlyphEnum.fetch,
                  action: RemoteActionEnum.fetch,
                  remote: remote,
                  width: double.infinity,
                  onPressed: isReachable
                      ? () => unawaited(notifier.fetch())
                      : null,
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _ActionWidget(
                  label: l10n.commonPull,
                  count: git.behind,
                  glyph: TomGlyphEnum.pull,
                  action: RemoteActionEnum.pull,
                  remote: remote,
                  width: double.infinity,
                  onPressed: isReachable
                      ? () => unawaited(notifier.pull())
                      : null,
                ),
              ),
            ],
          ),
          if (link != null)
            _LinkLineWidget(link: link)
          else if (standing(l10n, git) case final String sentence)
            _StandingLineWidget(sentence: sentence),
        ],
      ),
    );
  }

  /// Where the branch stands against its upstream, or null when it tracks
  /// nothing — there is nothing to stand against
  /// (`push-pull/when-the-link-is-broken/doc.md`).
  static String? standing(AppLocalizations l10n, GitStatusValueObject git) {
    final BranchNameValueObject? upstream = git.upstream;
    if (upstream == null) {
      return null;
    }
    final String name = upstream.value;
    return switch ((git.ahead, git.behind)) {
      (0, 0) => l10n.changesUpToDate(name),
      (0, final int behind) => l10n.changesBehind(behind, name),
      (final int ahead, 0) => l10n.changesAhead(ahead, name),
      (final int ahead, final int behind) => l10n.changesAheadAndBehind(
        ahead,
        behind,
        name,
      ),
    };
  }
}

/// Where a healthy link leaves the branch: the broken line's slot and type,
/// without its glyph and in `text_muted`, because nothing needs attention.
class _StandingLineWidget extends StatelessWidget {
  const _StandingLineWidget({required this.sentence});

  final String sentence;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('sentence', sentence));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: _LinkLineWidget.top),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        sentence,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: _LinkLineWidget.text,
          height: 1.4,
          color: TomColors.of(context).textMuted,
        ),
      ),
    ),
  );
}

/// What the connection is, under the three — a glyph and the words, never
/// colour alone, in `modified` because it needs attention rather than
/// reports a press that failed.
class _LinkLineWidget extends StatelessWidget {
  const _LinkLineWidget({required this.link});

  final LinkStateEnum link;

  /// The buttons to the line's glyph
  /// (`design/screens/desktop/git-connection/no-network-dark.svg`).
  static const double top = 15;

  /// The glyph, and the gap after it to the words.
  static const double glyph = 12;
  static const double glyphGap = 6;

  /// The words.
  static const double text = 11;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<LinkStateEnum>('link', link));
  }

  /// What the link is, in the window's language.
  String _sentenceOf(AppLocalizations l10n) => switch (link) {
    LinkStateEnum.noNetwork => l10n.changesLinkNoNetwork,
    LinkStateEnum.credentialsRefused => l10n.changesLinkCredentialsRefused,
    LinkStateEnum.noRemote => l10n.changesLinkNoRemote,
    LinkStateEnum.timedOut => l10n.changesLinkTimedOut,
  };

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: top),
      child: Row(
        children: <Widget>[
          TomGlyphWidget(
            glyph: TomGlyphEnum.alert,
            color: colors.modified,
            size: glyph,
          ),
          const SizedBox(width: glyphGap),
          Expanded(
            child: Text(
              _sentenceOf(context.l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: text,
                height: 1.4,
                color: colors.modified,
              ),
            ),
          ),
        ],
      ),
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

  /// The gap between the glyph and the words.
  static const double glyphGap = 7;

  /// The glyph.
  static const double glyphSize = 11;

  /// What the words are drawn at: `Push` a half point over the other two.
  double get _labelSize => isPrimary ? 12.5 : 12;

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
    final String text = isThisOne ? _working(context.l10n) : label;
    final bool enabled = !remote.isBusy && onPressed != null;
    final Color ink = enabled
        ? (isPrimary ? colors.textPrimary : colors.textSecondary)
        : colors.textMuted;
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ChangesDesign.radius),
    );
    // `Push` is filled with the control role and the other two outlined:
    // on a 1b board the accent belongs to the commit alone, so publishing
    // is one step quieter than committing.
    return SizedBox(
      key: ValueKey<RemoteActionEnum>(action),
      width: width,
      height: ChangesRemoteWidget.height,
      child: isPrimary
          ? FilledButton(
              onPressed: remote.isBusy ? null : onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: colors.control,
                foregroundColor: colors.textPrimary,
                disabledBackgroundColor: colors.surfaceSunken,
                disabledForegroundColor: colors.textMuted,
                shape: shape,
                padding: EdgeInsets.zero,
              ),
              child: _label(text, ink, colors, showsCount: !isThisOne),
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
                shape: shape,
                padding: EdgeInsets.zero,
              ),
              child: _label(text, ink, colors, showsCount: !isThisOne),
            ),
    );
  }

  /// The glyph, the words and the count, centred together rather than each
  /// on its own.
  ///
  /// The size is on the `Text` and not only on the button's `textStyle`:
  /// a style set through `styleFrom` does not reach a `Text` nested inside a
  /// `Row`.
  Widget _label(
    String text,
    Color ink,
    TomColors colors, {
    required bool showsCount,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      TomGlyphWidget(glyph: glyph, color: ink, size: glyphSize),
      const SizedBox(width: glyphGap),
      // Flexible so a label longer than the button shrinks the row instead
      // of throwing — a widget test has no vendored font, and every
      // character measures its font size square there.
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontSize: _labelSize,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            color: ink,
          ),
        ),
      ),
      // The count is a badge after the verb, not a number in brackets: a
      // 1b board reads it the way it reads the git tab's own count.
      if (showsCount && count > 0) ...<Widget>[
        const SizedBox(width: 5),
        ChangesCountWidget(count: count),
      ],
    ],
  );

  /// What this one says while it is the one running.
  String _working(AppLocalizations l10n) => switch (action) {
    RemoteActionEnum.fetch => l10n.changesFetching,
    RemoteActionEnum.pull => l10n.changesPulling,
    RemoteActionEnum.push => l10n.changesPushing,
  };
}
