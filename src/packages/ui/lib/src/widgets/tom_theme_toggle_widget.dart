/// The control that switches light and dark.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';

/// The `Theme toggle` component: a circle with one half filled
/// ([controls](../../../../../../docs/design/components/controls.md)).
///
/// Half filled rather than a sun and a moon, so it reads as the same set as
/// the panel toggles beside it — one outline, one half of it inked
/// (`docs/product/workspace/columns/doc.md`).
class TomThemeToggleWidget extends StatelessWidget {
  /// Creates the control at [size], filled on the side [isDark] decides.
  const TomThemeToggleWidget({
    required this.isDark,
    required this.size,
    required this.stroke,
    super.key,
  });

  /// Which theme is drawn now; it fills the opposite half.
  final bool isDark;

  /// The circle's diameter.
  final double size;

  /// Its outline.
  final double stroke;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isDark', isDark))
      ..add(DoubleProperty('size', size))
      ..add(DoubleProperty('stroke', stroke));
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _ThemePainter(
      ink: TomColors.of(context).textSecondary,
      isDark: isDark,
      stroke: stroke,
    ),
  );
}

/// The circle, and the half of it that is inked.
class _ThemePainter extends CustomPainter {
  const _ThemePainter({
    required this.ink,
    required this.isDark,
    required this.stroke,
  });

  final Color ink;
  final bool isDark;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect box =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    canvas
      ..drawArc(
        box,
        0,
        6.2831853,
        false,
        Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      )
      // Half a turn from the top, so the filled half is the left one in
      // light and the right one in dark: the control shows what the other
      // theme would be.
      ..drawArc(
        box,
        isDark ? -1.5707963 : 1.5707963,
        3.1415927,
        true,
        Paint()..color = ink,
      );
  }

  @override
  bool shouldRepaint(_ThemePainter old) =>
      old.ink != ink || old.isDark != isDark || old.stroke != stroke;
}
