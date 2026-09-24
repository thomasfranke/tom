/// The question a switch asks before it can lose anything.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/branches/branches_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Save, discard, or stay — asked before the switch, never after.
///
/// **Switching is blocked while this is on screen** rather than the edit
/// being lost and reported
/// (`docs/product/git-workflow/branch-switch/doc.md`). It is drawn in the
/// popover that was being used rather than as a dialog over the window: the
/// question belongs to the control that raised it, and [Decision
/// 6](../../../../../../../docs/technical/decisions/006-no-navigation-package.md)
/// keeps `Navigator` for the cases that genuinely stop everything.
///
/// *Cancel* is also what closing the popover means, so there is no way to
/// leave the question standing behind a surface nobody can see.
class BranchesUnsavedWidget extends ConsumerWidget {
  /// Creates the question about moving to [target].
  const BranchesUnsavedWidget({required this.target, super.key});

  /// The branch the switch is waiting to move to.
  final BranchNameValueObject target;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<BranchNameValueObject>('target', target),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final SpaceRelativePathValueObject? document = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.openDocument,
      ),
    );
    final bool isBusy = ref.watch(
      branchesProvider.select(
        (BranchesState state) => state is BranchesReady && state.isBusy,
      ),
    );
    final BranchesNotifier notifier = ref.read(branchesProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          // Named, not "the open document": the one thing a text editor may
          // never do is lose work quietly, and half of not doing it is
          // saying which file is at stake.
          '${document?.value ?? 'The open document'} has unsaved changes.',
          style: TextStyle(
            fontSize: BranchesDesign.label,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Switching to ${target.value} would replace it with the version '
          'on that branch.',
          style: TextStyle(
            fontSize: BranchesDesign.note,
            height: 1.5,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        _ActionWidget(
          label: 'Save and switch',
          isPrimary: true,
          onPressed: isBusy ? null : () => unawaited(notifier.saveAndSwitch()),
        ),
        const SizedBox(height: 8),
        _ActionWidget(
          label: 'Discard and switch',
          isPrimary: false,
          onPressed: isBusy
              ? null
              : () => unawaited(notifier.discardAndSwitch()),
        ),
        const SizedBox(height: 8),
        _ActionWidget(
          label: 'Stay on this branch',
          isPrimary: false,
          onPressed: isBusy ? null : notifier.cancelSwitch,
        ),
      ],
    );
  }
}

/// One of the three answers.
class _ActionWidget extends StatelessWidget {
  const _ActionWidget({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback? onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(DiagnosticsProperty<bool>('isPrimary', isPrimary))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BranchesDesign.radius),
    );
    final TextStyle text = TextStyle(
      fontSize: BranchesDesign.note,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    );
    return SizedBox(
      height: 32,
      child: isPrimary
          ? FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.surfaceRaised,
                disabledBackgroundColor: colors.surfaceSunken,
                disabledForegroundColor: colors.textMuted,
                shape: shape,
                textStyle: text,
              ),
              child: Text(label),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textSecondary,
                disabledForegroundColor: colors.textMuted,
                side: BorderSide(color: colors.borderStrong),
                shape: shape,
                textStyle: text,
              ),
              child: Text(label),
            ),
    );
  }
}
