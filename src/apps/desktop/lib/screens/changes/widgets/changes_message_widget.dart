/// The box a commit is described in.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The commit message, as somebody writes it: the summary on the first line
/// and an optional description under it, in one box
/// (`design/screens/desktop/git-commit/committing-dark.svg`).
///
/// The controllers are seeded once and cleared only when the notifier empties
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
  late final TextEditingController _summary = TextEditingController(
    text: switch (ref.read(changesProvider)) {
      ChangesReady(message: final String message) => message,
      _ => '',
    },
  );
  late final TextEditingController _description = TextEditingController(
    text: switch (ref.read(changesProvider)) {
      ChangesReady(description: final String description) => description,
      _ => '',
    },
  );
  late final FocusNode _summaryFocus = FocusNode()..addListener(_refocused);
  late final FocusNode _descriptionFocus = FocusNode()..addListener(_refocused);

  void _refocused() => setState(() {});

  @override
  void dispose() {
    _summaryFocus
      ..removeListener(_refocused)
      ..dispose();
    _descriptionFocus
      ..removeListener(_refocused)
      ..dispose();
    _summary.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A commit that landed empties the draft, and the fields are the only
    // place still holding the old text. A merge's draft arriving fills an
    // empty summary the same way.
    ref.listen<ChangesState>(changesProvider, (
      ChangesState? previous,
      ChangesState next,
    ) {
      if (next is! ChangesReady) {
        return;
      }
      if (next.message != _summary.text &&
          (next.message.isEmpty || _summary.text.isEmpty)) {
        _summary.text = next.message;
      }
      if (next.description.isEmpty && _description.text.isNotEmpty) {
        _description.clear();
      }
    });
    final TomColors colors = TomColors.of(context);
    final bool isFocused = _summaryFocus.hasFocus || _descriptionFocus.hasFocus;
    final ChangesNotifier changes = ref.read(changesProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ChangesDesign.inset),
      child: Container(
        height: ChangesDesign.messageHeight,
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(ChangesDesign.radius),
          border: Border.all(color: isFocused ? colors.accent : colors.border),
        ),
        // The stroke is painted inside the box, so the board's inset is the
        // pad less the stroke.
        padding: const EdgeInsets.fromLTRB(
          ChangesDesign.messagePad,
          ChangesDesign.messageTop,
          ChangesDesign.messagePad,
          ChangesDesign.messageTop,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _summary,
              focusNode: _summaryFocus,
              onChanged: changes.describe,
              // Enter moves to the description, the way a message is written.
              onSubmitted: (_) => _descriptionFocus.requestFocus(),
              cursorColor: colors.accent,
              cursorWidth: 1,
              style: TextStyle(
                fontSize: ChangesDesign.message,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration.collapsed(
                hintText: context.l10n.changesSummaryHint,
                hintStyle: TextStyle(
                  fontSize: ChangesDesign.message,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: ChangesDesign.descriptionGap),
            Expanded(
              child: TextField(
                controller: _description,
                focusNode: _descriptionFocus,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: changes.describeBody,
                cursorColor: colors.accent,
                cursorWidth: 1,
                style: TextStyle(
                  fontSize: ChangesDesign.description,
                  height: 1.4,
                  color: colors.textSecondary,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: context.l10n.changesDescriptionHint,
                  hintStyle: TextStyle(
                    fontSize: ChangesDesign.description,
                    height: 1.4,
                    color: colors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
