/// The brand icon, drawn for the About dialog.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The cream icon, `docs/design/brand/tom-icon.svg`: a tile, a page with its
/// fold, and the commit cut out of it on the trunk.
///
/// Painted rather than loaded, from the master's own numbers (a 512 box), for
/// the reason the wordmark is: straight lines and a circle do not earn an SVG
/// dependency. The colours are the brand's and not the theme's — the boards
/// draw the cream icon in both themes (`about-tom-dark.svg`).
class AboutIconWidget extends StatelessWidget {
  /// Creates the icon, [size] square.
  const AboutIconWidget({this.size = 56, super.key});

  /// The tile's side — 56 where the dialog draws it.
  final double size;

  /// The tile, `surface_raised` of the light palette.
  static const Color tile = Color(0xFFF6F5F1);

  /// The page, `accent` of the light palette.
  static const Color page = Color(0xFF178F71);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('size', size));
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: const CustomPaint(painter: _IconPainter()),
  );
}

/// Paints the master at the size it is given.
class _IconPainter extends CustomPainter {
  const _IconPainter();

  static const double _box = 512;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / _box)
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, _box, _box),
          const Radius.circular(112),
        ),
        Paint()..color = AboutIconWidget.tile,
      );

    // The page, its top right corner cut on the diagonal.
    final Path page = Path()
      ..moveTo(154, 64)
      ..lineTo(304, 64)
      ..lineTo(388, 148)
      ..lineTo(388, 418)
      ..quadraticBezierTo(388, 448, 358, 448)
      ..lineTo(154, 448)
      ..quadraticBezierTo(124, 448, 124, 418)
      ..lineTo(124, 94)
      ..quadraticBezierTo(124, 64, 154, 64)
      ..close();
    canvas.drawPath(page, Paint()..color = AboutIconWidget.page);

    // Everything drawn on the page is cut out in the tile's colour.
    final Paint cut = Paint()
      ..color = AboutIconWidget.tile
      ..style = PaintingStyle.stroke;
    canvas
      ..drawPath(
        Path()
          ..moveTo(304, 54)
          ..lineTo(304, 148)
          ..lineTo(398, 148),
        cut
          ..strokeWidth = 20
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter,
      )
      ..drawPath(
        Path()
          ..moveTo(256, 64)
          ..lineTo(256, 211)
          ..moveTo(256, 345)
          ..lineTo(256, 448),
        cut
          ..strokeWidth = 24
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(const Offset(256, 278), 52, cut..strokeWidth = 38)
      ..restore();
  }

  @override
  bool shouldRepaint(_IconPainter old) => false;
}
