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

  /// An arrow up over its stem: publishing (`icons/push.svg`).
  push,

  /// An arrow down over its stem: bringing back (`icons/pull.svg`).
  pull,

  /// A circle open at the top right, with a tick: asking what is there
  /// (`icons/fetch.svg`).
  fetch,

  /// An arrow curving back on itself: taking the last thing back
  /// (`icons/undo.svg`).
  undo,

  /// The same arrow the other way (`icons/redo.svg`).
  redo,

  /// Two uprights joined by a bar: the letter H (`icons/heading.svg`).
  heading,

  /// An S with a line through it (`icons/strikethrough.svg`).
  strikethrough,

  /// Three lines, each with a dot (`icons/list.svg`).
  list,

  /// Three lines, the first numbered (`icons/ordered-list.svg`).
  orderedList,

  /// Two lines, each with a tick (`icons/task-list.svg`).
  taskList,

  /// An upright and two lines beside it (`icons/quote.svg`).
  quote,

  /// Two angle brackets facing away (`icons/code.svg`).
  code,

  /// A box divided into cells (`icons/table.svg`).
  table,

  /// One line across the middle (`icons/rule.svg`).
  rule,

  /// A frame with a horizon and a sun (`icons/image.svg`).
  image,

  /// Lines of text with a raised one (`icons/footnote.svg`).
  footnote,

  /// A triangle with an exclamation in it (`icons/alert.svg`).
  alert,

  /// A cogwheel: the one symbol for settings nobody has to learn
  /// (`icons/preferences.svg`).
  preferences,

  /// Three dots: what a row too narrow for its last group collapses into
  /// (`icons/more.svg`).
  more,
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
        TomGlyphEnum.push => _push(),
        TomGlyphEnum.pull => _pull(),
        TomGlyphEnum.fetch => _fetch(),
        TomGlyphEnum.undo => _undo(),
        TomGlyphEnum.redo => _redo(),
        TomGlyphEnum.heading => _heading(),
        TomGlyphEnum.strikethrough => _strikethrough(),
        TomGlyphEnum.list => _list(),
        TomGlyphEnum.orderedList => _orderedList(),
        TomGlyphEnum.taskList => _taskList(),
        TomGlyphEnum.quote => _quote(),
        TomGlyphEnum.code => _code(),
        TomGlyphEnum.table => _table(),
        TomGlyphEnum.rule => _rule(),
        TomGlyphEnum.image => _image(),
        TomGlyphEnum.footnote => _footnote(),
        TomGlyphEnum.alert => _alert(),
        TomGlyphEnum.preferences => _preferences(),
        TomGlyphEnum.more => _more(),
      }, ink)
      ..restore();
  }

  /// `icons/more.svg`.
  ///
  /// Three dots as half-unit circles: stroked at [_stroke] they come out
  /// three across, which is the diameter the set's other round marks have.
  static Path _more() {
    final Path path = Path();
    for (final double x in <double>[4, 8, 12]) {
      path.addOval(Rect.fromCircle(center: Offset(x, 8), radius: 0.5));
    }
    return path;
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

  /// `icons/push.svg`: the stem, then the head over its top.
  static Path _push() => Path()
    ..moveTo(8, 14)
    ..lineTo(8, 3)
    ..moveTo(3, 8)
    ..lineTo(8, 3)
    ..lineTo(13, 8);

  /// `icons/pull.svg`: the same shape, pointing the other way.
  static Path _pull() => Path()
    ..moveTo(8, 2)
    ..lineTo(8, 13)
    ..moveTo(3, 8)
    ..lineTo(8, 13)
    ..lineTo(13, 8);

  /// `icons/fetch.svg`: a circle left open at the top right, and the tick
  /// that says which way it turns.
  ///
  /// The arc is the SVG's `a 5.5 5.5 0 1 1 -1.61 -3.89` — the long way
  /// round from three o'clock, which is what leaves the gap the tick fills.
  static Path _fetch() => Path()
    ..moveTo(13.5, 8)
    ..arcToPoint(
      const Offset(11.89, 4.11),
      radius: const Radius.circular(5.5),
      largeArc: true,
    )
    ..moveTo(13.5, 2)
    ..lineTo(13.5, 5.5)
    ..lineTo(10, 5.5);

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.color != color;

  /// `icons/undo.svg`: the arrowhead, then the line curving back under it.
  static Path _undo() => Path()
    ..moveTo(6, 4.5)
    ..lineTo(2.5, 8)
    ..lineTo(6, 11.5)
    ..moveTo(2.5, 8)
    ..lineTo(10.5, 8)
    ..arcToPoint(const Offset(10.5, 15), radius: const Radius.circular(3.5))
    ..lineTo(8.5, 15);

  /// `icons/redo.svg`: [_undo] mirrored.
  static Path _redo() => Path()
    ..moveTo(10, 4.5)
    ..lineTo(13.5, 8)
    ..lineTo(10, 11.5)
    ..moveTo(13.5, 8)
    ..lineTo(5.5, 8)
    ..arcToPoint(
      const Offset(5.5, 15),
      radius: const Radius.circular(3.5),
      clockwise: false,
    )
    ..lineTo(7.5, 15);

  /// `icons/heading.svg`: the letter H.
  static Path _heading() => Path()
    ..moveTo(3.5, 3)
    ..lineTo(3.5, 13)
    ..moveTo(12.5, 3)
    ..lineTo(12.5, 13)
    ..moveTo(3.5, 8)
    ..lineTo(12.5, 8);

  /// `icons/strikethrough.svg`: the S, and the line through it.
  static Path _strikethrough() => Path()
    ..moveTo(11, 4.6)
    ..cubicTo(11, 3.3, 9.7, 2.5, 8, 2.5)
    ..cubicTo(6.2, 2.5, 5, 3.5, 5, 5)
    ..cubicTo(5, 7.5, 11, 8.2, 11, 11)
    ..cubicTo(11, 12.5, 9.8, 13.5, 8, 13.5)
    ..cubicTo(6.3, 13.5, 5, 12.7, 5, 11.4)
    ..moveTo(2, 8)
    ..lineTo(14, 8);

  /// `icons/list.svg`: three lines, each with a dot.
  ///
  /// The dots are zero-length segments, which a round cap draws as circles —
  /// the set's own way of writing a dot without a second shape.
  static Path _list() => Path()
    ..moveTo(6, 4)
    ..lineTo(14, 4)
    ..moveTo(6, 8)
    ..lineTo(14, 8)
    ..moveTo(6, 12)
    ..lineTo(14, 12)
    ..moveTo(2.5, 4)
    ..lineTo(2.5, 4)
    ..moveTo(2.5, 8)
    ..lineTo(2.5, 8)
    ..moveTo(2.5, 12)
    ..lineTo(2.5, 12);

  /// `icons/ordered-list.svg`: three lines, the first numbered.
  static Path _orderedList() => Path()
    ..moveTo(7, 4)
    ..lineTo(14, 4)
    ..moveTo(7, 8)
    ..lineTo(14, 8)
    ..moveTo(7, 12)
    ..lineTo(14, 12)
    ..moveTo(2, 3.4)
    ..lineTo(3.2, 2.8)
    ..lineTo(3.2, 6);

  /// `icons/task-list.svg`: two lines, each with a tick.
  static Path _taskList() => Path()
    ..moveTo(2, 4)
    ..lineTo(3.2, 5.2)
    ..lineTo(5.5, 2.9)
    ..moveTo(2, 11)
    ..lineTo(3.2, 12.2)
    ..lineTo(5.5, 9.9)
    ..moveTo(8.5, 4)
    ..lineTo(14, 4)
    ..moveTo(8.5, 11)
    ..lineTo(14, 11);

  /// `icons/quote.svg`: the upright, and two lines beside it.
  static Path _quote() => Path()
    ..moveTo(3, 3.5)
    ..lineTo(3, 12.5)
    ..moveTo(7, 5.5)
    ..lineTo(13.5, 5.5)
    ..moveTo(7, 10.5)
    ..lineTo(13.5, 10.5);

  /// `icons/code.svg`: two angle brackets facing away.
  static Path _code() => Path()
    ..moveTo(5.5, 4)
    ..lineTo(2, 8)
    ..lineTo(5.5, 12)
    ..moveTo(10.5, 4)
    ..lineTo(14, 8)
    ..lineTo(10.5, 12);

  /// `icons/table.svg`: the box, its header rule and one divider.
  static Path _table() => Path()
    ..moveTo(2.5, 3.5)
    ..lineTo(13.5, 3.5)
    ..lineTo(13.5, 12.5)
    ..lineTo(2.5, 12.5)
    ..close()
    ..moveTo(2.5, 7)
    ..lineTo(13.5, 7)
    ..moveTo(8, 7)
    ..lineTo(8, 12.5);

  /// `icons/rule.svg`: one line across the middle.
  static Path _rule() => Path()
    ..moveTo(2.5, 8)
    ..lineTo(13.5, 8);

  /// `icons/image.svg`: the frame, the horizon and the sun.
  static Path _image() => Path()
    ..moveTo(2.5, 3.5)
    ..lineTo(13.5, 3.5)
    ..lineTo(13.5, 12.5)
    ..lineTo(2.5, 12.5)
    ..close()
    ..moveTo(3.5, 11.5)
    ..lineTo(6, 8.5)
    ..lineTo(8, 10.5)
    ..lineTo(9.5, 9.2)
    ..lineTo(12.5, 11.5)
    ..moveTo(10.6, 6)
    ..lineTo(10.6, 6);

  /// `icons/footnote.svg`: lines of text, with the reference raised.
  static Path _footnote() => Path()
    ..moveTo(2.5, 4)
    ..lineTo(9, 4)
    ..moveTo(11.2, 2.4)
    ..lineTo(12.2, 2)
    ..lineTo(12.2, 5.5)
    ..moveTo(2.5, 9.5)
    ..lineTo(6.5, 9.5)
    ..moveTo(2.5, 12.5)
    ..lineTo(10.5, 12.5);

  /// `icons/alert.svg`: the triangle, and the exclamation in it.
  static Path _alert() => Path()
    ..moveTo(8, 2.5)
    ..lineTo(14, 13)
    ..lineTo(2, 13)
    ..close()
    ..moveTo(8, 6.5)
    ..lineTo(8, 9.5)
    ..moveTo(8, 11.3)
    ..lineTo(8, 11.3);

  /// `icons/preferences.svg`: the cogwheel, and the hole at its centre.
  ///
  /// Twelve arcs rather than teeth drawn one by one, which is what makes it
  /// read as a gear at 16 — a sliders mark read as `rule`, as `list` and as
  /// a control panel at every size tried before this one.
  static Path _preferences() => Path()
    ..moveTo(6.24, 1.85)
    ..arcToPoint(const Offset(9.76, 1.85), radius: const Radius.circular(6.40))
    ..lineTo(9.84, 3.86)
    ..arcToPoint(const Offset(10.66, 4.33), radius: const Radius.circular(4.53))
    ..lineTo(12.45, 3.40)
    ..arcToPoint(const Offset(14.21, 6.45), radius: const Radius.circular(6.40))
    ..lineTo(12.51, 7.53)
    ..arcToPoint(const Offset(12.51, 8.47), radius: const Radius.circular(4.53))
    ..lineTo(14.21, 9.55)
    ..arcToPoint(
      const Offset(12.45, 12.60),
      radius: const Radius.circular(6.40),
    )
    ..lineTo(10.66, 11.67)
    ..arcToPoint(const Offset(9.84, 12.14), radius: const Radius.circular(4.53))
    ..lineTo(9.76, 14.15)
    ..arcToPoint(const Offset(6.24, 14.15), radius: const Radius.circular(6.40))
    ..lineTo(6.16, 12.14)
    ..arcToPoint(const Offset(5.34, 11.67), radius: const Radius.circular(4.53))
    ..lineTo(3.55, 12.60)
    ..arcToPoint(const Offset(1.79, 9.55), radius: const Radius.circular(6.40))
    ..lineTo(3.49, 8.47)
    ..arcToPoint(const Offset(3.49, 7.53), radius: const Radius.circular(4.53))
    ..lineTo(1.79, 6.45)
    ..arcToPoint(const Offset(3.55, 3.40), radius: const Radius.circular(6.40))
    ..lineTo(5.34, 4.33)
    ..arcToPoint(const Offset(6.16, 3.86), radius: const Radius.circular(4.53))
    ..close()
    ..addOval(Rect.fromCircle(center: const Offset(8, 8), radius: 2));
}
