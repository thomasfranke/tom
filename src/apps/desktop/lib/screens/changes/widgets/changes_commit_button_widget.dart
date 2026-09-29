/// The one action the panel offers.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// *Commit*, disabled until something is staged and described.
///
/// Disabled rather than refused after the attempt
/// (`docs/product/git-workflow/commit/the-message/doc.md`).
class ChangesCommitButtonWidget extends ConsumerWidget {
  /// Creates the button, enabled when [canCommit], for [branch].
  const ChangesCommitButtonWidget({
    required this.canCommit,
    this.branch,
    super.key,
  });

  /// Whether something is staged and described.
  final bool canCommit;

  /// Where the commit is going, named on the button itself.
  ///
  /// Null on a detached `HEAD` or before git has answered, and then the
  /// button says only what it does: a commit that names no branch is the one
  /// this product refuses anyway
  /// (`docs/product/git-workflow/commit/the-message/doc.md`).
  final BranchNameValueObject? branch;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('canCommit', canCommit))
      ..add(DiagnosticsProperty<BranchNameValueObject?>('branch', branch));
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
            // Smaller than a Home button's 15: a branch name has to fit
            // inside a column, and the board shrank the label rather than
            // drop the name
            // (`design/screens/desktop/git-commit/committing-dark.svg`).
            textStyle: const TextStyle(
              fontSize: ChangesDesign.button,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(
            branch == null ? 'Commit' : 'Commit to ${branch!.value}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
