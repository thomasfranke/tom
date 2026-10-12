import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  /// [button] on its own, in [brightness].
  Widget app(Widget button, {Brightness brightness = Brightness.dark}) =>
      MaterialApp(
        theme: tomTheme(brightness),
        home: Scaffold(body: Center(child: button)),
      );

  /// The glyph the button draws.
  TomOutlinePainter glyphOf(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byType(TomToolbarButtonWidget),
                  matching: find.byWidgetPredicate(
                    (Widget it) =>
                        it is CustomPaint && it.painter is TomOutlinePainter,
                  ),
                ),
              )
              .painter!
          as TomOutlinePainter;

  for (final Brightness brightness in Brightness.values) {
    final TomColors colors = brightness == Brightness.dark
        ? TomColors.dark
        : TomColors.light;

    group('in the ${brightness.name} theme', () {
      testWidgets('at rest its glyph is text_secondary', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          app(
            TomToolbarButtonWidget(
              glyph: TomGlyphEnum.undo,
              tooltip: 'Undo',
              onPressed: () {},
            ),
            brightness: brightness,
          ),
        );

        expect(glyphOf(tester).color, colors.textSecondary);
      });

      testWidgets('unavailable it is fainter than text_muted alone: 60%', (
        WidgetTester tester,
      ) async {
        // `text_muted` by itself sits too close to a live button's ink at
        // this size (`docs/design/components/controls.md`).
        await tester.pumpWidget(
          app(
            const TomToolbarButtonWidget(
              glyph: TomGlyphEnum.undo,
              tooltip: 'Undo',
              onPressed: null,
            ),
            brightness: brightness,
          ),
        );

        expect(glyphOf(tester).color, colors.textMuted.withValues(alpha: 0.6));
      });
    });
  }

  testWidgets('unavailable it answers no press, and is still there', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(
        const TomToolbarButtonWidget(
          glyph: TomGlyphEnum.redo,
          tooltip: 'Redo',
          onPressed: null,
        ),
      ),
    );

    expect(find.byTooltip('Redo'), findsOneWidget);
    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
  });

  testWidgets('pressed, it does what it was given', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await tester.pumpWidget(
      app(
        TomToolbarButtonWidget(
          glyph: TomGlyphEnum.undo,
          tooltip: 'Undo',
          onPressed: () => presses++,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Undo'));

    expect(presses, 1);
  });

  testWidgets('it is the cell the design gives it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(
        TomToolbarButtonWidget(
          glyph: TomGlyphEnum.undo,
          tooltip: 'Undo',
          onPressed: () {},
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(SizedBox).first),
      const Size.square(TomToolbarButtonWidget.size),
    );
  });
}
