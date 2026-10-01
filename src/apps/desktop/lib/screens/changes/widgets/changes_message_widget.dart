/// The box a commit is described in.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The commit message, as somebody writes it.
///
/// The controller is seeded once and cleared only when the notifier empties
/// the draft, because re-seeding under a cursor loses what is being typed.
/// Never disabled, even while git works: describing a commit is not git's.
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
    // A commit that landed empties the draft, and the field is the only place
    // still holding the old text.
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
