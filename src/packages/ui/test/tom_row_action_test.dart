import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  Widget app(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: tomTheme(brightness),
        home: Scaffold(body: Center(child: child)),
      );

  group('Row action', () {
    for (final (TomRowActionKind kind, String label)
        in <(TomRowActionKind, String)>[
          (TomRowActionKind.confirm, 'Run'),
          (TomRowActionKind.always, 'Always allow'),
          (TomRowActionKind.refuse, 'Deny'),
        ]) {
      testWidgets('$label is 20 tall and as wide as its label', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          app(TomRowActionWidget(kind: kind, label: label, onPressed: () {})),
        );

        final Size size = tester.getSize(find.byType(TomRowActionWidget));
        expect(size.height, 20);
        // 6 · glyph · 3 · label · 10, and never wider than the label needs.
        final double text = tester.getSize(find.text(label)).width;
        expect(size.width, closeTo(6 + 14 + 3 + text + 10, 1));
      });

      testWidgets('$label answers a press', (WidgetTester tester) async {
        int pressed = 0;
        await tester.pumpWidget(
          app(
            TomRowActionWidget(
              kind: kind,
              label: label,
              onPressed: () => pressed++,
            ),
          ),
        );

        await tester.tap(find.text(label));

        expect(pressed, 1);
      });
    }

    testWidgets('the kinds wear their fills: accent, outline, removed', (
      WidgetTester tester,
    ) async {
      const TomColors colors = TomColors.light;
      for (final (TomRowActionKind kind, Color? fill, bool outlined)
          in <(TomRowActionKind, Color?, bool)>[
            (TomRowActionKind.confirm, colors.accent, false),
            (TomRowActionKind.always, null, true),
            (TomRowActionKind.refuse, colors.removed, false),
          ]) {
        await tester.pumpWidget(
          app(TomRowActionWidget(kind: kind, label: 'x', onPressed: () {})),
        );

        final BoxDecoration decoration =
            tester
                    .widget<Container>(
                      find.descendant(
                        of: find.byType(TomRowActionWidget),
                        matching: find.byType(Container),
                      ),
                    )
                    .decoration!
                as BoxDecoration;
        expect(decoration.color, fill);
        expect(decoration.border != null, outlined);
        if (outlined) {
          expect(decoration.border!.top.color, colors.accent);
        }
      }
    });
  });

  group('Spinner', () {
    testWidgets('is 12 by 12 and turns without ever settling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(app(const TomSpinnerWidget()));

      expect(tester.getSize(find.byType(TomSpinnerWidget)), const Size(12, 12));
      await tester.pump(TomSpinnerWidget.turn);
      expect(tester.takeException(), isNull);
    });
  });
}
