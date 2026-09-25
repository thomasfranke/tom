/// The wordmark, drawn rather than loaded.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// TOM, with the O as the commit on the trunk, drawn from the master's own
/// numbers ([TomMark]) because brand rule 1 says the commit is never redrawn:
/// [`brand/tom-wordmark-light.svg`](../../../../../../docs/technical/design/brand/tom-wordmark-light.svg).
///
/// Painted rather than loaded, since straight lines and a circle do not earn
/// an SVG dependency; the letters are Sora Bold outlines, needing no font.
class TomWordmarkWidget extends StatelessWidget {
  /// Creates the wordmark [capHeight] tall in its capitals.
  const TomWordmarkWidget({
    required this.letters,
    required this.commit,
    this.capHeight = 60,
    super.key,
  });

  /// The colour of the T and the M — `textPrimary`, in either mode.
  final Color letters;

  /// The colour of the ring and the trunk — `accent`.
  final Color commit;

  /// How tall the capitals are — brand rule 2, cap height sizes the mark, so
  /// the widget is taller than this by the trunk's reach. Home uses 60, the
  /// design's `type.brand`.
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
    final double scale = capHeight / TomMark.capHeight;
    return SizedBox(
      width: TomMark.boxWidth * scale,
      height: TomMark.boxHeight * scale,
      child: CustomPaint(
        painter: _WordmarkPainter(
          letters: letters,
          commit: commit,
          scale: scale,
        ),
      ),
    );
  }
}

/// The master's own numbers, in the master's own units.
///
/// Public so whatever continues the mark — the trunk behind Home — starts
/// where the letterform stops, from one transcription rather than two.
abstract final class TomMark {
  /// The height of the letters, which run from y 0 to y 146.
  static const double capHeight = 146;

  /// The width of the master's viewBox, `4.4 -35.04 477.8 216.08`.
  static const double boxWidth = 477.8;

  /// Its height, taller than the letters by the trunk's reach.
  static const double boxHeight = 216.08;

  /// Its left edge.
  static const double left = 4.4;

  /// Its top, where the trunk's upper tip reaches.
  static const double top = -35.04;

  /// The O's centre.
  static const Offset commitCentre = Offset(212.1, 72.7);

  /// The radius of the ring drawn through that centre.
  static const double commitRadius = 60.7;

  /// The weight of that ring.
  static const double commitStroke = 32.8;

  /// The weight of the trunk the commit sits on.
  static const double trunkStroke = 19.68;

  /// Where the letterform's trunk stops above the commit.
  static const double trunkAbove = 12;

  /// Where it picks up again below.
  static const double trunkBelow = 133.4;

  /// How far the commit reaches from its centre — the break the trunk keeps.
  static const double commitReach = commitRadius + commitStroke / 2;
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
      ..translate(-TomMark.left, -TomMark.top);

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
