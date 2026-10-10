import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  const Color ink = Color(0xFFECEAE4);

  /// [chevron] on its own.
  Widget app(Widget chevron) => MaterialApp(
    theme: tomTheme(Brightness.dark),
    home: Scaffold(body: Center(child: chevron)),
  );

  /// The glyph the chevron draws.
  TomGlyphWidget glyphOf(WidgetTester tester) =>
      tester.widget<TomGlyphWidget>(find.byType(TomGlyphWidget));

  testWidgets('open, it points down', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(const TomChevronWidget(isOpen: true, color: ink)),
    );

    expect(glyphOf(tester).glyph, TomGlyphEnum.chevronDown);
  });

  testWidgets('closed, it points right', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(const TomChevronWidget(isOpen: false, color: ink)),
    );

    expect(glyphOf(tester).glyph, TomGlyphEnum.chevronRight);
  });

  testWidgets('the glyph sits well inside its box, so it does not outweigh '
      'the label beside it', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(const TomChevronWidget(isOpen: true, color: ink)),
    );

    expect(glyphOf(tester).size, 16 * TomChevronWidget.inkShare);
  });

  testWidgets('it is the box the boards give it', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(const TomChevronWidget(isOpen: true, color: ink)),
    );

    expect(
      tester.getSize(find.byType(TomChevronWidget)),
      const Size.square(16),
    );
  });
}
