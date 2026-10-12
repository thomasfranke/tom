/// The git column: what differs, what is going in, and the commit.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_commit_button_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_message_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_note_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_remote_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_row_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_section_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Stage, describe, commit.
///
/// The list is the repository's, not the space's, because a commit records
/// the index (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
/// What git said
/// lives in the session, which the status bar reads too; the draft lives in
/// [ChangesNotifier] because nobody else does.
class ChangesPanel extends ConsumerWidget {
  /// Creates the panel.
  const ChangesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChangesState state = ref.watch(changesProvider);
    final GitStatusValueObject? status = ref.watch(
      spaceSessionProvider.select((SpaceSessionState? session) => session?.git),
    );
    final bool isBusy = state is ChangesReady && state.isBusy;
    final List<StatusEntryValueObject> entries =
        status?.entries ?? const <StatusEntryValueObject>[];
    final int staged = entries
        .where((StatusEntryValueObject it) => it.isStaged)
        .length;
    // A merge still holding conflicts is the one thing that takes the commit
    // away: concluding it is a commit, and it cannot be made while a document
    // still holds a marker
    // (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
    final int toResolve = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) =>
            session?.isResolvingMerge ?? false ? session!.toResolve.length : 0,
      ),
    );
    final AppLocalizations l10n = context.l10n;
    final bool isAwaitingApproval = ref.watch(
      commandsProvider.select(
        (CommandsState it) => it.isWaitingOn(CommandActionEnum.readRepository),
      ),
    );
    final bool isDetached = status?.isDetached ?? false;
    final bool canCommit =
        !isBusy &&
        !isDetached &&
        toResolve == 0 &&
        state is ChangesReady &&
        state.message.trim().isNotEmpty &&
        (status?.hasStagedChanges ?? false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: _body(
            l10n,
            ref,
            state,
            entries,
            isBusy: isBusy,
            isAwaitingApproval: isAwaitingApproval,
          ),
        ),
        // Above the box rather than in place of the list, so a refusal is
        // said while what it refused is still on screen.
        if (state case ChangesReady(failure: final AppFailure refused))
          Padding(
            padding: const EdgeInsets.only(top: ChangesDesign.stackGap),
            child: ChangesNoteWidget(
              _explain(l10n, refused),
              isRefusal: refused is GitConflictMarkersPresent,
            ),
          )
        // The app's own policy, said before anything is pressed: the branch
        // is already on the session, so the refusal costs no round trip
        // (`docs/product/git-workflow/commit/the-message/doc.md`).
        else if (isDetached)
          Padding(
            padding: const EdgeInsets.only(top: ChangesDesign.stackGap),
            child: ChangesNoteWidget(l10n.changesNotOnABranch),
          ),
        // Never taken away, not even by a refused push: the refusal is a band
        // above the document and this column keeps working
        // (`docs/product/git-workflow/push-pull/when-it-fails/doc.md`).
        const SizedBox(height: ChangesDesign.stackGap),
        // ⌘Enter commits when the button would (`the-message/doc.md`).
        ChangesMessageWidget(
          onCommit: canCommit
              ? () => unawaited(ref.read(changesProvider.notifier).commit())
              : null,
        ),
        const SizedBox(height: ChangesDesign.stackGap),
        ChangesCommitButtonWidget(
          canCommit: canCommit,
          branch: isDetached ? null : status?.branch,
        ),
        // Under the button rather than on it: what is going in is a fact
        // about the list above, and the button says what it does. Absent
        // with nothing changed, because `0 of 0` is a line read twice and
        // ignored (`design/screens/desktop/git-commit/committing-dark.svg`).
        if (entries.isNotEmpty) ...<Widget>[
          const SizedBox(height: ChangesDesign.buttonToStaged),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ChangesDesign.inset,
            ),
            child: Text(
              // What is left to resolve takes the line while a merge is
              // unfinished: the staged count answers a question nobody is
              // asking yet
              // (`design/screens/desktop/git-conflict/conflict-in-source-light.svg`).
              toResolve > 0
                  ? l10n.changesToResolve(toResolve)
                  : l10n.changesStagedOf(staged, entries.length),
              style: TextStyle(
                fontSize: ChangesDesign.staged,
                height: 1.4,
                color: TomColors.of(context).textMuted,
              ),
            ),
          ),
        ],
        // Under the commit, in the order the work happens: stage, describe,
        // commit, then publish
        // (`docs/product/git-workflow/push-pull/the-controls/doc.md`).
        const ChangesRemoteWidget(),
        const SizedBox(height: ChangesDesign.inset),
      ],
    );
  }

  /// The list, or the sentence that stands in for it.
  static Widget _body(
    AppLocalizations l10n,
    WidgetRef ref,
    ChangesState state,
    List<StatusEntryValueObject> entries, {
    required bool isBusy,
    required bool isAwaitingApproval,
  }) => switch (state) {
    ChangesInitial() => ChangesNoteWidget(l10n.commonNoSpaceOpen),
    // A read that waits for a yes is not git being slow: the sentence says
    // whose turn it is.
    ChangesLoading() when isAwaitingApproval => ChangesNoteWidget(
      l10n.commonWaitingForApproval,
      isWaiting: true,
    ),
    ChangesLoading() => ChangesNoteWidget(l10n.commonAskingGit),
    ChangesFailed(failure: final AppFailure failure) => ChangesNoteWidget(
      _explain(l10n, failure),
    ),
    ChangesReady() when entries.isEmpty => ChangesNoteWidget(
      l10n.changesNothingChanged,
    ),
    ChangesReady() => _sections(l10n, ref, entries, isBusy: isBusy),
  };

  /// What is going in, then what is not, each under its own head.
  ///
  /// A section with nothing in it is left out rather than drawn empty: a
  /// `STAGED · 0` is a line read twice and ignored.
  static Widget _sections(
    AppLocalizations l10n,
    WidgetRef ref,
    List<StatusEntryValueObject> entries, {
    required bool isBusy,
  }) {
    final ChangesNotifier notifier = ref.read(changesProvider.notifier);
    final List<StatusEntryValueObject> staged = <StatusEntryValueObject>[
      for (final StatusEntryValueObject each in entries)
        if (each.isStaged) each,
    ];
    final List<StatusEntryValueObject> unstaged = <StatusEntryValueObject>[
      for (final StatusEntryValueObject each in entries)
        if (!each.isStaged) each,
    ];
    Widget rows(List<StatusEntryValueObject> section) => Column(
      children: <Widget>[
        for (final StatusEntryValueObject each in section)
          SizedBox(
            height: ChangesDesign.rowPitch,
            child: ChangesRowWidget(entry: each, isBusy: isBusy),
          ),
      ],
    );
    return ListView(
      padding: const EdgeInsets.only(top: ChangesDesign.sectionTop),
      children: <Widget>[
        if (staged.isNotEmpty) ...<Widget>[
          ChangesSectionWidget(
            title: l10n.changesStagedSection,
            count: staged.length,
            action: l10n.changesUnstageAll,
            onAction: isBusy
                ? null
                : () => unawaited(notifier.setAllStaged(staged: false)),
          ),
          rows(staged),
        ],
        if (staged.isNotEmpty && unstaged.isNotEmpty)
          const SizedBox(height: ChangesDesign.sectionGap),
        if (unstaged.isNotEmpty) ...<Widget>[
          ChangesSectionWidget(
            title: l10n.changesChangesSection,
            count: unstaged.length,
            action: l10n.changesStageAll,
            onAction: isBusy
                ? null
                : () => unawaited(notifier.setAllStaged(staged: true)),
          ),
          rows(unstaged),
        ],
      ],
    );
  }

  /// What to say about a repository that would not answer.
  ///
  /// A catch-all, because this switches over [AppFailure] itself and the
  /// panel must say something whatever went wrong.
  static String _explain(AppLocalizations l10n, AppFailure failure) =>
      switch (failure) {
        GitNotInstalled() => l10n.gitNotInstalled,
        GitNotARepository() => l10n.gitNotARepository,
        GitMergeConflict() => l10n.changesMergeInProgress,
        GitDetachedHead() => l10n.changesNotOnABranch,
        // Named, because the way out is in that one document.
        GitConflictMarkersPresent(paths: [final String only]) =>
          l10n.changesStillHoldsMarker(only.split('/').last),
        GitConflictMarkersPresent(paths: final List<String> several) =>
          l10n.changesStillHoldMarkers(several.length),
        GitNoCommitsYet() => l10n.changesNoCommitYet,
        GitPathCommitted(paths: [final String first, ...]) =>
          l10n.changesAlreadyCommitted(first.split('/').last),
        GitTimedOut() => l10n.gitTimedOut,
        _ => l10n.changesGitCouldNot,
      };
}
