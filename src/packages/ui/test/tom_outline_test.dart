import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

/// The glyphs of the formatting bar are outlines, whichever hand drew them.
void main() {
  group('path data', () {
    Rect bounds(String d) => TomOutline.parsePath(d).getBounds();

    test('absolute and relative lines close on the start', () {
      expect(
        bounds('M10 10 h20 v20 h-20 Z'),
        const Rect.fromLTRB(10, 10, 30, 30),
      );
      expect(
        bounds('M10 10L30 10 30 30 10 30z'),
        const Rect.fromLTRB(10, 10, 30, 30),
      );
    });

    test('numbers may touch their signs and decimal points', () {
      final Rect heading = bounds('M437.69-180v-515h-217.3v-85H740');
      expect(heading.left, closeTo(220.39, 0.001));
      expect(heading.top, -780);
      expect(heading.right, 740);
      expect(heading.bottom, -180);
      expect(bounds('M.5.5L1.5.5'), const Rect.fromLTRB(0.5, 0.5, 1.5, 0.5));
    });

    test('curves, smooth curves and arcs reach their end points', () {
      expect(bounds('M0 0C0 10 10 10 10 0S20 -10 20 0').width, 20);
      expect(bounds('M0 0Q5 10 10 0T20 0').width, 20);
      final Rect arc = bounds('M0 0a10 10 0 0 1 20 0');
      expect(arc.width, closeTo(20, 0.01));
      // Sweep 1 is clockwise on a y-down screen: the half-circle goes over.
      expect(arc.top, closeTo(-10, 0.01));
      final Rect glued = bounds('M0 0a10 10 0 0120 0');
      expect(glued, arc);
    });

    test('a pair after a move is a line', () {
      expect(bounds('M0 0 10 0 10 10'), const Rect.fromLTRB(0, 0, 10, 10));
    });

    test('what cannot be placed is refused, not half drawn', () {
      expect(() => TomOutline.parsePath('M0 0 X1 1'), throwsFormatException);
      expect(() => TomOutline.parsePath('10 10'), throwsFormatException);
      expect(() => TomOutline.parsePath('M0'), throwsFormatException);
    });
  });

  group('the bar’s sources', () {
    const List<TomGlyphEnum> bar = <TomGlyphEnum>[
      TomGlyphEnum.undo,
      TomGlyphEnum.redo,
      TomGlyphEnum.heading,
      TomGlyphEnum.bold,
      TomGlyphEnum.italic,
      TomGlyphEnum.strikethrough,
      TomGlyphEnum.list,
      TomGlyphEnum.orderedList,
      TomGlyphEnum.taskList,
      TomGlyphEnum.quote,
      TomGlyphEnum.code,
      TomGlyphEnum.table,
      TomGlyphEnum.rule,
      TomGlyphEnum.link,
      TomGlyphEnum.image,
      TomGlyphEnum.footnote,
      TomGlyphEnum.alert,
    ];

    test('every one of the seventeen has an outline, and no other does', () {
      expect(tomToolbarOutlines.keys.toSet(), bar.toSet());
    });

    test('every outline parses and stays inside its own grid', () {
      for (final TomGlyphEnum glyph in bar) {
        final TomOutline outline = tomToolbarOutlines[glyph]!;
        final Rect grid = Rect.fromLTWH(
          outline.left,
          outline.top,
          outline.width,
          outline.height,
        );
        final Rect ink = outline.path.getBounds();
        expect(
          grid.inflate(0.5).contains(ink.topLeft),
          isTrue,
          reason: glyph.name,
        );
        expect(
          grid.inflate(0.5).contains(ink.bottomRight),
          isTrue,
          reason: glyph.name,
        );
      }
    });

    testWidgets('a button draws a hand-drawn source with the same widget', (
      WidgetTester tester,
    ) async {
      const TomOutline handDrawn = TomOutline(
        left: 0,
        top: 0,
        width: 24,
        height: 24,
        pathData: 'M4 4h16v16H4Z',
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: tomTheme(Brightness.dark),
          home: Scaffold(
            body: Center(
              child: Column(
                children: <Widget>[
                  TomToolbarButtonWidget(
                    glyph: TomGlyphEnum.quote,
                    tooltip: 'Quote',
                    onPressed: () {},
                  ),
                  TomToolbarButtonWidget(
                    glyph: TomGlyphEnum.quote,
                    outline: handDrawn,
                    tooltip: 'Hand drawn',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final List<CustomPaint> drawn = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(TomToolbarButtonWidget),
              matching: find.byWidgetPredicate(
                (Widget it) =>
                    it is CustomPaint && it.painter is TomOutlinePainter,
              ),
            ),
          )
          .toList();
      expect(drawn, hasLength(2));
      final TomOutlinePainter first = drawn[0].painter! as TomOutlinePainter;
      final TomOutlinePainter second = drawn[1].painter! as TomOutlinePainter;
      expect(first.outline, tomToolbarOutlines[TomGlyphEnum.quote]);
      expect(second.outline, handDrawn);
      expect(drawn[1].size, drawn[0].size);
      expect(drawn[1].size, const Size.square(TomToolbarButtonWidget.glyphBox));
    });
  });
}
