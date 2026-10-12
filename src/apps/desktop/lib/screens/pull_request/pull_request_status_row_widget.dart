/// The pull request page's own chrome, in the row the tabs had.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/commands/commands_panel.dart';
import 'package:tom_desktop/screens/editor/editor_tabs_widget.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Whether the pull request can be opened and what stands in the way, in
/// the colour that state already has in the app
/// (`docs/product/git-workflow/pull-request/when-it-cannot-be-opened/doc.md`).
///
/// It carries an action only when the action can happen where it stands:
/// `Push`, never `Commit`, because committing is a column this page gave
/// away; and `Show the command` after a `Create pull request` that failed.
class PullRequestStatusRowWidget extends ConsumerWidget {
  /// Creates the row.
  const PullRequestStatusRowWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PullRequestStatus status = ref.watch(pullRequestStatusProvider);
    final bool pushing = ref.watch(
      remoteProvider.select((RemoteState state) => state.isBusy),
    );
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    final (Color ink, Color fill, TomGlyphEnum? glyph) = switch (status) {
      PullRequestReady() => (
        colors.added,
        colors.addedSoft,
        TomGlyphEnum.check,
      ),
      PullRequestUncommitted() => (
        colors.removed,
        colors.removedSoft,
        TomGlyphEnum.alert,
      ),
      PullRequestUnpublished() || PullRequestUntitled() => (
        colors.modified,
        colors.modifiedSoft,
        TomGlyphEnum.alert,
      ),
      // Nothing stands in the way and nothing is wrong: there is simply
      // nothing yet, so the row carries no glyph and no colour of its own.
      PullRequestEmpty() => (colors.textMuted, colors.surfaceSunken, null),
      PullRequestAlreadyOpen() => (
        colors.accent,
        colors.accentSoft,
        TomGlyphEnum.check,
      ),
      PullRequestReading() => (
        colors.textSecondary,
        colors.surfaceSunken,
        TomGlyphEnum.branch,
      ),
      PullRequestFailed() || PullRequestNotCreated() => (
        colors.removed,
        colors.removedSoft,
        TomGlyphEnum.alert,
      ),
    };
    // With the right column shut the row takes its action over, so the page
    // never keeps its only action where the window can hide it
    // (`git-workflow/pull-request/opening-it/doc.md`).
    final bool asideShut = !ref.watch(
      workspaceProvider.select((WorkspaceState it) => it.showingAside),
    );
    final String? host = ref.watch(
      pullRequestProvider.select(
        (PullRequestState state) => state.target?.project?.host.label,
      ),
    );
    final ({bool throughGh, bool creating}) gh = ref.watch(
      pullRequestProvider.select(
        (PullRequestState state) =>
            (throughGh: state.throughGh, creating: state.creating),
      ),
    );
    final String base =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.pullRequestBase?.value,
          ),
        ) ??
        '';
    final PullRequestNotifier notifier = ref.read(pullRequestProvider.notifier);
    return ColoredBox(
      color: fill,
      child: SizedBox(
        height: EditorTabsDesign.height,
        child: Row(
          children: <Widget>[
            const SizedBox(width: EditorTabsDesign.glyphLeft),
            if (glyph case final TomGlyphEnum it)
              TomGlyphWidget(
                glyph: it,
                color: ink,
                size: EditorTabsDesign.glyph,
              )
            else
              const SizedBox(width: EditorTabsDesign.glyph),
            const SizedBox(
              width:
                  PullRequestDesign.statusText -
                  EditorTabsDesign.glyphLeft -
                  EditorTabsDesign.glyph,
            ),
            Expanded(
              child: Text(
                sentenceOf(l10n, status, base: base, host: host ?? ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: EditorTabsDesign.label,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: ink,
                ),
              ),
            ),
            if (status is PullRequestUnpublished) ...<Widget>[
              const SizedBox(width: 12),
              _RowOutlinedWidget(
                label: pushing ? l10n.pullRequestPushing : l10n.commonPush,
                ink: ink,
                onPressed: pushing
                    ? null
                    : () => unawaited(ref.read(remoteProvider.notifier).push()),
              ),
              const SizedBox(width: EditorTabsDesign.right),
            ],
            if (status is PullRequestNotCreated) ...<Widget>[
              const SizedBox(width: 12),
              _RowOutlinedWidget(
                label: l10n.remoteShowTheCommand,
                ink: ink,
                onPressed: () => showTheCommand(ref),
              ),
              const SizedBox(width: EditorTabsDesign.right),
            ],
            if (asideShut &&
                host != null &&
                status is! PullRequestUnpublished &&
                status is! PullRequestNotCreated) ...<Widget>[
              const SizedBox(width: 12),
              _primary(context, notifier, status, host, gh),
              const SizedBox(width: EditorTabsDesign.right),
            ],
            const SizedBox(width: EditorTabsDesign.right),
          ],
        ),
      ),
    );
  }

  /// The column's first action, when the column is shut: the one already
  /// open, else `Create pull request` through `gh`, else the host's page.
  static Widget _primary(
    BuildContext context,
    PullRequestNotifier notifier,
    PullRequestStatus status,
    String host,
    ({bool throughGh, bool creating}) gh,
  ) {
    final AppLocalizations l10n = context.l10n;
    final bool canAct = status.canOpen && !gh.creating;
    return switch (status) {
      PullRequestAlreadyOpen(:final int number) => _RowFilledWidget(
        label: l10n.pullRequestView(number, host),
        onPressed: () => unawaited(notifier.viewOnHost()),
      ),
      _ when gh.throughGh => _RowFilledWidget(
        label: gh.creating ? l10n.pullRequestCreating : l10n.pullRequestCreate,
        onPressed: canAct ? () => unawaited(notifier.create()) : null,
      ),
      _ => _RowFilledWidget(
        label: l10n.pullRequestOpenOn(host),
        onPressed: canAct ? () => unawaited(notifier.openOnHost()) : null,
      ),
    };
  }

  /// Opens the commands panel on the `gh pr create` that failed, open onto
  /// what `gh` said — the reveal a git failure band uses
  /// (`docs/product/workspace/commands/doc.md`).
  static void showTheCommand(WidgetRef ref) {
    ref.read(workspaceProvider.notifier).showBottomPanel(CommandsPanel.id);
    ref
        .read(commandsProvider.notifier)
        .revealLastFailure(
          (CommandRecord it) =>
              it.executable == 'gh' && it.arguments.contains('create'),
        );
  }

  /// What the row says for [status], in the product's words: [base] is the
  /// branch proposed onto, [host] the host's own name.
  static String sentenceOf(
    AppLocalizations l10n,
    PullRequestStatus status, {
    String base = '',
    String host = '',
  }) => switch (status) {
    PullRequestReady(:final int commits) => l10n.pullRequestReady(commits),
    PullRequestUncommitted(:final int documents) => l10n.pullRequestUncommitted(
      documents,
    ),
    PullRequestUnpublished(:final int commits, hasUpstream: true) =>
      l10n.pullRequestUnpublished(commits),
    PullRequestUnpublished(hasUpstream: false) =>
      l10n.pullRequestUnpublishedBranch,
    PullRequestUntitled() => l10n.pullRequestUntitled,
    PullRequestEmpty() => l10n.pullRequestEmpty(base),
    PullRequestAlreadyOpen(:final int number) => l10n.pullRequestAlreadyOpen(
      number,
      host,
    ),
    PullRequestReading() => l10n.pullRequestReading,
    PullRequestFailed() => l10n.pullRequestFailed,
    PullRequestNotCreated(:final AppFailure failure) => switch (failure) {
      PullRequestHostUnreachable() => l10n.pullRequestNotCreatedUnreachable(
        host,
      ),
      PullRequestHostRefused() => l10n.pullRequestNotCreatedRefused(host),
      // A catch-all, because this switches over [AppFailure] itself.
      _ => l10n.pullRequestNotCreated(host),
    },
  };
}

/// The row's own outlined action, in the row's ink, 24 high.
class _RowOutlinedWidget extends StatelessWidget {
  const _RowOutlinedWidget({
    required this.label,
    required this.ink,
    required this.onPressed,
  });

  final String label;

  final Color ink;

  final VoidCallback? onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(ColorProperty('ink', ink))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 24,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        disabledForegroundColor: ink.withValues(alpha: 0.4),
        backgroundColor: TomColors.of(context).surfaceRaised,
        side: BorderSide(color: ink),
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(TomMetrics.radius)),
        ),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    ),
  );
}

/// The row's filled action, 24 high: the column's first, taken over.
class _RowFilledWidget extends StatelessWidget {
  const _RowFilledWidget({required this.label, required this.onPressed});

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
      height: 24,
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(TomMetrics.radius)),
          ),
          textStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
