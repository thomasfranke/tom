/// The primary way forward.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// The primary way forward.
class HomePrimaryButtonWidget extends StatelessWidget {
  /// Creates a button saying [label], led by [glyph] when there is one.
  const HomePrimaryButtonWidget({
    required this.label,
    required this.onPressed,
    this.glyph,
    this.width = HomeDesign.column,
    super.key,
  });

  /// What it says.
  final String label;

  /// The 16-unit glyph before the label, or null where the board draws none.
  ///
  /// `empty-state` leads `Choose folder…` with one; `not-a-repository` leads
  /// `Choose another folder…` with nothing, because that screen is already
  /// saying what went wrong and a second folder glyph adds no word to it.
  final TomGlyphEnum? glyph;

  /// What it does.
  final VoidCallback onPressed;

  /// How wide the design draws it.
  final double width;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(EnumProperty<TomGlyphEnum?>('glyph', glyph))
      ..add(DoubleProperty('width', width))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.surfaceRaised,
        fixedSize: Size(width, HomeDesign.control),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HomeDesign.controlRadius),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (glyph case final TomGlyphEnum it) ...<Widget>[
            TomGlyphWidget(glyph: it, color: colors.surfaceRaised),
            const SizedBox(width: HomeDesign.glyphToLabel),
          ],
          // Flexible so the label can still use the room the button has:
          // in a row that sizes to its children a sentence simply grows,
          // and the retry's is longer than its button is wide.
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
