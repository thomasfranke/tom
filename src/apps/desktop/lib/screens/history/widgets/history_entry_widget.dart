/// One commit in the history of the open document.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/history/history_design.dart';
import 'package:tom_desktop/screens/history/history_words.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// A commit: what it was called, who wrote it, and how long ago.
///
/// All three because the product asks for all three
/// (`docs/product/git-workflow/file-history/doc.md`), on the wireframe's two
/// lines: the subject, then the sha, the author and the age. The sha is
/// there because it is the only one of the four that names the commit
/// anywhere else — in a terminal, in a review, in a bug report.
///
/// Clicking it opens that version, which is [SpaceSessionState]'s to record:
/// the preview renders it and the bar above the document says so, and one
/// answer is what stops those two disagreeing.
class HistoryEntryWidget extends ConsumerWidget {
  /// Creates the entry for [commit], marked when [isOpen].
  const HistoryEntryWidget({
    required this.commit,
    required this.isOpen,
    super.key,
  });

  /// The commit this entry is.
  final CommitEntity commit;

  /// Whether this is the version on screen.
  final bool isOpen;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<CommitEntity>('commit', commit))
      ..add(DiagnosticsProperty<bool>('isOpen', isOpen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: HistoryDesign.entryPitch,
      child: Align(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TomMetrics.padTight),
          child: Material(
            color: isOpen ? colors.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(HistoryDesign.radius),
            child: InkWell(
              onTap: () => ref.read(historyProvider.notifier).open(commit),
              borderRadius: BorderRadius.circular(HistoryDesign.radius),
              child: SizedBox(
                height: HistoryDesign.entryHeight,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        // An empty subject is possible — `git commit -m ''`
                        // is refused, but an amended one can get there — and
                        // a blank row would be unclickable-looking.
                        commit.subject.isEmpty
                            ? '(no message)'
                            : commit.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: HistoryDesign.subject,
                          height: 1.4,
                          fontWeight: isOpen
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isOpen ? colors.accent : colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: HistoryDesign.metaGap),
                      Text(
                        _meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: HistoryDesign.meta,
                          height: 1.4,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The second line: which commit, whose, and how old.
  String get _meta => <String>[
    commit.sha.short,
    commit.author.name,
    whenInWords(commit.date),
  ].join(' · ');
}
