/// The one chevron the app draws, in both directions.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A chevron: pointing down when open, right when closed.
///
/// The icon set's own path (`docs/design/components/icons/chevron.svg`),
/// painted rather than loaded, so the glyph costs no dependency — the
/// alternative `flutter_svg` is a licence check for nine shapes
/// (`docs/design/components/icons.md`).
///
/// **Filled, not stroked** — VS Code's codicon path, which is what every
/// board draws (`design/screens/desktop/workspace/shell-dark.svg` fills it;
/// nothing there strokes a chevron). The path is off-centre in its box by
/// the third of a unit the codicon is off-centre by, which is the alignment:
/// the ink is the glyph, so nothing is nudged on top of it.
class TomChevronWidget extends StatelessWidget {
  /// Creates a chevron of [size], pointing down when [isOpen].
  const TomChevronWidget({
    required this.isOpen,
    required this.color,
    this.size = 16,
    super.key,
  });

  /// Whether what it opens is open, which is what it points at.
  final bool isOpen;

  /// The ink.
  final Color color;

  /// The box it is drawn in, 16 where the boards put one.
  final double size;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isOpen', isOpen))
      ..add(ColorProperty('color', color))
      ..add(DoubleProperty('size', size));
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _ChevronPainter(isOpen: isOpen, color: color),
    ),
  );
}

/// The path, at whatever size the box is.
class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.isOpen, required this.color});

  final bool isOpen;
  final Color color;

  /// The grid the path is written on, which every number below is in.
  static const double _grid = 16;

  /// The codicon, pointing right, read off the boards at 16 units.
  ///
  /// The turn to down is a transpose rather than a second list, so the two
  /// states cannot drift apart.
  static const List<Offset> _pointingRight = <Offset>[
    Offset(10.072, 8.024),
    Offset(5.715, 3.667),
    Offset(6.333, 3.047),
    Offset(11, 7.716),
    Offset(11, 8.334),
    Offset(6.333, 13),
    Offset(5.715, 12.381),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.width / _grid;
    final Paint ink = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    for (int i = 0; i < _pointingRight.length; i++) {
      final Offset it = _pointingRight[i];
      final Offset at = (isOpen ? Offset(it.dy, it.dx) : it) * unit;
      i == 0 ? path.moveTo(at.dx, at.dy) : path.lineTo(at.dx, at.dy);
    }
    canvas.drawPath(path..close(), ink);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) =>
      old.isOpen != isOpen || old.color != color;
}
