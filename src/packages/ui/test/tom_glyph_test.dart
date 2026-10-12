import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  const Color ink = Color(0xFFECEAE4);

  /// [glyph] on its own.
  Widget app(Widget glyph) => MaterialApp(
    theme: tomTheme(Brightness.dark),
    home: Scaffold(body: Center(child: glyph)),
  );

  /// The icon [glyph] draws.
  Future<IconData> iconOf(WidgetTester tester, TomGlyphEnum glyph) async {
    await tester.pumpWidget(app(TomGlyphWidget(glyph: glyph, color: ink)));
    return tester.widget<Icon>(find.byType(Icon)).icon!;
  }

  testWidgets('a glyph is a character of the vendored icon face', (
    WidgetTester tester,
  ) async {
    final IconData icon = await iconOf(tester, TomGlyphEnum.folder);

    expect(icon.fontFamily, TomFonts.icons);
    expect(icon.fontPackage, TomFonts.iconsPackage);
  });

  testWidgets('every glyph is drawn, and no two are the same character', (
    WidgetTester tester,
  ) async {
    // A glyph the map forgot draws nothing; two sharing a code point is a
    // control that looks like another.
    final Set<int> seen = <int>{};
    for (final TomGlyphEnum glyph in TomGlyphEnum.values) {
      seen.add((await iconOf(tester, glyph)).codePoint);
    }

    expect(seen, hasLength(TomGlyphEnum.values.length));
  });

  testWidgets('it is drawn in the ink the host control gives it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(const TomGlyphWidget(glyph: TomGlyphEnum.push, color: ink)),
    );

    expect(tester.widget<Icon>(find.byType(Icon)).color, ink);
  });

  testWidgets('beside a label it is a step under the text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(const TomGlyphWidget(glyph: TomGlyphEnum.folder, color: ink)),
    );

    expect(
      tester.getSize(find.byType(TomGlyphWidget)),
      const Size.square(TomGlyphWidget.defaultSize),
    );
  });

  testWidgets('an outline is the same glyph, painted with a stroke', (
    WidgetTester tester,
  ) async {
    // Font Awesome Free has no regular house or gear, so an outline is the
    // Solid glyph's edge rather than a second set (Decision 32, revised).
    await tester.pumpWidget(
      app(
        const TomGlyphWidget(
          glyph: TomGlyphEnum.home,
          color: ink,
          size: 16,
          outline: true,
        ),
      ),
    );

    final TextSpan span =
        tester
                .widget<RichText>(
                  find.descendant(
                    of: find.byType(TomGlyphWidget),
                    matching: find.byType(RichText),
                  ),
                )
                .text
            as TextSpan;
    final Paint paint = span.style!.foreground!;
    expect(find.byType(Icon), findsNothing);
    expect(span.text!.runes.single, 0xf015);
    expect(span.style!.fontFamily, contains(TomFonts.icons));
    expect(paint.style, PaintingStyle.stroke);
    expect(paint.strokeWidth, TomGlyphWidget.outlineStroke);
    expect(paint.color.toARGB32(), ink.toARGB32());
    expect(tester.getSize(find.byType(TomGlyphWidget)), const Size.square(16));
  });

  testWidgets('a glyph is filled unless it is asked for an outline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(const TomGlyphWidget(glyph: TomGlyphEnum.home, color: ink)),
    );

    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('it takes the size the host control gives it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(const TomGlyphWidget(glyph: TomGlyphEnum.link, color: ink, size: 24)),
    );

    expect(tester.getSize(find.byType(TomGlyphWidget)), const Size.square(24));
  });
}
