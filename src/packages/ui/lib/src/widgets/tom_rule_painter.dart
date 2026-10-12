/// A one-point rule laid on whole device pixels.
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Paints a rule that lands on one row of pixels wherever its box sits.
///
/// A `Divider` is a box one point tall, and a box whose offset is a fraction
/// (a line of text 16.1 tall above it) smears into two half-lit rows; a board
/// draws one row in the authored colour. The painter reads where the canvas
/// is on the device and rounds its own edges there.
class TomRulePainter extends CustomPainter {
  /// Creates the painter of a rule in [color].
  const TomRulePainter(this.color);

  /// The rule's colour.
  final Color color;

  /// The rule as a widget as wide as its parent, plus [bleed] past both
  /// edges — the boards' menus run a rule to the card's stroke.
  static Widget of(Color color, {double bleed = 0}) => SizedBox(
    height: 1,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth + bleed * 2;
        return OverflowBox(
          minWidth: width,
          maxWidth: width,
          minHeight: 1,
          maxHeight: 1,
          child: CustomPaint(
            size: Size(width, 1),
            painter: TomRulePainter(color),
          ),
        );
      },
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Float64List m = canvas.getTransform();
    final double scaleX = m[0];
    final double scaleY = m[5];
    final Paint paint = Paint()
      ..color = color
      ..isAntiAlias = false;
    if (scaleX == 0 || scaleY == 0) {
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }
    final double left = (m[12].roundToDouble() - m[12]) / scaleX;
    final double right =
        ((m[12] + size.width * scaleX).roundToDouble() - m[12]) / scaleX;
    final double top = (m[13].roundToDouble() - m[13]) / scaleY;
    canvas.drawRect(Rect.fromLTRB(left, top, right, top + size.height), paint);
  }

  @override
  bool shouldRepaint(TomRulePainter oldDelegate) => oldDelegate.color != color;
}
