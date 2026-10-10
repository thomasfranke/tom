/// The `Overview` segment: what the branch did, in numbers.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/screens/history/history_words.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_design.dart';
import 'package:tom_desktop/screens/pull_request/widgets/pull_request_caption_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Reading time, words, blocks by kind, documents, commits, folders and the
/// most changed — and no action, because a number beside a button invites
/// pressing it (`docs/product/git-workflow/pull-request/the-right-column/doc.md`).
class PullRequestOverviewPanel extends ConsumerStatefulWidget {
  /// Creates the panel.
  const PullRequestOverviewPanel({super.key});

  @override
  ConsumerState<PullRequestOverviewPanel> createState() =>
      _PullRequestOverviewPanelState();
}

class _PullRequestOverviewPanelState
    extends ConsumerState<PullRequestOverviewPanel> {
  @override
  void initState() {
    super.initState();
    // Read when it is first looked at: the overview reads every changed
    // document twice, which the proposal alone never needs.
    unawaited(
      Future<void>.microtask(() async {
        if (mounted) {
          await ref
              .read(pullRequestProvider.notifier)
              .show(PullRequestSegmentEnum.overview);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    final BranchOverviewValueObject? overview = ref.watch(
      pullRequestProvider.select((PullRequestState state) => state.overview),
    );
    if (overview == null) {
      return Padding(
        padding: const EdgeInsets.all(ChangesDesign.inset),
        child: Text(
          l10n.pullRequestCounting,
          style: TextStyle(fontSize: 12, color: colors.textMuted),
        ),
      );
    }
    TextStyle value({FontWeight weight = FontWeight.w500, Color? color}) =>
        TextStyle(
          fontSize: 12.5,
          height: 1.4,
          fontWeight: weight,
          color: color ?? colors.textPrimary,
        );
    TextStyle small(Color color) => TextStyle(
      fontSize: PullRequestDesign.small,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: color,
    );
    List<Widget> section(String caption, List<Widget> body) => <Widget>[
      const SizedBox(height: PullRequestDesign.sectionGap),
      PullRequestCaptionWidget(caption),
      const SizedBox(height: PullRequestDesign.lineGap),
      ...body,
    ];
    final BranchChangeValueObject? most = overview.mostChanged;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: ChangesDesign.inset),
      children: <Widget>[
        const SizedBox(height: PullRequestDesign.headlineTop),
        Text(
          l10n.pullRequestMinutes(overview.readingMinutes),
          style: TextStyle(
            fontSize: PullRequestDesign.headline,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        Text(
          l10n.pullRequestToReview,
          style: TextStyle(
            fontSize: PullRequestDesign.small,
            height: 1.4,
            color: colors.textMuted,
          ),
        ),
        ...section(l10n.pullRequestWords, <Widget>[
          Row(
            children: <Widget>[
              Text(
                '+${overview.wordsAdded}',
                style: value(color: colors.added),
              ),
              const SizedBox(width: 10),
              Text(
                '−${overview.wordsRemoved}',
                style: value(color: colors.removed),
              ),
            ],
          ),
        ]),
        if (overview.blocks.isNotEmpty)
          ...section(l10n.pullRequestBlocks, <Widget>[
            Text(
              <String>[
                for (final MapEntry<BlockKindEnum, int> kind
                    in overview.blocks.entries)
                  _kindCount(l10n, kind.key, kind.value),
              ].join(' · '),
              style: value(),
            ),
          ]),
        ...section(l10n.pullRequestDocuments, <Widget>[
          Text(
            <String>[
              if (overview.modified > 0)
                l10n.pullRequestModified(overview.modified),
              if (overview.added > 0) l10n.pullRequestAdded(overview.added),
              if (overview.deleted > 0)
                l10n.pullRequestDeleted(overview.deleted),
            ].join(' · '),
            style: value(),
          ),
        ]),
        ...section(l10n.pullRequestCommits, <Widget>[
          Text(switch (overview.firstCommit) {
            null => '${overview.commits}',
            final CommitDateValueObject first => l10n.pullRequestCommitsSince(
              overview.commits,
              whenInWords(l10n, first),
            ),
          }, style: value()),
        ]),
        if (overview.folders.isNotEmpty)
          ...section(l10n.pullRequestFolders, <Widget>[
            for (final MapEntry<String, int> folder
                in overview.folders.entries.take(5))
              SizedBox(
                height: PullRequestDesign.folderPitch,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        folder.key.isEmpty ? '/' : folder.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: value(
                          weight: FontWeight.w400,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '${folder.value}',
                      style: value(weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ]),
        if (most != null)
          ...section(l10n.pullRequestMostChanged, <Widget>[
            Text(most.path.name, style: value()),
            Row(
              children: <Widget>[
                Text('+${most.added ?? 0}', style: small(colors.added)),
                const SizedBox(width: 8),
                Text('−${most.removed ?? 0}', style: small(colors.removed)),
              ],
            ),
          ]),
        const SizedBox(height: ChangesDesign.inset),
      ],
    );
  }

  /// [count] blocks of [kind], as a reader says it.
  static String _kindCount(
    AppLocalizations l10n,
    BlockKindEnum kind,
    int count,
  ) => switch (kind) {
    BlockKindEnum.paragraph => l10n.pullRequestParagraphs(count),
    BlockKindEnum.heading => l10n.pullRequestHeadings(count),
    BlockKindEnum.list => l10n.pullRequestLists(count),
    BlockKindEnum.table => l10n.pullRequestTables(count),
    BlockKindEnum.code => l10n.pullRequestCodeBlocks(count),
    BlockKindEnum.quote => l10n.pullRequestQuotes(count),
    BlockKindEnum.rule => l10n.pullRequestRules(count),
    BlockKindEnum.html => l10n.pullRequestHtmlBlocks(count),
  };
}
