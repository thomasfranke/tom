/// The text a small field holds.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';

/// A field with no decoration of its own, for use inside
/// [TomFieldBoxWidget](tom_field_box_widget.dart).
///
/// Collapsed on purpose: the box around it is what draws the fill, the
/// hairline and the height, so this contributes only the text and the caret.
class TomFieldWidget extends StatelessWidget {
  /// Creates the field.
  const TomFieldWidget({
    required this.controller,
    required this.hint,
    required this.fontSize,
    this.focusNode,
    this.onChanged,
    this.onSubmit,
    this.pad = 12,
    this.fontWeight = FontWeight.w400,
    this.autofocus = false,
    super.key,
  });

  /// Called on Enter. **The field keeps the keyboard**, so a refusal can be
  /// corrected where it was typed.
  final VoidCallback? onSubmit;

  /// The weight of what is typed; the hint keeps the regular cut.
  final FontWeight fontWeight;

  /// Whether it takes the keyboard as soon as it is built.
  final bool autofocus;

  /// What it holds, and who else can read it.
  final TextEditingController controller;

  /// What it says while it is empty.
  final String hint;

  /// The size of both.
  final double fontSize;

  /// Whose focus it takes, when the box around it draws that focus.
  final FocusNode? focusNode;

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  /// The inset from the box's edge.
  final double pad;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('hint', hint))
      ..add(DoubleProperty('fontSize', fontSize))
      ..add(DoubleProperty('pad', pad))
      ..add(DiagnosticsProperty<FontWeight>('fontWeight', fontWeight))
      ..add(DiagnosticsProperty<bool>('autofocus', autofocus))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onSubmit', onSubmit))
      ..add(
        DiagnosticsProperty<TextEditingController>('controller', controller),
      )
      ..add(DiagnosticsProperty<FocusNode?>('focusNode', focusNode))
      ..add(
        ObjectFlagProperty<ValueChanged<String>?>.has('onChanged', onChanged),
      );
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: EdgeInsets.only(left: pad),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          // Given, Flutter's own unfocus-on-done is replaced by it.
          onEditingComplete: onSubmit,
          autofocus: autofocus,
          cursorColor: colors.accent,
          cursorWidth: 1,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: colors.textPrimary,
          ),
          decoration: InputDecoration.collapsed(
            hintText: hint,
            hintStyle: TextStyle(fontSize: fontSize, color: colors.textMuted),
          ),
        ),
      ),
    );
  }
}
