/// One cell of the formatting bar.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';
import 'package:tom_ui/src/theme/tom_metrics.dart';
import 'package:tom_ui/src/widgets/tom_glyph_widget.dart';

/// The toolbar button of
/// [components](../../../../../../docs/design/components/controls.md): a 28
/// square on the raised surface, carrying one glyph at 16.
///
/// A component rather than a rectangle because seventeen of them are the
/// [formatting bar](../../../../../../docs/product/editor/formatting-shortcuts/doc.md)
/// and nothing else in the app repeats a control that many times. **A button
/// with nothing to act on is disabled, never absent** — a toolbar that
/// reflows is harder to use than a dim one.
class TomToolbarButtonWidget extends StatelessWidget {
  /// Creates the cell for [glyph].
  const TomToolbarButtonWidget({
    required this.glyph,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  /// The cell the boards draw.
  static const double size = 24;

  /// The glyph inside it, centred.
  static const double glyphSize = 15;

  /// Which glyph.
  final TomGlyphEnum glyph;

  /// The whole word, for whoever does not read the shape.
  final String tooltip;

  /// What it does, or null while it cannot do it.
  final VoidCallback? onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<TomGlyphEnum>('glyph', glyph))
      ..add(StringProperty('tooltip', tooltip))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final Color ink = onPressed == null
        ? colors.textMuted
        : colors.textSecondary;
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: size,
        // Flat on the island: a 1b toolbar is glyphs, and the hover is
        // what says one is a button.
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
            child: Center(
              child: TomGlyphWidget(glyph: glyph, color: ink, size: glyphSize),
            ),
          ),
        ),
      ),
    );
  }
}
