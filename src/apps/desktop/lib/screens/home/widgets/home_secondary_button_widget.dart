/// The second way forward.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// The library's `Secondary` button at the column's width, or its `Disabled`
/// kind while [onPressed] is null
/// ([controls](../../../../../../../docs/design/components/controls.md)).
class HomeSecondaryButtonWidget extends StatelessWidget {
  /// Creates a button saying [label], led by [glyph].
  const HomeSecondaryButtonWidget({
    required this.label,
    required this.glyph,
    required this.onPressed,
    super.key,
  });

  /// What it says.
  final String label;

  /// The 16-unit glyph before the label
  /// (`docs/design/screens/desktop/home/empty-state-dark.svg`).
  final TomGlyphEnum glyph;

  /// What it does, or null where it cannot act.
  final VoidCallback? onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(EnumProperty<TomGlyphEnum>('glyph', glyph))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final Color ink = onPressed == null
        ? colors.textMuted
        : colors.textSecondary;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textSecondary,
        disabledForegroundColor: colors.textMuted,
        // Unavailable is a kind, not a state: a sunken well with no outline,
        // so a control that is off does not keep the outline of one that is
        // on.
        disabledBackgroundColor: colors.surfaceSunken,
        side: onPressed == null
            ? BorderSide.none
            : BorderSide(color: colors.borderStrong),
        fixedSize: const Size(HomeDesign.column, HomeDesign.control),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HomeDesign.controlRadius),
        ),
        // Restated for the reason `HomePrimaryButtonWidget` gives.
        textStyle: const TextStyle(
          fontFamily: TomFonts.sans,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TomGlyphWidget(glyph: glyph, color: ink),
          const SizedBox(width: HomeDesign.glyphToLabel),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
