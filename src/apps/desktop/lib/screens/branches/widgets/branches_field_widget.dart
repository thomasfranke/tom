/// The one box the switcher has, whichever thing it currently means.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/branches/branches_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The filter, or the name of the branch about to be started.
///
/// One box because the state holds one string, so a filter for a branch that
/// does not exist is already typed as its name. The controller is seeded
/// once and cleared only when the notifier empties the draft: re-seeding
/// under a cursor loses what is being typed.
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
  late final FocusNode _focus = FocusNode()..addListener(_focusChanged);

  void _focusChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    // The surface exists to be typed into; nobody should have to click first.
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus
      ..removeListener(_focusChanged)
      ..dispose();
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
    // Drawn, not decorated: an `InputDecoration` sized the box from its
    // content and the empty field collapsed under its own caret.
    return TomFieldBoxWidget(
      height: BranchesDesign.fieldHeight,
      fill: TomColors.of(context).surfaceSunken,
      isFocused: _focus.hasFocus,
      radius: BranchesDesign.radius,
      child: TomFieldWidget(
        controller: _controller,
        focusNode: _focus,
        onChanged: ref.read(branchesProvider.notifier).type,
        hint: widget.hint,
        fontSize: BranchesDesign.note,
      ),
    );
  }
}
