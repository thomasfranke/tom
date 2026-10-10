/// The `Pull request` segment: the base, the branch's commits, the action.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_design.dart';
import 'package:tom_desktop/screens/pull_request/widgets/pull_request_actions_widget.dart';
import 'package:tom_desktop/screens/pull_request/widgets/pull_request_base_widget.dart';
import 'package:tom_desktop/screens/pull_request/widgets/pull_request_caption_widget.dart';
import 'package:tom_desktop/screens/pull_request/widgets/pull_request_commit_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// What is proposed, onto what, and the way to open it
/// (`docs/product/git-workflow/pull-request/the-right-column/doc.md`).
///
/// The foot is [PullRequestActionsWidget], which follows what `gh`
/// answered for the branch.
class PullRequestPanel extends ConsumerWidget {
  /// Creates the panel.
  const PullRequestPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final BranchNameValueObject? base = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.pullRequestBase,
      ),
    );
    final BranchProposalValueObject? proposal = ref.watch(
      pullRequestProvider.select((PullRequestState state) => state.proposal),
    );
    final RemoteHostEnum? host = ref.watch(
      pullRequestProvider.select(
        (PullRequestState state) => state.target?.project?.host,
      ),
    );
    final TextStyle summary = TextStyle(
      fontSize: 12.5,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ChangesDesign.inset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: PullRequestDesign.captionTop),
          PullRequestCaptionWidget(context.l10n.pullRequestProposingOnto),
          if (base != null) PullRequestBaseWidget(base: base),
          const SizedBox(height: PullRequestDesign.afterSelect),
          PullRequestCaptionWidget(context.l10n.pullRequestThisBranch),
          // Nothing over the base: the summary says so, and no list.
          if (proposal != null && proposal.commits.isEmpty) ...<Widget>[
            const SizedBox(height: PullRequestDesign.lineGap),
            Text(
              context.l10n.pullRequestNoCommitsOver(base?.value ?? ''),
              style: summary,
            ),
            const Spacer(),
          ] else if (proposal != null) ...<Widget>[
            const SizedBox(height: PullRequestDesign.lineGap),
            Text(
              context.l10n.pullRequestProposal(
                proposal.commits.length,
                proposal.changes.length,
              ),
              style: summary,
            ),
            const SizedBox(height: PullRequestDesign.lineGap),
            _LinesWidget(
              added: proposal.linesAdded,
              removed: proposal.linesRemoved,
            ),
            const SizedBox(height: PullRequestDesign.commitsTop),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  for (final CommitEntity commit in proposal.commits)
                    PullRequestCommitWidget(commit: commit),
                ],
              ),
            ),
          ] else
            const Spacer(),
          if (host != null) PullRequestActionsWidget(host: host),
          const SizedBox(height: PullRequestDesign.footBottom),
        ],
      ),
    );
  }
}

/// `+48 −12`, in the diff's own two colours.
class _LinesWidget extends StatelessWidget {
  const _LinesWidget({required this.added, required this.removed});

  final int added;
  final int removed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('added', added))
      ..add(IntProperty('removed', removed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    TextStyle style(Color color) => TextStyle(
      fontSize: PullRequestDesign.small,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: color,
    );
    return Row(
      children: <Widget>[
        Text('+$added', style: style(colors.added)),
        const SizedBox(width: 8),
        Text('−$removed', style: style(colors.removed)),
      ],
    );
  }
}
