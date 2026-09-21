/// The wordmark, drawn rather than loaded.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// TOM, with the O as the commit on the trunk.
///
/// **Drawn from the master's own numbers**, transcribed from
/// [`brand/tom-wordmark-light.svg`](../../../../../docs/technical/design/brand/tom-wordmark-light.svg),
/// which `tools/brand.py` generates. Brand rule 1 is that the commit is
/// never redrawn — the ring and the trunk here are the same geometry as the
/// icon's, not an approximation of it, so a change in `brand.py` is a change
/// of these numbers and nothing else.
///
/// Painted rather than rendered from the SVG because every segment is a
/// straight line or a circle: an SVG package would be a dependency
/// ([rule 1](../../../../../AGENTS.md)) earning its keep on four shapes. The
/// letters are Sora Bold outlines, extracted once into the master — which is
/// also why no font has to be installed for the wordmark to be right.
class TomWordmark extends StatelessWidget {
  /// Creates the wordmark [capHeight] tall in its capitals.
  const TomWordmark({
    required this.letters,
    required this.commit,
    this.capHeight = 60,
    super.key,
  });

  /// The colour of the T and the M — `textPrimary`, in either mode.
  final Color letters;

  /// The colour of the ring and the trunk — `accent`.
  final Color commit;

  /// How tall the capitals are.
  ///
  /// **Cap height sizes the mark** (brand rule 2), never the box: the
  /// trunk's reach above and below is part of it, so the widget is taller
  /// than this number and that is correct. The empty state uses 60, which is
  /// the design's `type.brand`.
  final double capHeight;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('letters', letters))
      ..add(ColorProperty('commit', commit))
      ..add(DoubleProperty('capHeight', capHeight));
  }

  @override
  Widget build(BuildContext context) {
    final double scale = capHeight / _capHeight;
    return SizedBox(
      width: _boxWidth * scale,
      height: _boxHeight * scale,
      child: CustomPaint(
        painter: _WordmarkPainter(
          letters: letters,
          commit: commit,
          scale: scale,
        ),
      ),
    );
  }

  /// The letters run from y 0 to y 146 in the master.
  static const double _capHeight = 146;

  /// The master's viewBox: `4.4 -35.04 477.8 216.08`.
  static const double _boxWidth = 477.8;
  static const double _boxHeight = 216.08;
  static const double _left = 4.4;
  static const double _top = -35.04;
}

/// Paints the master at [scale].
class _WordmarkPainter extends CustomPainter {
  const _WordmarkPainter({
    required this.letters,
    required this.commit,
    required this.scale,
  });

  final Color letters;
  final Color commit;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(scale)
      ..translate(-TomWordmark._left, -TomWordmark._top);

    final Paint ink = Paint()..color = letters;
    canvas
      ..drawPath(_letterT(), ink)
      ..drawPath(_letterM(), ink);

    // The trunk pokes past the cap line and the baseline — the one place the
    // wordmark leaves the text line, and the reason cap height sizes it.
    final Paint stroke = Paint()
      ..color = commit
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 19.68;
    canvas
      ..drawLine(const Offset(212.1, -35.04), const Offset(212.1, 12), stroke)
      ..drawLine(
        const Offset(212.1, 133.4),
        const Offset(212.1, 181.04),
        stroke,
      )
      ..drawCircle(
        const Offset(212.1, 72.7),
        60.7,
        Paint()
          ..color = commit
          ..style = PaintingStyle.stroke
          ..strokeWidth = 32.8,
      )
      ..restore();
  }

  /// `M45.4 146.0V24.6H78.2V146.0ZM4.4 28.6V0.0H119.4V28.6Z` — stem and bar.
  Path _letterT() => Path()
    ..addRect(const Rect.fromLTRB(45.4, 24.6, 78.2, 146))
    ..addRect(const Rect.fromLTRB(4.4, 0, 119.4, 28.6));

  /// The M's outline, point for point from the master.
  Path _letterM() {
    final Path path = Path()..moveTo(320.8, 146);
    for (final Offset point in const <Offset>[
      Offset(320.8, 0),
      Offset(366, 0),
      Offset(399.4, 82),
      Offset(403.2, 82),
      Offset(436.2, 0),
      Offset(482.2, 0),
      Offset(482.2, 146),
      Offset(449.8, 146),
      Offset(449.8, 21.4),
      Offset(454.4, 21.8),
      Offset(415.8, 116.4),
      Offset(384.6, 116.4),
      Offset(345.8, 21.8),
      Offset(350.8, 21.4),
      Offset(350.8, 146),
    ]) {
      path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_WordmarkPainter old) =>
      old.letters != letters || old.commit != commit || old.scale != scale;
}
