/// The one box the compare surface has.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/compare/compare_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Narrows both lists at once, because a name is a name.
///
/// The controller is the draft while this is on screen, seeded once and
/// pushing every keystroke up: a field re-seeded under a cursor loses what
/// was being typed.
class CompareFieldWidget extends ConsumerStatefulWidget {
  /// Creates the box, labelled [hint].
  const CompareFieldWidget({required this.hint, super.key});

  /// What the box is for, in the words the design uses.
  final String hint;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('hint', hint));
  }

  @override
  ConsumerState<CompareFieldWidget> createState() => _CompareFieldWidgetState();
}

class _CompareFieldWidgetState extends ConsumerState<CompareFieldWidget> {
  late final TextEditingController _controller = TextEditingController(
    text: switch (ref.read(compareProvider)) {
      CompareReady(draft: final String draft) => draft,
      _ => '',
    },
  );
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // The surface exists to be typed into; reaching for the mouse to click
    // the box would be a step nobody wants.
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
    final TomColors colors = TomColors.of(context);
    final TextStyle style = TextStyle(
      fontSize: CompareDesign.note,
      height: 1.4,
      color: colors.textPrimary,
    );
    return SizedBox(
      height: CompareDesign.fieldHeight,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        onChanged: ref.read(compareProvider.notifier).type,
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
    borderRadius: BorderRadius.circular(CompareDesign.radius),
    borderSide: BorderSide(color: color),
  );
}
