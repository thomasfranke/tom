/// What the changes panel is called, and the one control beside it.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The panel's caption, and *All* — the staging rule's everything-at-once
/// half (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
class ChangesCaptionWidget extends ConsumerWidget {
  /// Creates the caption.
  const ChangesCaptionWidget({
    required this.allStaged,
    required this.isBusy,
    super.key,
  });

  /// Whether every change git reports is already staged.
  final bool allStaged;

  /// Whether git is already doing something.
  final bool isBusy;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('allStaged', allStaged))
      ..add(DiagnosticsProperty<bool>('isBusy', isBusy));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
      child: Row(
        children: <Widget>[
          // Expanded rather than followed by a spacer: a module may put a
          // second panel in the aside, and a caption that cannot give way
          // overflows the day one does.
          Expanded(
            child: Text(
              'CHANGES',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ChangesDesign.caption,
                height: 1.4,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
              ),
            ),
          ),
          Text(
            'All',
            style: TextStyle(
              fontSize: ChangesDesign.row,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: ChangesDesign.mark,
            height: ChangesDesign.mark,
            child: Checkbox(
              value: allStaged,
              onChanged: isBusy
                  ? null
                  : (bool? staged) => unawaited(
                      ref
                          .read(changesProvider.notifier)
                          .setAllStaged(staged: staged ?? false),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
