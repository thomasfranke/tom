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
import 'package:tom_desktop/screens/changes/widgets/changes_rejected_widget.dart';
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
    // While a push stands refused the banner is the column: the box and the
    // button give way, which is also what keeps the panel inside its height
    // when it shares the aside
    // (`docs/product/git-workflow/push-pull/when-it-fails/doc.md`).
    final bool rejected = ref.watch(remoteProvider) is RemoteRejected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (rejected) const ChangesRejectedWidget(),
        const SizedBox(height: ChangesDesign.captionTop),
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
        // Hidden, not emptied: the message is the notifier's and comes back
        // with the banner.
        if (!rejected) ...<Widget>[
          const SizedBox(height: ChangesDesign.stackGap),
          const ChangesMessageWidget(),
          const SizedBox(height: ChangesDesign.stackGap),
          ChangesCommitButtonWidget(
            canCommit:
                !isBusy &&
                state is ChangesReady &&
                state.message.trim().isNotEmpty &&
                (status?.hasStagedChanges ?? false),
          ),
        ],
        const SizedBox(height: TomMetrics.pad),
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
