/// The box a commit is described in.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The commit message, as somebody writes it.
///
/// **The controller is the draft while this is on screen** — seeded once
/// from the state and pushing every keystroke up, for the same reason the
/// editor's is: a field re-seeded under a cursor loses what was being typed.
/// Re-seeded only when the notifier empties it, which is what a commit that
/// landed does.
///
/// **Never disabled**, not even while git is working: describing a commit
/// has nothing to do with git, and taking the box away mid-sentence because
/// a file is being staged would be hostile.
class ChangesMessageWidget extends ConsumerStatefulWidget {
  /// Creates the box.
  const ChangesMessageWidget({super.key});

  @override
  ConsumerState<ChangesMessageWidget> createState() =>
      _ChangesMessageWidgetState();
}

class _ChangesMessageWidgetState extends ConsumerState<ChangesMessageWidget> {
  late final TextEditingController _controller = TextEditingController(
    text: switch (ref.read(changesProvider)) {
      ChangesReady(message: final String message) => message,
      _ => '',
    },
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The one thing worth listening for: a commit that landed empties the
    // box, and the field is the only place that still holds the old text.
    ref.listen<ChangesState>(changesProvider, (
      ChangesState? previous,
      ChangesState next,
    ) {
      final bool emptied = next is ChangesReady && next.message.isEmpty;
      if (emptied && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    });
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TomMetrics.padTight),
      child: SizedBox(
        height: ChangesDesign.messageHeight,
        child: TextField(
          controller: _controller,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          onChanged: ref.read(changesProvider.notifier).describe,
          style: TextStyle(
            fontSize: ChangesDesign.message,
            height: 1.4,
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Summary',
            hintStyle: TextStyle(
              fontSize: ChangesDesign.message,
              height: 1.4,
              color: colors.textMuted,
            ),
            filled: true,
            fillColor: colors.surfaceSunken,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ChangesDesign.radius),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ChangesDesign.radius),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ChangesDesign.radius),
              borderSide: BorderSide(color: colors.accent, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
