/// One revision the document can be compared against.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/compare/compare_design.dart';
import 'package:tom_desktop/screens/history/history_words.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// A branch, and whether it is the base the document is compared against.
///
/// The current branch is offered like any other: comparing the working copy
/// against the branch it is on is what the default already does, and a row
/// missing from the list would read as a repository missing a branch.
class CompareBranchRowWidget extends ConsumerWidget {
  /// Creates the row for [branch].
  const CompareBranchRowWidget({
    required this.branch,
    required this.isBase,
    super.key,
  });

  /// The branch this row is.
  final BranchEntity branch;

  /// Whether the document is being compared against it.
  final bool isBase;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<BranchEntity>('branch', branch))
      ..add(DiagnosticsProperty<bool>('isBase', isBase));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => _RowWidget(
    isBase: isBase,
    pitch: CompareDesign.branchPitch,
    height: CompareDesign.branchHeight,
    onTap: () => ref
        .read(compareProvider.notifier)
        .choose(RevisionValueObject.branch(branch)),
    child: _LabelWidget(text: branch.name.value, isBase: isBase),
  );
}

/// A commit that touched this document, and whether it is the base.
///
/// Two lines, the same facts the history panel shows: the subject, then the
/// sha, the author and the age.
class CompareCommitRowWidget extends ConsumerWidget {
  /// Creates the row for [commit].
  const CompareCommitRowWidget({
    required this.commit,
    required this.isBase,
    super.key,
  });

  /// The commit this row is.
  final CommitEntity commit;

  /// Whether the document is being compared against it.
  final bool isBase;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<CommitEntity>('commit', commit))
      ..add(DiagnosticsProperty<bool>('isBase', isBase));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => _RowWidget(
    isBase: isBase,
    pitch: CompareDesign.commitPitch,
    height: CompareDesign.commitHeight,
    onTap: () => ref
        .read(compareProvider.notifier)
        .choose(RevisionValueObject.commit(commit)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _LabelWidget(
          // An amended commit can reach here with no subject, and a blank
          // row would look unclickable.
          text: commit.subject.isEmpty ? '(no message)' : commit.subject,
          isBase: isBase,
        ),
        const SizedBox(height: CompareDesign.metaGap),
        Text(
          '${commit.sha.short} · ${commit.author.name} · '
          '${whenInWords(commit.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: CompareDesign.note,
            height: 1.4,
            color: TomColors.of(context).textMuted,
          ),
        ),
      ],
    ),
  );
}

/// The box a revision is drawn in, whichever kind it is.
class _RowWidget extends StatelessWidget {
  const _RowWidget({
    required this.isBase,
    required this.pitch,
    required this.height,
    required this.onTap,
    required this.child,
  });

  final bool isBase;
  final double pitch;
  final double height;
  final VoidCallback onTap;
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isBase', isBase))
      ..add(DoubleProperty('pitch', pitch))
      ..add(DoubleProperty('height', height))
      ..add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: pitch,
      child: Align(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CompareDesign.rowInset,
          ),
          child: Material(
            color: isBase ? colors.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(CompareDesign.radius),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(CompareDesign.radius),
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A revision's name, marked when it is the base.
class _LabelWidget extends StatelessWidget {
  const _LabelWidget({required this.text, required this.isBase});

  final String text;
  final bool isBase;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('text', text))
      ..add(DiagnosticsProperty<bool>('isBase', isBase));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: CompareDesign.label,
          height: 1.4,
          // The weight says it a second way, because colour is never the
          // only signal.
          fontWeight: isBase ? FontWeight.w600 : FontWeight.w400,
          color: isBase ? colors.accent : colors.textPrimary,
        ),
      ),
    );
  }
}
