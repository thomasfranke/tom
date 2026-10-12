/// The foot of the pull request column: the way to open it, or to see it.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// One action, or two stacked 6 apart, at the board's 32
/// (`design/screens/desktop/git-pull-request/`, `Creating it through gh`).
///
/// Which ones is what `gh` answered for the branch
/// (`docs/product/git-workflow/pull-request/opening-it/doc.md`): one
/// already open is `View #n`; `gh` with an account is `Create pull request`
/// over `Open on <host> instead`; anything else is the host's page alone.
class PullRequestActionsWidget extends ConsumerWidget {
  /// Creates the foot for a project on [host].
  const PullRequestActionsWidget({required this.host, super.key});

  /// The host the project is on.
  final RemoteHostEnum host;

  /// Between the two actions.
  static const double gap = 6;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<RemoteHostEnum>('host', host));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PullRequestStatus status = ref.watch(pullRequestStatusProvider);
    final ({bool throughGh, int? opened, bool creating}) gh = ref.watch(
      pullRequestProvider.select(
        (PullRequestState state) => (
          throughGh: state.throughGh,
          opened: state.opened?.number,
          creating: state.creating,
        ),
      ),
    );
    final PullRequestNotifier notifier = ref.read(pullRequestProvider.notifier);
    final AppLocalizations l10n = context.l10n;
    final bool canAct = status.canOpen && !gh.creating;
    if (gh.opened case final int number) {
      return _FilledActionWidget(
        label: l10n.pullRequestView(number, host.label),
        onPressed: () => unawaited(notifier.viewOnHost()),
      );
    }
    if (!gh.throughGh) {
      return _FilledActionWidget(
        label: l10n.pullRequestOpenOn(host.label),
        glyph: TomGlyphEnum.link,
        onPressed: canAct ? () => unawaited(notifier.openOnHost()) : null,
      );
    }
    final Widget create = _FilledActionWidget(
      label: gh.creating ? l10n.pullRequestCreating : l10n.pullRequestCreate,
      onPressed: canAct ? () => unawaited(notifier.create()) : null,
    );
    // Nothing to propose: the one action, drawn and unavailable.
    if (status is PullRequestEmpty) {
      return create;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        create,
        const SizedBox(height: gap),
        _OutlinedActionWidget(
          label: l10n.pullRequestOpenOnInstead(host.label),
          onPressed: canAct ? () => unawaited(notifier.openOnHost()) : null,
        ),
      ],
    );
  }
}

/// The filled action: `accent`, its label in the island's colour, and
/// `control` with a muted label while it cannot act.
class _FilledActionWidget extends StatelessWidget {
  const _FilledActionWidget({
    required this.label,
    required this.onPressed,
    this.glyph,
  });

  final String label;

  /// Null while it cannot act.
  final VoidCallback? onPressed;

  final TomGlyphEnum? glyph;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed))
      ..add(EnumProperty<TomGlyphEnum?>('glyph', glyph));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final bool live = onPressed != null;
    return SizedBox(
      height: ChangesDesign.buttonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.surfaceRaised,
          disabledBackgroundColor: colors.control,
          disabledForegroundColor: colors.textMuted,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ChangesDesign.radius),
          ),
          textStyle: const TextStyle(
            fontSize: ChangesDesign.button,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (glyph case final TomGlyphEnum it) ...<Widget>[
              TomGlyphWidget(
                glyph: it,
                color: live ? colors.surfaceRaised : colors.textMuted,
                size: 11,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

/// The second action: outlined in `border_strong`, its label
/// `text_secondary`.
class _OutlinedActionWidget extends StatelessWidget {
  const _OutlinedActionWidget({required this.label, required this.onPressed});

  final String label;

  final VoidCallback? onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: ChangesDesign.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textSecondary,
          disabledForegroundColor: colors.textMuted,
          side: BorderSide(color: colors.borderStrong),
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ChangesDesign.radius),
          ),
          textStyle: const TextStyle(
            fontSize: ChangesDesign.button,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
