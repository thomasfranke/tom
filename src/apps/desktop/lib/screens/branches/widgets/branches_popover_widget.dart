/// The surface the branch control opens.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/branches/branches_design.dart';
import 'package:tom_desktop/screens/branches/widgets/branches_field_widget.dart';
import 'package:tom_desktop/screens/branches/widgets/branches_row_widget.dart';
import 'package:tom_desktop/screens/branches/widgets/branches_unsaved_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Choose a branch, start one, or answer for the unsaved buffer first.
///
/// **Three faces, one surface.** Which one is drawn is the state's to say,
/// not this widget's to remember — a popover holding its own idea of what it
/// is showing is how it comes to disagree with what the notifier is doing.
///
/// A click outside and Escape both close it, and closing is *cancel*: no
/// half-typed name is kept and no question is left standing.
class BranchesPopoverWidget extends ConsumerWidget {
  /// Creates the surface, calling [onDismissed] when it should go away.
  const BranchesPopoverWidget({required this.onDismissed, super.key});

  /// What to call to put the surface away.
  final VoidCallback onDismissed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback>.has('onDismissed', onDismissed),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return TapRegion(
      onTapOutside: (PointerDownEvent _) => onDismissed(),
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): onDismissed,
        },
        child: Material(
          color: colors.surfaceRaised,
          elevation: 8,
          borderRadius: BorderRadius.circular(BranchesDesign.radius),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(BranchesDesign.radius),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: BranchesDesign.padding,
            ),
            child: _ContentsWidget(onDismissed: onDismissed),
          ),
        ),
      ),
    );
  }
}

/// Whichever of the three faces the state is asking for.
class _ContentsWidget extends ConsumerWidget {
  const _ContentsWidget({required this.onDismissed});

  final VoidCallback onDismissed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback>.has('onDismissed', onDismissed),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BranchesState state = ref.watch(branchesProvider);
    return switch (state) {
      BranchesInitial() ||
      BranchesLoading() => const _NoteWidget('Asking git…'),
      BranchesFailed() => const _NoteWidget(
        'Git could not say what branches there are.',
      ),
      BranchesReady(pending: final BranchNameValueObject target) => _Padded(
        child: BranchesUnsavedWidget(target: target),
      ),
      BranchesReady(isCreating: true) => _CreateWidget(state: state),
      final BranchesReady ready => _ListWidget(
        state: ready,
        onDismissed: onDismissed,
      ),
    };
  }
}

/// The branches, filtered, with the way to start another under them.
class _ListWidget extends ConsumerWidget {
  const _ListWidget({required this.state, required this.onDismissed});

  final BranchesReady state;
  final VoidCallback onDismissed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<BranchesReady>('state', state))
      ..add(ObjectFlagProperty<VoidCallback>.has('onDismissed', onDismissed));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final List<BranchEntity> visible = state.visible;
    // The height the wireframe fixes belongs to *this* face: a repository
    // with forty branches scrolls, and the other two faces are as tall as
    // what they have to say.
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: BranchesDesign.popoverMaxHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _Padded(child: BranchesFieldWidget(hint: 'Filter branches')),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            const _NoteWidget('No branch by that name.')
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemExtent: BranchesDesign.rowPitch,
                itemCount: visible.length,
                itemBuilder: (BuildContext context, int index) =>
                    BranchesRowWidget(branch: visible[index]),
              ),
            ),
          if (state.failure != null)
            const _NoteWidget('Git refused that. Nothing has changed.'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, thickness: 1, color: colors.border),
          ),
          _RowButtonWidget(
            label: 'Create branch…',
            onPressed: ref.read(branchesProvider.notifier).startCreating,
          ),
        ],
      ),
    );
  }
}

/// Naming a branch, which starts it from where `HEAD` is now.
class _CreateWidget extends ConsumerWidget {
  const _CreateWidget({required this.state});

  final BranchesReady state;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BranchesReady>('state', state));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final BranchesNotifier notifier = ref.read(branchesProvider.notifier);
    final String from =
        state.branches
            .where((BranchEntity it) => it.isCurrent)
            .map((BranchEntity it) => it.name.value)
            .firstOrNull ??
        'where you are';
    return _Padded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const BranchesFieldWidget(hint: 'New branch name'),
          const SizedBox(height: 8),
          Text(
            // What it branches from, said before rather than discovered
            // after: a branch starts at the current HEAD and the app moves
            // onto it immediately
            // (`docs/product/git-workflow/branch-switch/doc.md`).
            state.rejected ?? 'Starts from $from, and switches to it.',
            style: TextStyle(
              fontSize: BranchesDesign.note,
              height: 1.4,
              color: state.rejected == null ? colors.textMuted : colors.removed,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: FilledButton(
              onPressed: state.canCreate
                  ? () => unawaited(notifier.create())
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.surfaceRaised,
                disabledBackgroundColor: colors.surfaceSunken,
                disabledForegroundColor: colors.textMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BranchesDesign.radius),
                ),
                textStyle: const TextStyle(
                  fontSize: BranchesDesign.note,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Create branch'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: OutlinedButton(
              onPressed: notifier.stopCreating,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textSecondary,
                side: BorderSide(color: colors.borderStrong),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BranchesDesign.radius),
                ),
                textStyle: const TextStyle(
                  fontSize: BranchesDesign.note,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Back to the list'),
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-width row that reads as a control rather than as a branch.
class _RowButtonWidget extends StatelessWidget {
  const _RowButtonWidget({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BranchesDesign.rowInset),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(BranchesDesign.radius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(BranchesDesign.radius),
          child: SizedBox(
            height: BranchesDesign.rowHeight,
            width: double.infinity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: BranchesDesign.label,
                    height: 1.4,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A sentence the surface says about itself.
class _NoteWidget extends StatelessWidget {
  const _NoteWidget(this.text);

  final String text;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
  }

  @override
  Widget build(BuildContext context) => _Padded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: BranchesDesign.note,
          height: 1.4,
          color: TomColors.of(context).textMuted,
        ),
      ),
    ),
  );
}

/// The popover's own side margin, which the list does not take.
class _Padded extends StatelessWidget {
  const _Padded({required this.child});

  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Widget>('child', child));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: BranchesDesign.padding),
    child: child,
  );
}
