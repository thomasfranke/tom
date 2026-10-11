/// A command running, where its check will be.
library;

import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';

/// The spinner of
/// [components](../../../../../../docs/design/components/controls.md): a
/// 12-point ring in `border_strong` with a quarter arc in `accent` turning
/// along it.
///
/// **The one spinner in the product**: a request on the network raises the
/// progress bar instead, so this only ever says that a local command has
/// started and not yet ended.
class TomSpinnerWidget extends StatefulWidget {
  /// Creates the spinner.
  const TomSpinnerWidget({super.key});

  /// Its side.
  static const double size = 12;

  /// The ring's stroke.
  static const double stroke = 1.5;

  /// One turn.
  static const Duration turn = Duration(milliseconds: 900);

  @override
  State<TomSpinnerWidget> createState() => _TomSpinnerWidgetState();
}

class _TomSpinnerWidgetState extends State<TomSpinnerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turning = AnimationController(
    vsync: this,
    duration: TomSpinnerWidget.turn,
  )..repeat();

  @override
  void dispose() {
    _turning.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox.square(
      dimension: TomSpinnerWidget.size,
      child: CustomPaint(
        painter: _SpinnerPainter(
          ring: colors.borderStrong,
          arc: colors.accent,
          turning: _turning,
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({
    required this.ring,
    required this.arc,
    required this.turning,
  }) : super(repaint: turning);

  final Color ring;
  final Color arc;
  final Animation<double> turning;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect box = Offset.zero & size;
    final Rect inside = box.deflate(TomSpinnerWidget.stroke / 2);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = TomSpinnerWidget.stroke
      ..strokeCap = StrokeCap.round
      ..color = ring;
    canvas.drawArc(inside, 0, 6.283185307179586, false, paint);
    paint.color = arc;
    // A quarter of the ring, starting wherever the turn has got to.
    final double start = turning.value * 6.283185307179586 - 1.5707963267948966;
    canvas.drawArc(inside, start, 1.5707963267948966, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.ring != ring || old.arc != arc;
}
