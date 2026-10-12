/// What the remote answered, said above the document.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/commands/commands_panel.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The band that carries news from the remote, and nothing while there is
/// none (`docs/product/git-workflow/push-pull/when-it-fails/doc.md`).
///
/// **A merge in progress outranks everything else the band could say.** It is
/// a state of the repository rather than news from a press, so it survives
/// the window being closed — which is what keeps the `C` marks in the tree
/// from standing there with nothing explaining them
/// (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
class RemoteBandWidget extends ConsumerWidget {
  /// Creates the band.
  const RemoteBandWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RemoteState remote = ref.watch(remoteProvider);
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    final int behind =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.git?.behind,
          ),
        ) ??
        0;
    final int ahead =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.git?.ahead,
          ),
        ) ??
        0;
    final String upstream =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.git?.upstream?.value,
          ),
        ) ??
        l10n.remoteTheRemote;
    // A branch that tracks nothing has nothing to be ahead of, yet `Push`
    // publishes it — unless the repository has no remote to publish to.
    final bool isUntracked =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) =>
                session?.git != null && session!.git!.upstream == null,
          ),
        ) &&
        ref.watch(remoteLinkProvider) != LinkStateEnum.noRemote;
    final int conflicted = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) =>
            session?.isResolvingMerge ?? false ? session!.toResolve.length : 0,
      ),
    );
    // Before the remote state, because a conflict found on open was left by a
    // pull nobody in this session made.
    if (conflicted > 0) {
      return NoticeBandWidget(
        sentence: l10n.remoteStopped(conflicted),
        // `modified` rather than `removed`: nothing failed, and there is
        // something to do about it.
        ink: colors.modified,
        fill: colors.modifiedSoft,
        // The band's one action while a merge is open. Resolving is done in
        // the document, not from here, so undoing is all this offers.
        action: l10n.remoteAbortThePull,
        onAction: () => unawaited(_confirmAbort(context, ref)),
      );
    }
    return switch (remote) {
      // A commit that worked quotes its message and offers `Push` while
      // there is something to publish
      // (`git-workflow/commit/confirming/doc.md`).
      RemoteIdle(committed: final String message) => NoticeBandWidget(
        sentence: ahead > 0
            ? l10n.remoteCommittedWaiting(message, ahead)
            : l10n.remoteCommitted(message),
        ink: colors.added,
        fill: colors.addedSoft,
        action: ahead > 0 || isUntracked ? l10n.commonPush : null,
        onAction: ahead > 0 || isUntracked
            ? () => unawaited(ref.read(remoteProvider.notifier).push())
            : null,
      ),
      // A push that landed says so and offers nothing: a button returning to
      // `Push` looks exactly like a push that never left.
      RemoteIdle(published: final int count) when count >= 0 =>
        NoticeBandWidget(
          sentence: count > 0
              ? l10n.remotePublished(count, upstream)
              : l10n.remotePublishedBranch(upstream),
          ink: colors.added,
          fill: colors.addedSoft,
        ),
      // A pull that worked says how many arrived, and offers Push only while
      // something of this branch is still to publish
      // (`git-workflow/push-pull/when-it-works/doc.md`).
      RemoteIdle(arrived: final int arrived) => NoticeBandWidget(
        sentence: _arrived(l10n, arrived, ahead, upstream),
        ink: colors.added,
        fill: colors.addedSoft,
        action: arrived > 0 && ahead > 0 ? l10n.commonPush : null,
        onAction: arrived > 0 && ahead > 0
            ? () => unawaited(ref.read(remoteProvider.notifier).push())
            : null,
      ),
      // A request in flight says so on the button that was pressed and in the
      // bar over the column; a band is news from one that ended.
      RemoteIdle() || RemoteWorking() => const SizedBox.shrink(),
      RemoteRejected() => NoticeBandWidget(
        // Counted only when known, because a fetch may not have happened yet.
        sentence: behind > 0
            ? l10n.remoteRejected(behind)
            : l10n.remoteRejectedUncounted,
        ink: colors.modified,
        fill: colors.modifiedSoft,
        action: l10n.commonPull,
        onAction: () => unawaited(ref.read(remoteProvider.notifier).pull()),
        alternative: l10n.remoteShowTheCommand,
        onAlternative: () => _showTheCommand(ref, RemoteActionEnum.push),
      ),
      // A protected branch has no `Try again`, which would answer the same
      // for ever: the way in is a pull request, offered while one can be
      // opened (`git-workflow/push-pull/when-it-fails/doc.md`).
      RemoteFailed(failure: GitBranchProtected()) => _protected(
        context,
        ref,
        l10n,
        colors,
        git: ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.git,
          ),
        ),
      ),
      RemoteFailed(
        action: final RemoteActionEnum action,
        failure: final AppFailure failure,
      ) =>
        NoticeBandWidget(
          sentence: _explain(l10n, failure, action),
          // A conflict, or a pull held back by uncommitted work, is
          // `modified` rather than `removed`: nothing failed, and there is
          // something to do about it — the same reading the refusal above
          // gets.
          ink: _isSituation(failure) ? colors.modified : colors.removed,
          fill: _isSituation(failure)
              ? colors.modifiedSoft
              : colors.removedSoft,
          action: _canRetry(failure) ? l10n.remoteTryAgain : null,
          onAction: _canRetry(failure)
              ? () => unawaited(_retry(ref, action))
              : null,
          alternative: l10n.remoteShowTheCommand,
          onAlternative: () => _showTheCommand(ref, action),
        ),
    };
  }

  /// The refusal of a branch the remote protects.
  static Widget _protected(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    TomColors colors, {
    required GitStatusValueObject? git,
  }) {
    final bool canOpen =
        ref.watch(pullRequestProvider).availability(git) ==
        PullRequestAvailabilityEnum.available;
    return NoticeBandWidget(
      sentence: l10n.remoteBranchProtected,
      ink: colors.modified,
      fill: colors.modifiedSoft,
      action: canOpen ? l10n.panelPullRequest : null,
      onAction: canOpen
          ? () => ref.read(pullRequestProvider.notifier).open()
          : null,
      alternative: l10n.remoteShowTheCommand,
      onAlternative: () => _showTheCommand(ref, RemoteActionEnum.push),
    );
  }

  /// Opens the commands panel on the `git <action>` that failed, open onto
  /// what git said — the one way the panel opens without being asked for
  /// directly (`docs/product/workspace/commands/doc.md`).
  ///
  /// By its verb, because the re-read after it runs commands whose ordinary
  /// answer is a failure.
  static void _showTheCommand(WidgetRef ref, RemoteActionEnum action) {
    ref.read(workspaceProvider.notifier).showBottomPanel(CommandsPanel.id);
    ref
        .read(commandsProvider.notifier)
        .revealLastFailure(
          (CommandRecord it) => it.arguments.contains(action.name),
        );
  }

  /// Asks before undoing, and says what the undo costs.
  ///
  /// The safe answer is the filled one and the destructive answer carries
  /// `removed`: a press that cannot be taken back is never the one that
  /// needs no thought
  /// (`design/screens/desktop/git-conflict/aborting-the-pull-light.svg`).
  static Future<void> _confirmAbort(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = context.l10n;
    final bool? abort = await TomDialogWidget.show<bool>(
      context,
      title: l10n.remoteAbortQuestion,
      body: <String>[l10n.remoteAbortGoesBack, l10n.remoteAbortStaysFetched],
      actions: (void Function(bool) answer) => <TomDialogAction>[
        TomDialogAction(
          label: l10n.remoteKeepTheConflict,
          onPressed: () => answer(false),
        ),
        TomDialogAction(
          label: l10n.remoteAbortThePull,
          onPressed: () => answer(true),
          destructive: true,
        ),
      ],
    );
    // Dismissed without choosing is *do nothing*, never a default.
    if (abort ?? false) {
      await ref.read(remoteProvider.notifier).abort();
    }
  }

  /// What a pull that worked brought, and what of this branch is left to
  /// publish — the boards' own sentences.
  static String _arrived(
    AppLocalizations l10n,
    int arrived,
    int ahead,
    String upstream,
  ) {
    if (arrived == 0) {
      return l10n.remoteAlreadyLevel(upstream);
    }
    final String pulled = l10n.remotePulled(arrived, upstream);
    return ahead == 0 ? pulled : '$pulled ${l10n.remoteStillToPublish(ahead)}';
  }

  /// What went wrong, and what it cost.
  ///
  /// A catch-all, because this switches over [AppFailure] itself and the band
  /// must say something whatever the remote did.
  static String _explain(
    AppLocalizations l10n,
    AppFailure failure,
    RemoteActionEnum action,
  ) => switch (failure) {
    GitNotInstalled() => l10n.gitNotInstalled,
    GitNotARepository() => l10n.gitNotARepository,
    GitAuthenticationFailed() =>
      '${l10n.remoteNotAccepted} ${_cost(l10n, action)}',
    // The remote is never named: which one git used is not on the session,
    // and guessing "origin" would be guessing.
    GitTimedOut() => '${l10n.remoteCouldNotReach} ${_cost(l10n, action)}',
    GitMergeConflict(conflictedFiles: final List<String> files) =>
      l10n.remoteStoppedShort(files.length),
    // Named when it is one, counted when it is more: the band is one line.
    GitLocalChangesOverwritten(paths: final List<String> paths) =>
      switch (paths) {
        [] => l10n.remoteWouldOverwriteUncounted,
        [final String only] => l10n.remoteWouldOverwriteOne(only),
        _ => l10n.remoteWouldOverwriteMany(paths.length),
      },
    // What was refused, never why: git may have reached the remote
    // perfectly and refused for a reason this product cannot yet name.
    _ => '${_refused(l10n, action)} ${_cost(l10n, action)}',
  };

  /// That git refused [action], naming the verb.
  static String _refused(AppLocalizations l10n, RemoteActionEnum action) =>
      switch (action) {
        RemoteActionEnum.fetch => l10n.remoteRefusedFetch,
        RemoteActionEnum.pull => l10n.remoteRefusedPull,
        RemoteActionEnum.push => l10n.remoteRefusedPush,
      };

  /// What the failed action did not manage to do.
  static String _cost(AppLocalizations l10n, RemoteActionEnum action) =>
      switch (action) {
        RemoteActionEnum.fetch => l10n.remoteCostFetch,
        RemoteActionEnum.pull => l10n.remoteCostPull,
        RemoteActionEnum.push => l10n.remoteCostPush,
      };

  /// Whether [failure] is a state of the work to act on rather than a fault.
  static bool _isSituation(AppFailure failure) =>
      failure is GitMergeConflict || failure is GitLocalChangesOverwritten;

  /// Whether trying the same thing again could answer differently.
  ///
  /// A missing binary and a folder outside a repository will answer the same
  /// way forever, and a conflict is a state to resolve rather than retry —
  /// offering the button would be offering nothing.
  static bool _canRetry(AppFailure failure) => switch (failure) {
    GitNotInstalled() || GitNotARepository() || GitMergeConflict() => false,
    _ => true,
  };

  /// Runs the failed action once more.
  static Future<void> _retry(WidgetRef ref, RemoteActionEnum action) {
    final RemoteNotifier notifier = ref.read(remoteProvider.notifier);
    return switch (action) {
      RemoteActionEnum.fetch => notifier.fetch(),
      RemoteActionEnum.pull => notifier.pull(),
      RemoteActionEnum.push => notifier.push(),
    };
  }
}
