/// The surface the compare control opens.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/compare/compare_design.dart';
import 'package:tom_desktop/screens/compare/widgets/compare_field_widget.dart';
import 'package:tom_desktop/screens/compare/widgets/compare_row_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Pick a branch or a commit to compare this document against.
///
/// **Two lists behind one filter**, because the product offers both and they
/// are asked for the same way (`docs/product/diff/branch-diff/doc.md`). The
/// commits are the ones that touched *this* document, which is what makes the
/// list short enough to read.
///
/// A click outside and Escape both close it, and closing keeps nothing.
class ComparePopoverWidget extends ConsumerWidget {
  /// Creates the surface, calling [onDismissed] when it should go away.
  const ComparePopoverWidget({required this.onDismissed, super.key});

  /// What to call to put the surface away.
  final VoidCallback onDismissed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback>.has('onDismissed', onDismissed),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return TapRegion(
      onTapOutside: (PointerDownEvent _) => onDismissed(),
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): onDismissed,
        },
        child: Material(
          color: colors.surfaceRaised,
          elevation: 8,
          borderRadius: BorderRadius.circular(CompareDesign.radius),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(CompareDesign.radius),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: CompareDesign.padding,
            ),
            child: const _ContentsWidget(),
          ),
        ),
      ),
    );
  }
}

/// The filter, the two lists, and the way back to the working tree.
class _ContentsWidget extends ConsumerWidget {
  const _ContentsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CompareState state = ref.watch(compareProvider);
    final RevisionValueObject? base = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.comparingAgainst,
      ),
    );
    if (state is! CompareReady) {
      return const _NoteWidget('Open a document to compare it.');
    }
    final TomColors colors = TomColors.of(context);
    final List<BranchEntity> branches = state.visibleBranches;
    final List<CommitEntity> commits = state.visibleCommits;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: CompareDesign.popoverMaxHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _Padded(
            child: CompareFieldWidget(hint: 'Filter branches and commits'),
          ),
          const SizedBox(height: 12),
          if (branches.isEmpty && commits.isEmpty)
            // A repository always has a branch, so nothing at all with
            // nothing typed means the lists have not arrived yet — which is
            // different news from a filter that matched none of them.
            _NoteWidget(
              state.draft.isEmpty ? 'Asking git…' : 'Nothing by that name.',
            )
          else
            Flexible(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  if (branches.isNotEmpty) ...<Widget>[
                    const _CaptionWidget('BRANCHES'),
                    for (final BranchEntity branch in branches)
                      CompareBranchRowWidget(
                        branch: branch,
                        isBase: base is RevisionBranch && base.branch == branch,
                      ),
                  ],
                  if (commits.isNotEmpty) ...<Widget>[
                    const _CaptionWidget('THIS DOCUMENT\'S COMMITS'),
                    for (final CommitEntity commit in commits)
                      CompareCommitRowWidget(
                        commit: commit,
                        isBase:
                            base is RevisionCommit &&
                            base.commit.sha == commit.sha,
                      ),
                  ],
                ],
              ),
            ),
          if (base != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, thickness: 1, color: colors.border),
            ),
            _RowButtonWidget(
              label: 'Compare against the last commit',
              onPressed: ref.read(compareProvider.notifier).stop,
            ),
          ],
        ],
      ),
    );
  }
}

/// What a group of rows is, in the design's own words.
class _CaptionWidget extends StatelessWidget {
  const _CaptionWidget(this.text);

  final String text;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      CompareDesign.padding,
      6,
      CompareDesign.padding,
      6,
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10,
        height: 1.4,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: TomColors.of(context).textMuted,
      ),
    ),
  );
}

/// A full-width row that reads as a control rather than as a revision.
class _RowButtonWidget extends StatelessWidget {
  const _RowButtonWidget({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CompareDesign.rowInset),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(CompareDesign.radius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(CompareDesign.radius),
          child: SizedBox(
            height: CompareDesign.branchHeight,
            width: double.infinity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: CompareDesign.label,
                    height: 1.4,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A sentence the surface says about itself.
class _NoteWidget extends StatelessWidget {
  const _NoteWidget(this.text);

  final String text;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
  }

  @override
  Widget build(BuildContext context) => _Padded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: CompareDesign.note,
          height: 1.4,
          color: TomColors.of(context).textMuted,
        ),
      ),
    ),
  );
}

/// The popover's own side margin, which the lists do not take.
class _Padded extends StatelessWidget {
  const _Padded({required this.child});

  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Widget>('child', child));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: CompareDesign.padding),
    child: child,
  );
}
