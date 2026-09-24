/// The commits that touched the document currently open.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/history/history_design.dart';
import 'package:tom_desktop/screens/history/widgets/history_entry_widget.dart';
import 'package:tom_desktop/screens/history/widgets/history_note_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Who changed this document, when, and what they called it.
///
/// **Scoped to the open document, not to the repository**
/// (`docs/product/git-workflow/file-history/doc.md`) — which is the whole
/// difference between this panel and a log, and why it says so under the
/// list rather than leaving somebody to wonder why a busy repository has
/// four entries.
///
/// Clicking an entry shows that version *rendered*; the preview is what
/// draws it and the bar above the document is what offers the way back.
class HistoryPanel extends ConsumerWidget {
  /// Creates the panel.
  const HistoryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HistoryState state = ref.watch(historyProvider);
    final CommitEntity? reading = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.readingVersion,
      ),
    );
    final TomColors colors = TomColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: HistoryDesign.captionTop),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
          child: Text(
            'HISTORY',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: HistoryDesign.caption,
              height: 1.4,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
        ),
        const SizedBox(
          height:
              HistoryDesign.entriesTop -
              HistoryDesign.captionTop -
              HistoryDesign.caption * 1.4,
        ),
        Expanded(child: _body(state, reading)),
        if (state case HistoryReady(
          commits: final List<CommitEntity> all,
        ) when all.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          const HistoryNoteWidget('scoped to this file, not the repo'),
        ],
        const SizedBox(height: TomMetrics.pad),
      ],
    );
  }

  /// The list, or the sentence that stands in for it.
  static Widget _body(HistoryState state, CommitEntity? reading) =>
      switch (state) {
        HistoryIdle() => const HistoryNoteWidget(
          'Open a document to see what changed it.',
        ),
        HistoryLoading() => const HistoryNoteWidget('Asking git…'),
        HistoryFailed(failure: final AppFailure failure) => HistoryNoteWidget(
          _explain(failure),
        ),
        HistoryReady(commits: final List<CommitEntity> commits)
            when commits.isEmpty =>
          const HistoryNoteWidget('Git has no record of this file yet.'),
        HistoryReady(commits: final List<CommitEntity> commits) =>
          ListView.builder(
            // The design's pitch, and what lets the list build lazily.
            itemExtent: HistoryDesign.entryPitch,
            itemCount: commits.length,
            itemBuilder: (BuildContext context, int index) =>
                HistoryEntryWidget(
                  commit: commits[index],
                  isOpen: commits[index].sha == reading?.sha,
                ),
          ),
      };

  /// What to say about a repository that would not answer.
  ///
  /// A catch-all, because this switches over [AppFailure] itself: whatever
  /// went wrong, the panel says something rather than staying blank.
  static String _explain(AppFailure failure) => switch (failure) {
    GitNotInstalled() => 'TOM could not find git on this machine.',
    GitNotARepository() => 'That folder is not inside a Git repository.',
    GitTimedOut() => 'Git took too long to answer.',
    _ => 'Git could not read this file\'s history.',
  };
}
