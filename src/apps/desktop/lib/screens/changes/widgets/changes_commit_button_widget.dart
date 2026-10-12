/// The one action the panel offers.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
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
    // The verb in progress on the button that was pressed, which keeps its
    // fill: going quiet reads the same as a click that never landed
    // (`docs/product/git-workflow/commit/confirming/doc.md`).
    final bool isCommitting = ref.watch(
      changesProvider.select(
        (ChangesState state) => state is ChangesReady && state.isCommitting,
      ),
    );
    final bool isFilled = canCommit || isCommitting;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ChangesDesign.inset),
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
            disabledBackgroundColor: isCommitting
                ? colors.accent
                : colors.control,
            disabledForegroundColor: isCommitting
                ? colors.surfaceRaised
                : colors.textMuted,
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
          // The check before the words, as every 1b board draws it.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TomGlyphWidget(
                glyph: TomGlyphEnum.check,
                color: isFilled ? colors.surfaceRaised : colors.textMuted,
                size: 11,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  isCommitting
                      ? context.l10n.changesCommitting
                      : branch == null
                      ? context.l10n.changesCommit
                      : context.l10n.changesCommitTo(branch!.value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
