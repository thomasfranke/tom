/// A way forward that is not open yet.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// A way forward that is not open yet; always disabled, the chip beside it
/// says when.
class HomeSecondaryButtonWidget extends StatelessWidget {
  /// Creates a disabled button saying [label], led by [glyph].
  const HomeSecondaryButtonWidget({
    required this.label,
    required this.glyph,
    super.key,
  });

  /// What it says.
  final String label;

  /// The 16-unit glyph before the label
  /// (`docs/design/screens/desktop/home/empty-state-dark.svg`).
  final TomGlyphEnum glyph;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(EnumProperty<TomGlyphEnum>('glyph', glyph));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return OutlinedButton(
      onPressed: null,
      style: OutlinedButton.styleFrom(
        disabledForegroundColor: colors.textMuted,
        side: BorderSide(color: colors.borderStrong),
        fixedSize: const Size(HomeDesign.column, HomeDesign.control),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HomeDesign.controlRadius),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TomGlyphWidget(glyph: glyph, color: colors.textMuted),
          const SizedBox(width: HomeDesign.glyphToLabel),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
