/// The question leaving asks before it can lose anything.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/spaces/space_menu_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Save, discard, or stay — asked before leaving, never after
/// (`docs/product/workspace/leaving-a-space/doc.md`).
///
/// The same question a branch switch asks, because the thing at risk is the
/// same: an edit that never reached the disk. Drawn in the menu that raised
/// it rather than in a dialog
/// ([Decision 6](../../../../../../../docs/technical/decisions/006-no-navigation-package.md)).
class SpaceMenuUnsavedWidget extends ConsumerWidget {
  /// Creates the question.
  const SpaceMenuUnsavedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final SpaceRelativePathValueObject? document = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.openDocument,
      ),
    );
    final SpaceMenuNotifier notifier = ref.read(spaceMenuProvider.notifier);
    final String going = switch (ref.watch(
      spaceMenuProvider.select((SpaceMenuState state) => state.pending),
    )) {
      SpaceDepartureSwitching(space: final RecentSpaceEntity it) => it.name,
      _ => '',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // A rule in `modified`, the role the unsaved buffer already wears in
        // the mode bar and the tree.
        Container(
          height: SpaceMenuDesign.warningBar,
          decoration: BoxDecoration(
            color: colors.modified,
            borderRadius: BorderRadius.circular(SpaceMenuDesign.warningRadius),
          ),
        ),
        const SizedBox(height: SpaceMenuDesign.dividerGap),
        Text(
          // Named, because half of not losing work quietly is saying which
          // file is at stake.
          '${document?.value ?? 'The open document'} has unsaved changes.',
          style: TextStyle(
            fontSize: SpaceMenuDesign.title,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          going.isEmpty
              ? 'Closing the space leaves the window, and the edit that has '
                    'not reached the disk goes with it.'
              : 'Opening $going replaces what is on screen, and the edit '
                    'that has not reached the disk goes with it.',
          style: TextStyle(
            fontSize: SpaceMenuDesign.note,
            height: 1.5,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        _AnswerWidget(
          label: going.isEmpty ? 'Save and close' : 'Save and open',
          isPrimary: true,
          onPressed: () => unawaited(notifier.saveAndLeave()),
        ),
        const SizedBox(height: SpaceMenuDesign.answerGap),
        _AnswerWidget(
          label: going.isEmpty ? 'Discard and close' : 'Discard and open',
          isPrimary: false,
          onPressed: () => unawaited(notifier.discardAndLeave()),
        ),
        const SizedBox(height: SpaceMenuDesign.answerGap),
        _AnswerWidget(
          label: 'Stay in this space',
          isPrimary: false,
          onPressed: notifier.stay,
        ),
      ],
    );
  }
}

/// One of the three answers.
class _AnswerWidget extends StatelessWidget {
  const _AnswerWidget({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(DiagnosticsProperty<bool>('isPrimary', isPrimary))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SpaceMenuDesign.rowRadius),
    );
    const TextStyle text = TextStyle(
      fontSize: SpaceMenuDesign.title,
      fontWeight: FontWeight.w600,
    );
    return SizedBox(
      height: SpaceMenuDesign.answerHeight,
      child: isPrimary
          ? FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.surfaceRaised,
                shape: shape,
                textStyle: text,
              ),
              child: Text(label),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                side: BorderSide(color: colors.borderStrong),
                shape: shape,
                textStyle: text,
              ),
              child: Text(label),
            ),
    );
  }
}
