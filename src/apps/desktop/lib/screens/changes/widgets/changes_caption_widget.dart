/// What the changes panel is called, and the one control beside it.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The panel's caption, and *All* — everything at once.
///
/// The other half of the product's staging rule: everything at once, or one
/// file at a time, and nothing finer than a file
/// (`docs/product/git-workflow/commit/doc.md`).
///
/// Drawn by the panel itself, because the shell draws no panel chrome.
class ChangesCaptionWidget extends ConsumerWidget {
  /// Creates the caption for a list where [allStaged] says whether
  /// everything is already in, disabled while [isBusy].
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
          // Expanded rather than followed by a spacer: the aside is a fixed
          // column that a module may put a second panel into, and a caption
          // that could not give way would overflow the day one did.
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
