/// What a refused push says, and the one thing that mends it.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The remote moved first — said in words, with Pull underneath it.
///
/// The wording is the product's (`docs/product/git-workflow/push-pull/doc.md`):
/// who got there first, what to do, and that nothing committed is lost.
class ChangesRejectedWidget extends ConsumerWidget {
  /// Creates the banner.
  const ChangesRejectedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final int behind =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.git?.behind,
          ),
        ) ??
        0;
    final bool isBusy = ref.watch(
      remoteProvider.select((RemoteState state) => state.isBusy),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TomMetrics.padTight,
        ChangesDesign.captionTop,
        TomMetrics.padTight,
        ChangesDesign.stackGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.modifiedSoft,
              borderRadius: BorderRadius.circular(ChangesDesign.radius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                // Counted only when known: a fetch may not have happened yet.
                behind > 0
                    ? 'Someone pushed $behind commit${behind == 1 ? '' : 's'} '
                          'first.'
                    : 'Someone pushed first.',
                style: TextStyle(
                  fontSize: ChangesDesign.row,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: colors.modified,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Pull them, then push again. Nothing you committed has been lost.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: ChangesDesign.stackGap),
          SizedBox(
            height: ChangesDesign.buttonHeight,
            child: FilledButton(
              onPressed: isBusy
                  ? null
                  : () => unawaited(ref.read(remoteProvider.notifier).pull()),
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.surfaceRaised,
                disabledBackgroundColor: colors.surfaceSunken,
                disabledForegroundColor: colors.textMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ChangesDesign.radius),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Pull'),
            ),
          ),
        ],
      ),
    );
  }
}
