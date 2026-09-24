/// The one box the switcher has, whichever thing it currently means.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/branches/branches_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Filters the branches, or names the one about to be started.
///
/// **One box, because the state holds one string** — which of the two it
/// means is [hint]'s to say. Filtering for a branch that turns out not to
/// exist therefore leaves its name already typed, which is the useful way
/// round.
///
/// The controller is the draft while this is on screen, seeded once and
/// pushing every keystroke up: a field re-seeded under a cursor loses what
/// was being typed. It is re-seeded only when the notifier empties the
/// draft, which is what a switch that landed does.
class BranchesFieldWidget extends ConsumerStatefulWidget {
  /// Creates the box, labelled [hint].
  const BranchesFieldWidget({required this.hint, super.key});

  /// What the box is for, in the words the design uses.
  final String hint;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('hint', hint));
  }

  @override
  ConsumerState<BranchesFieldWidget> createState() =>
      _BranchesFieldWidgetState();
}

class _BranchesFieldWidgetState extends ConsumerState<BranchesFieldWidget> {
  late final TextEditingController _controller = TextEditingController(
    text: switch (ref.read(branchesProvider)) {
      BranchesReady(draft: final String draft) => draft,
      _ => '',
    },
  );
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // The surface exists to be typed into; opening it and then reaching for
    // the mouse to click the box would be a step nobody wants.
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BranchesState>(branchesProvider, (
      BranchesState? previous,
      BranchesState next,
    ) {
      final bool emptied = next is BranchesReady && next.draft.isEmpty;
      if (emptied && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    });
    final TomColors colors = TomColors.of(context);
    final TextStyle style = TextStyle(
      fontSize: BranchesDesign.note,
      height: 1.4,
      color: colors.textPrimary,
    );
    return SizedBox(
      height: BranchesDesign.fieldHeight,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        onChanged: ref.read(branchesProvider.notifier).type,
        style: style,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: style.copyWith(color: colors.textMuted),
          filled: true,
          fillColor: colors.surfaceSunken,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: _border(colors.border),
          enabledBorder: _border(colors.border),
          focusedBorder: _border(colors.accent),
        ),
      ),
    );
  }

  /// The box's outline in [color].
  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(BranchesDesign.radius),
    borderSide: BorderSide(color: color),
  );
}
