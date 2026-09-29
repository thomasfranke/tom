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
      padding: const EdgeInsets.symmetric(horizontal: TomMetrics.padTight),
      child: Row(
        children: <Widget>[
          // No caption: the column's switch names the panel now, and a word
          // that repeats the raised segment above it says nothing
          // (`docs/product/workspace/columns/doc.md`).
          const Spacer(),
          Text(
            'All',
            style: TextStyle(
              fontSize: ChangesDesign.all,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          TomCheckWidget(
            // Pinned right, where the column's margin is
            // (`git-commit/committing-dark.svg`).
            alignment: Alignment.centerRight,
            isChecked: allStaged,
            onChanged: isBusy
                ? null
                : (bool staged) => unawaited(
                    ref
                        .read(changesProvider.notifier)
                        .setAllStaged(staged: staged),
                  ),
          ),
        ],
      ),
    );
  }
}
