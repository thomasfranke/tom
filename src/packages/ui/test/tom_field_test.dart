import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  /// [child] on its own, under the dark theme.
  Widget app(Widget child) => MaterialApp(
    theme: tomTheme(Brightness.dark),
    home: Scaffold(body: Center(child: child)),
  );

  /// What the box paints.
  BoxDecoration boxOf(WidgetTester tester) =>
      tester
              .widget<DecoratedBox>(
                find.descendant(
                  of: find.byType(TomFieldBoxWidget),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .decoration
          as BoxDecoration;

  group('the box a column field is drawn in', () {
    testWidgets('it is the height it was told, whatever is inside it', (
      WidgetTester tester,
    ) async {
      // The design fixes the box, which is why it is drawn rather than
      // decorated: a Material decoration sizes itself from its content and
      // an empty field came out seven points shorter.
      await tester.pumpWidget(
        app(
          const TomFieldBoxWidget(
            height: 28,
            fill: Color(0xFF131211),
            radius: 6,
            child: SizedBox.shrink(),
          ),
        ),
      );

      expect(tester.getSize(find.byType(TomFieldBoxWidget)).height, 28);
    });

    testWidgets('at rest it is a hairline, and on focus it is the accent', (
      WidgetTester tester,
    ) async {
      // A hairline either way: two points at this height reads as an error
      // rather than as focus.
      await tester.pumpWidget(
        app(
          const TomFieldBoxWidget(
            height: 28,
            fill: Color(0xFF131211),
            radius: 6,
            child: SizedBox.shrink(),
          ),
        ),
      );
      expect(boxOf(tester).border?.top.color, TomColors.dark.border);
      expect(boxOf(tester).border?.top.width, 1);

      await tester.pumpWidget(
        app(
          const TomFieldBoxWidget(
            height: 28,
            fill: Color(0xFF131211),
            radius: 6,
            isFocused: true,
            child: SizedBox.shrink(),
          ),
        ),
      );

      expect(boxOf(tester).border?.top.color, TomColors.dark.accent);
      expect(boxOf(tester).border?.top.width, 1);
    });
  });

  group('the control that empties a field', () {
    testWidgets('it is a disc of muted ink, not a bare glyph', (
      WidgetTester tester,
    ) async {
      // A glyph alone reads as a character somebody typed
      // (`docs/design/components/controls.md`).
      await tester.pumpWidget(
        app(const TomFieldClearWidget(on: Color(0xFF131211))),
      );

      final BoxDecoration disc =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: find.byType(TomFieldClearWidget),
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      expect(disc.color, TomColors.dark.textMuted);
      expect(disc.shape, BoxShape.circle);
    });

    testWidgets('and the glyph is knocked out in the field’s own fill', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        app(const TomFieldClearWidget(on: Color(0xFF131211))),
      );

      expect(
        tester.widget<Icon>(find.byIcon(Icons.close)).color,
        const Color(0xFF131211),
      );
    });
  });
}
