/// One cell of the formatting bar.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';
import 'package:tom_ui/src/theme/tom_metrics.dart';
import 'package:tom_ui/src/widgets/tom_glyph_widget.dart';

/// The toolbar button of
/// [components](../../../../../../docs/design/components/controls.md): a 28
/// square on the raised surface, carrying one glyph at 24.
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
    this.letter,
    super.key,
  });

  /// The cell the boards draw.
  static const double size = 28;

  /// The glyph inside it, centred.
  static const double glyphSize = 24;

  /// A letterform instead of a glyph, which the boards set larger than a
  /// label because it is standing in for a 24 icon.
  static const double letterSize = 20;

  /// Which glyph, or the one [letter] replaces.
  final TomGlyphEnum? glyph;

  /// A letterform instead of a glyph — `B` and `I`, which are letters
  /// everywhere and would be a worse icon than themselves.
  final String? letter;

  /// The whole word, for whoever does not read the shape.
  final String tooltip;

  /// What it does, or null while it cannot do it.
  final VoidCallback? onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<TomGlyphEnum?>('glyph', glyph))
      ..add(StringProperty('letter', letter))
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
        child: Material(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(TomMetrics.radius),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(TomMetrics.radius),
            child: Center(
              child: letter != null
                  ? Text(
                      letter!,
                      style: TextStyle(
                        fontSize: letterSize,
                        height: 1,
                        // `B` bold and `I` italic: the letterform is the
                        // icon, so it carries what it means.
                        fontWeight: letter == 'B'
                            ? FontWeight.w700
                            : FontWeight.w400,
                        fontStyle: letter == 'I'
                            ? FontStyle.italic
                            : FontStyle.normal,
                        color: ink,
                      ),
                    )
                  : TomGlyphWidget(
                      glyph: glyph!,
                      color: ink,
                      size: glyphSize,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
