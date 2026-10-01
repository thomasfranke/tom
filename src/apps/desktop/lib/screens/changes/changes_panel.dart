/// The git column: what differs, what is going in, and the commit.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_caption_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_commit_button_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_message_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_note_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_remote_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_row_widget.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // No gap of its own: the column's switch already leaves one under
        // itself, and a second would push `All` off the board's line.
        ChangesCaptionWidget(
          allStaged:
              entries.isNotEmpty &&
              entries.every((StatusEntryValueObject e) => e.isStaged),
          isBusy: isBusy,
        ),
        const SizedBox(
          height:
              ChangesDesign.rowsTop -
              ChangesDesign.captionTop -
              ChangesDesign.caption * 1.4,
        ),
        Expanded(child: _body(state, entries, isBusy: isBusy)),
        // Above the box rather than in place of the list, so a refusal is
        // said while what it refused is still on screen.
        if (state case ChangesReady(failure: final AppFailure refused))
          Padding(
            padding: const EdgeInsets.only(top: ChangesDesign.stackGap),
            child: ChangesNoteWidget(_explain(refused)),
          ),
        // Never taken away, not even by a refused push: the refusal is a band
        // above the document and this column keeps working
        // (`docs/product/git-workflow/push-pull/when-it-fails/doc.md`).
        const SizedBox(height: ChangesDesign.stackGap),
        const ChangesMessageWidget(),
        const SizedBox(height: ChangesDesign.stackGap),
        ChangesCommitButtonWidget(
          canCommit:
              !isBusy &&
              toResolve == 0 &&
              state is ChangesReady &&
              state.message.trim().isNotEmpty &&
              (status?.hasStagedChanges ?? false),
          branch: status?.isDetached ?? false ? null : status?.branch,
        ),
        // Under the button rather than on it: what is going in is a fact
        // about the list above, and the button says what it does. Absent
        // with nothing changed, because `0 of 0` is a line read twice and
        // ignored (`design/screens/desktop/git-commit/committing-dark.svg`).
        if (entries.isNotEmpty) ...<Widget>[
          const SizedBox(height: ChangesDesign.buttonToStaged),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TomMetrics.padTight,
            ),
            child: Text(
              // What is left to resolve takes the line while a merge is
              // unfinished: the staged count answers a question nobody is
              // asking yet
              // (`design/screens/desktop/git-conflict/conflict-in-source-light.svg`).
              toResolve > 0
                  ? '$toResolve document${toResolve == 1 ? '' : 's'} to resolve'
                  : '$staged of ${entries.length} staged',
              style: TextStyle(
                fontSize: ChangesDesign.staged,
                height: 1.4,
                color: TomColors.of(context).textSecondary,
              ),
            ),
          ),
        ],
        // Under the commit, in the order the work happens: stage, describe,
        // commit, then publish
        // (`docs/product/git-workflow/push-pull/the-controls/doc.md`).
        const ChangesRemoteWidget(),
        // Sixteen, which is where a column's content ends: the containers
        // run under the status bar and what sits in them does not
        // (`docs/design/screens/measurements.md`).
        const SizedBox(height: TomMetrics.padTight),
      ],
    );
  }

  /// The list, or the sentence that stands in for it.
  static Widget _body(
    ChangesState state,
    List<StatusEntryValueObject> entries, {
    required bool isBusy,
  }) => switch (state) {
    ChangesInitial() => const ChangesNoteWidget('No space is open.'),
    ChangesLoading() => const ChangesNoteWidget('Asking git…'),
    ChangesFailed(failure: final AppFailure failure) => ChangesNoteWidget(
      _explain(failure),
    ),
    ChangesReady() when entries.isEmpty => const ChangesNoteWidget(
      'Nothing has changed since the last commit.',
    ),
    ChangesReady() => ListView.builder(
      itemExtent: ChangesDesign.rowPitch,
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) =>
          ChangesRowWidget(entry: entries[index], isBusy: isBusy),
    ),
  };

  /// What to say about a repository that would not answer.
  ///
  /// A catch-all, because this switches over [AppFailure] itself and the
  /// panel must say something whatever went wrong.
  static String _explain(AppFailure failure) => switch (failure) {
    GitNotInstalled() => 'TOM could not find git on this machine.',
    GitNotARepository() => 'That folder is not inside a Git repository.',
    GitMergeConflict() => 'A merge is in progress — resolve it first.',
    GitTimedOut() => 'Git took too long to answer.',
    _ => 'Git could not do that.',
  };
}
