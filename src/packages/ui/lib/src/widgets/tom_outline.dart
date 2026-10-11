/// An icon as an outline: SVG path data on a square grid.
library;

import 'dart:ui';

import 'package:flutter/rendering.dart' show CustomPainter;

/// One glyph drawn as a filled outline, whatever drew it.
///
/// The formatting bar's glyphs come from two sources — Material Symbols at
/// weight 300 and the ones the maintainer redraws by hand in Penpot — and
/// both arrive as the `viewBox` and the `d` of one SVG `<path>`, so the
/// widget that paints them cannot tell them apart
/// ([icons](../../../../../../docs/design/components/icons.md)).
class TomOutline {
  /// Creates an outline of [pathData] on the grid [left], [top], [width],
  /// [height] — the SVG's `viewBox`.
  const TomOutline({
    required this.pathData,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// The SVG `<path d="…">`.
  ///
  /// Every command is understood: `M L H V C S Q T A Z`, absolute and
  /// relative.
  final String pathData;

  /// The `viewBox`'s x.
  final double left;

  /// The `viewBox`'s y (Material's is `-960`).
  final double top;

  /// The `viewBox`'s width.
  final double width;

  /// The `viewBox`'s height.
  final double height;

  static final Expando<Path> _built = Expando<Path>('TomOutline.path');

  /// The path in the grid's own units, built once per outline.
  Path get path => _built[this] ??= parsePath(pathData);

  /// Reads SVG path data into a [Path].
  ///
  /// Throws a [FormatException] on anything it cannot place, rather than
  /// drawing half an icon.
  static Path parsePath(String data) {
    final Path path = Path();
    final _Scanner scan = _Scanner(data);
    double x = 0;
    double y = 0;
    double startX = 0;
    double startY = 0;
    Offset? lastCubic;
    Offset? lastQuad;
    String command = '';
    bool first = true;

    while (true) {
      scan.skip();
      if (scan.isDone) {
        break;
      }
      if (scan.atCommand) {
        command = scan.takeCommand();
        first = true;
        if (command == 'Z' || command == 'z') {
          path.close();
          x = startX;
          y = startY;
          lastCubic = lastQuad = null;
          continue;
        }
      } else if (command.isEmpty || command == 'Z' || command == 'z') {
        throw FormatException('Numbers with no command', data, scan.at);
      }

      final bool relative = command == command.toLowerCase();
      final double dx = relative ? x : 0;
      final double dy = relative ? y : 0;
      String kind = command.toUpperCase();
      if (kind == 'M' && !first) {
        kind = 'L';
      }
      first = false;

      switch (kind) {
        case 'M':
          x = dx + scan.number();
          y = dy + scan.number();
          path.moveTo(x, y);
          startX = x;
          startY = y;
          lastCubic = lastQuad = null;
        case 'L':
          x = dx + scan.number();
          y = dy + scan.number();
          path.lineTo(x, y);
          lastCubic = lastQuad = null;
        case 'H':
          x = dx + scan.number();
          path.lineTo(x, y);
          lastCubic = lastQuad = null;
        case 'V':
          y = dy + scan.number();
          path.lineTo(x, y);
          lastCubic = lastQuad = null;
        case 'C':
          final double x1 = dx + scan.number();
          final double y1 = dy + scan.number();
          final double x2 = dx + scan.number();
          final double y2 = dy + scan.number();
          final double nx = dx + scan.number();
          final double ny = dy + scan.number();
          path.cubicTo(x1, y1, x2, y2, nx, ny);
          lastCubic = Offset(x2, y2);
          lastQuad = null;
          x = nx;
          y = ny;
        case 'S':
          final Offset from = lastCubic == null
              ? Offset(x, y)
              : Offset(2 * x - lastCubic.dx, 2 * y - lastCubic.dy);
          final double x2 = dx + scan.number();
          final double y2 = dy + scan.number();
          final double nx = dx + scan.number();
          final double ny = dy + scan.number();
          path.cubicTo(from.dx, from.dy, x2, y2, nx, ny);
          lastCubic = Offset(x2, y2);
          lastQuad = null;
          x = nx;
          y = ny;
        case 'Q':
          final double x1 = dx + scan.number();
          final double y1 = dy + scan.number();
          final double nx = dx + scan.number();
          final double ny = dy + scan.number();
          path.quadraticBezierTo(x1, y1, nx, ny);
          lastQuad = Offset(x1, y1);
          lastCubic = null;
          x = nx;
          y = ny;
        case 'T':
          final Offset from = lastQuad == null
              ? Offset(x, y)
              : Offset(2 * x - lastQuad.dx, 2 * y - lastQuad.dy);
          final double nx = dx + scan.number();
          final double ny = dy + scan.number();
          path.quadraticBezierTo(from.dx, from.dy, nx, ny);
          lastQuad = from;
          lastCubic = null;
          x = nx;
          y = ny;
        case 'A':
          final double rx = scan.number();
          final double ry = scan.number();
          final double turn = scan.number();
          final bool large = scan.flag();
          final bool sweep = scan.flag();
          final double nx = dx + scan.number();
          final double ny = dy + scan.number();
          path.arcToPoint(
            Offset(nx, ny),
            radius: Radius.elliptical(rx, ry),
            rotation: turn,
            largeArc: large,
            clockwise: sweep,
          );
          lastCubic = lastQuad = null;
          x = nx;
          y = ny;
        default:
          throw FormatException('Unknown command $command', data, scan.at);
      }
    }
    return path;
  }
}

/// Fills [outline] with [color], scaled to the box it is given and centred
/// in it.
///
/// The grid is scaled whole, so a Material glyph (24 grid, ink inside a 20
/// live area) and a hand-drawn one on the same grid sit alike.
class TomOutlinePainter extends CustomPainter {
  /// Creates the painter of [outline] in [color].
  const TomOutlinePainter(this.outline, this.color);

  /// What to draw.
  final TomOutline outline;

  /// The ink.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double grid = outline.width > outline.height
        ? outline.width
        : outline.height;
    final double scale = size.width / grid;
    canvas
      ..translate(
        (size.width - outline.width * scale) / 2,
        (size.height - outline.height * scale) / 2,
      )
      ..scale(scale)
      ..translate(-outline.left, -outline.top)
      ..drawPath(outline.path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(TomOutlinePainter old) =>
      old.outline != outline || old.color != color;
}

/// A cursor over path data.
class _Scanner {
  _Scanner(this.data);

  static final RegExp _numberPattern = RegExp(
    r'[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?',
  );

  final String data;
  int at = 0;

  bool get isDone => at >= data.length;

  /// Passes whitespace and commas.
  void skip() {
    while (at < data.length && ' \t\r\n,'.contains(data[at])) {
      at++;
    }
  }

  bool get atCommand => 'MmLlHhVvCcSsQqTtAaZz'.contains(data[at]);

  String takeCommand() => data[at++];

  double number() {
    skip();
    final Match? match = _numberPattern.matchAsPrefix(data, at);
    if (match == null) {
      throw FormatException('A number was expected', data, at);
    }
    at = match.end;
    return double.parse(match.group(0)!);
  }

  /// An arc's flag: one character, which may touch the next number.
  bool flag() {
    skip();
    if (at >= data.length || (data[at] != '0' && data[at] != '1')) {
      throw FormatException('A flag was expected', data, at);
    }
    return data[at++] == '1';
  }
}
