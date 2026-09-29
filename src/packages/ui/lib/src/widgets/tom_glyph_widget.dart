/// The icon set's stroked glyphs, painted rather than loaded.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Which glyph of the set to draw.
///
/// The set is fourteen files and this holds the ones a screen actually
/// leads a control with; it grows a glyph at a time, as the boards ask
/// (`docs/design/components/icons.md`).
enum TomGlyphEnum {
  /// A folder with its tab: picking one (`icons/folder.svg`).
  folder,

  /// Two links of a chain: a URL (`icons/link.svg`).
  link,
}

/// One glyph of the icon set, at the size the host control gives it.
///
/// Painted from the set's own `d`, so a glyph costs no dependency —
/// `flutter_svg` would be a licence check under
/// [rule 1](../../../../../../AGENTS.md) for fourteen shapes
/// (`docs/design/components/icons.md`). The chevron is filled and has its
/// own widget; everything here is stroked.
class TomGlyphWidget extends StatelessWidget {
  /// Creates [glyph] in [color], in a box of [size].
  const TomGlyphWidget({
    required this.glyph,
    required this.color,
    this.size = 16,
    super.key,
  });

  /// Which one.
  final TomGlyphEnum glyph;

  /// The ink, which is the host control's colour and never its own.
  final Color color;

  /// The box, 16 where the boards put one.
  final double size;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<TomGlyphEnum>('glyph', glyph))
      ..add(ColorProperty('color', color))
      ..add(DoubleProperty('size', size));
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _GlyphPainter(glyph: glyph, color: color),
    ),
  );
}

/// The paths, written on the 16 grid and scaled to whatever the box is.
class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({required this.glyph, required this.color});

  final TomGlyphEnum glyph;
  final Color color;

  /// The grid every number below is on.
  static const double _grid = 16;

  /// The stroke the set draws every glyph at.
  ///
  /// The home board renders its two at 1.5, which is the board disagreeing
  /// with the set rather than a rule: `icons.md` calls the files the source,
  /// and the twelve other glyphs are 2.
  static const double _stroke = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint ink = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..save()
      ..scale(size.width / _grid)
      ..drawPath(switch (glyph) {
        TomGlyphEnum.folder => _folder(),
        TomGlyphEnum.link => _link(),
      }, ink)
      ..restore();
  }

  /// `icons/folder.svg`.
  static Path _folder() => Path()
    ..moveTo(2, 5)
    ..cubicTo(2, 4.2, 2.6, 3.5, 3.5, 3.5)
    ..lineTo(6.5, 3.5)
    ..lineTo(8, 5)
    ..lineTo(12.5, 5)
    ..cubicTo(13.4, 5, 14, 5.6, 14, 6.5)
    ..lineTo(14, 11.5)
    ..cubicTo(14, 12.4, 13.4, 13, 12.5, 13)
    ..lineTo(3.5, 13)
    ..cubicTo(2.6, 13, 2, 12.4, 2, 11.5)
    ..close();

  /// `icons/link.svg`: the bar, then a loop at each end of it.
  static Path _link() => Path()
    ..moveTo(6.5, 9.5)
    ..lineTo(9.5, 6.5)
    ..moveTo(7, 11.5)
    ..lineTo(5.5, 13)
    ..cubicTo(4.5, 14, 2.8, 14, 2, 13)
    ..cubicTo(1.2, 12, 1.2, 10.5, 2.2, 9.6)
    ..lineTo(3.7, 8.1)
    ..moveTo(9, 4.5)
    ..lineTo(10.5, 3)
    ..cubicTo(11.5, 2, 13.2, 2, 14, 3)
    ..cubicTo(14.8, 4, 14.8, 5.5, 13.8, 6.4)
    ..lineTo(12.3, 7.9);

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}
