/// The control that hides a column.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';

/// Which side of the control the strip is on.
enum TomPanelSideEnum {
  /// The left column's toggle: the strip is at the left.
  left,

  /// The right column's: the strip is at the right.
  right,
}

/// The `Panel toggle` component: an outline with a divider inside it, and
/// the strip filled while that column is open
/// ([controls](../../../../../../docs/design/components/controls.md)).
///
/// **Outline and divider are always drawn.** A bare outline says which
/// column the control belongs to; an outline with nothing in it says
/// nothing, which is why the empty state still has its divider
/// (`docs/product/workspace/columns/doc.md`).
class TomPanelToggleWidget extends StatelessWidget {
  /// Creates the toggle for [side], filled while [isOpen].
  const TomPanelToggleWidget({
    required this.side,
    required this.isOpen,
    required this.width,
    required this.height,
    required this.radius,
    required this.stroke,
    required this.strip,
    super.key,
  });

  /// Which column it belongs to.
  final TomPanelSideEnum side;

  /// Whether that column is on screen.
  final bool isOpen;

  /// The control's width.
  final double width;

  /// Its height.
  final double height;

  /// Its corner.
  final double radius;

  /// The outline's width, which the divider and the strip share.
  final double stroke;

  /// How far in from its own edge the divider sits.
  final double strip;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<TomPanelSideEnum>('side', side))
      ..add(DiagnosticsProperty<bool>('isOpen', isOpen))
      ..add(DoubleProperty('width', width))
      ..add(DoubleProperty('height', height))
      ..add(DoubleProperty('radius', radius))
      ..add(DoubleProperty('stroke', stroke))
      ..add(DoubleProperty('strip', strip));
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, height),
    painter: _TogglePainter(
      ink: TomColors.of(context).textSecondary,
      side: side,
      isOpen: isOpen,
      radius: radius,
      stroke: stroke,
      strip: strip,
    ),
  );
}

/// The outline, the divider, and the strip when it is filled.
class _TogglePainter extends CustomPainter {
  const _TogglePainter({
    required this.ink,
    required this.side,
    required this.isOpen,
    required this.radius,
    required this.stroke,
    required this.strip,
  });

  final Color ink;
  final TomPanelSideEnum side;
  final bool isOpen;
  final double radius;
  final double stroke;
  final double strip;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect box = RRect.fromRectAndRadius(
      Offset(stroke / 2, stroke / 2) &
          Size(size.width - stroke, size.height - stroke),
      Radius.circular(radius),
    );
    final Paint line = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final double at = side == TomPanelSideEnum.left
        ? strip
        : size.width - strip;
    if (isOpen) {
      // The strip is filled by clipping the outline's own shape, so the fill
      // takes the corner with it rather than squaring it off.
      canvas
        ..save()
        ..clipRect(
          side == TomPanelSideEnum.left
              ? Rect.fromLTRB(0, 0, at, size.height)
              : Rect.fromLTRB(at, 0, size.width, size.height),
        )
        ..drawRRect(box, Paint()..color = ink)
        ..restore();
    }
    canvas
      ..drawRRect(box, line)
      ..drawLine(Offset(at, stroke), Offset(at, size.height - stroke), line);
  }

  @override
  bool shouldRepaint(_TogglePainter old) =>
      old.ink != ink ||
      old.side != side ||
      old.isOpen != isOpen ||
      old.radius != radius ||
      old.stroke != stroke ||
      old.strip != strip;
}
