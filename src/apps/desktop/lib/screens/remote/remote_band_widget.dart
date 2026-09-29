/// What the remote answered, said above the document.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The band that carries news from the remote, and nothing while there is
/// none (`docs/product/git-workflow/push-pull/when-it-fails/doc.md`).
///
/// A pull in flight is drawn here because **Pull is not a fourth button** —
/// it lives inside the refusal, so this band is the control that was pressed
/// and the one that has to say it is working.
class RemoteBandWidget extends ConsumerWidget {
  /// Creates the band.
  const RemoteBandWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RemoteState remote = ref.watch(remoteProvider);
    final TomColors colors = TomColors.of(context);
    final int behind =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.git?.behind,
          ),
        ) ??
        0;
    return switch (remote) {
      RemoteWorking(action: RemoteActionEnum.pull) => NoticeBandWidget(
        sentence: 'Pulling what the remote has…',
        ink: colors.modified,
        fill: colors.modifiedSoft,
        raised: colors.surfaceRaised,
      ),
      // Fetch and push say they are working on the button that was pressed.
      RemoteIdle() || RemoteWorking() => const SizedBox.shrink(),
      RemoteRejected() => NoticeBandWidget(
        sentence: _rejection(behind),
        ink: colors.modified,
        fill: colors.modifiedSoft,
        raised: colors.surfaceRaised,
        action: 'Pull',
        onAction: () => unawaited(ref.read(remoteProvider.notifier).pull()),
      ),
      RemoteFailed(
        action: final RemoteActionEnum action,
        failure: final AppFailure failure,
      ) =>
        NoticeBandWidget(
          sentence: _explain(failure, action),
          // A conflict is `modified` rather than `removed`: nothing failed,
          // and there is something to do about it — the same reading the
          // refusal above gets.
          ink: failure is GitMergeConflict ? colors.modified : colors.removed,
          fill: failure is GitMergeConflict
              ? colors.modifiedSoft
              : colors.removedSoft,
          raised: colors.surfaceRaised,
          action: _canRetry(failure) ? 'Try again' : null,
          onAction: _canRetry(failure)
              ? () => unawaited(_retry(ref, action))
              : null,
        ),
    };
  }

  /// Who got there first, what to do, and that nothing is lost — the three
  /// the product asks for, in the board's own words.
  ///
  /// Counted only when known, because a fetch may not have happened yet.
  static String _rejection(int behind) =>
      '${behind > 0 ? 'Someone pushed $behind commit${behind == 1 ? '' : 's'} '
                'first.' : 'Someone pushed first.'} '
      'Pull them, then push again — nothing you committed has been lost.';

  /// What went wrong, and what it cost.
  ///
  /// A catch-all, because this switches over [AppFailure] itself and the band
  /// must say something whatever the remote did.
  static String _explain(AppFailure failure, RemoteActionEnum action) =>
      switch (failure) {
        GitNotInstalled() => 'TOM could not find git on this machine.',
        GitNotARepository() => 'That folder is not inside a Git repository.',
        GitAuthenticationFailed() =>
          'The remote would not accept this machine. ${_cost(action)}',
        // The remote is never named: which one git used is not on the session,
        // and guessing "origin" would be guessing.
        GitTimedOut() => 'git could not reach the remote. ${_cost(action)}',
        GitMergeConflict(conflictedFiles: final List<String> files) =>
          'The pull stopped: ${files.length} '
              'document${files.length == 1 ? '' : 's'} conflict.',
        // What was refused, never why: git may have reached the remote
        // perfectly and refused for a reason this product cannot yet name.
        _ => 'Git refused the ${action.name}. ${_cost(action)}',
      };

  /// What the failed action did not manage to do.
  static String _cost(RemoteActionEnum action) => switch (action) {
    RemoteActionEnum.fetch => 'Nothing arrived.',
    RemoteActionEnum.pull => 'Nothing changed here.',
    RemoteActionEnum.push =>
      'Nothing was published, and nothing you committed has been lost.',
  };

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
