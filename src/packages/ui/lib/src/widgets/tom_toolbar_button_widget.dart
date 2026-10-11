/// One cell of the formatting bar.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';
import 'package:tom_ui/src/theme/tom_metrics.dart';
import 'package:tom_ui/src/widgets/tom_glyph_widget.dart';
import 'package:tom_ui/src/widgets/tom_outline.dart';
import 'package:tom_ui/src/widgets/tom_toolbar_outlines.dart';

/// The toolbar button of
/// [components](../../../../../../docs/design/components/controls.md): a 28
/// square on the raised surface, carrying one Material Symbols glyph (weight
/// 300) about 14-16 tall in ink (the library's 24 is the `Icon` box, not the
/// ink). Every other icon in the app stays Font Awesome Solid.
///
/// A component rather than a rectangle because seventeen of them are the
/// [formatting bar](../../../../../../docs/product/editor/formatting-shortcuts/doc.md)
/// and nothing else in the app repeats a control that many times. **A button
/// with nothing to act on is disabled, never absent** — a toolbar that
/// reflows is harder to use than a dim one.
class TomToolbarButtonWidget extends StatelessWidget {
  /// Creates the cell for [glyph], drawn from [outline] when given.
  const TomToolbarButtonWidget({
    required this.glyph,
    required this.tooltip,
    required this.onPressed,
    this.outline,
    super.key,
  });

  /// The cell the boards draw.
  static const double size = 28;

  /// The box the glyph's grid is scaled to, centred in the cell.
  ///
  /// **Tuned by eye** (the Penpot prototype of 2026-10-11): Material's 24
  /// grid in a 22 box inks about 14-16, like the board's `Icon`.
  static const double glyphBox = 22;

  /// The size of the `⋯` that collapses a narrow row, which stays a Font
  /// Awesome glyph (14.5, as tuned by eye on 2026-10-11).
  static const double moreSize = 14.5;

  /// How much of `text_muted` an unavailable button's glyph keeps.
  static const double unavailableInk = 0.6;

  /// Which glyph.
  final TomGlyphEnum glyph;

  /// Another source for the glyph, or null for the one in
  /// [tomToolbarOutlines] — a hand-drawn SVG goes through the same widget.
  final TomOutline? outline;

  /// The whole word, for whoever does not read the shape.
  final String tooltip;

  /// What it does, or null while it cannot do it.
  final VoidCallback? onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<TomGlyphEnum>('glyph', glyph))
      ..add(DiagnosticsProperty<TomOutline?>('outline', outline))
      ..add(StringProperty('tooltip', tooltip))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    // Fainter than the muted role alone: with no fill and no label, that
    // sits too close to a live button's ink to be told from it.
    final Color ink = onPressed == null
        ? colors.textMuted.withValues(alpha: unavailableInk)
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
              child: ExcludeSemantics(
                child: CustomPaint(
                  size: const Size.square(glyphBox),
                  painter: TomOutlinePainter(
                    outline ?? tomToolbarOutlines[glyph]!,
                    ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
