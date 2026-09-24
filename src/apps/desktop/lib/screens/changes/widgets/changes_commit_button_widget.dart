/// The one action the panel offers.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// *Commit*, disabled until there is something to record and something to
/// call it.
///
/// **Disabled, not absent, and not a message after the fact**: a commit
/// requires a message, and committing with nothing staged is refused before
/// it is attempted (`docs/product/git-workflow/commit/doc.md`).
class ChangesCommitButtonWidget extends ConsumerWidget {
  /// Creates the button, enabled when [canCommit].
  const ChangesCommitButtonWidget({required this.canCommit, super.key});

  /// Whether something is staged and described.
  final bool canCommit;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('canCommit', canCommit));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TomMetrics.padTight),
      child: SizedBox(
        width: double.infinity,
        height: ChangesDesign.buttonHeight,
        child: FilledButton(
          onPressed: canCommit
              ? () => unawaited(ref.read(changesProvider.notifier).commit())
              : null,
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
          child: const Text('Commit'),
        ),
      ),
    );
  }
}
