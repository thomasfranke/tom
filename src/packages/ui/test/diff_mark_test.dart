import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  /// [mark] on its own, under the theme.
  Widget app(Widget mark) => MaterialApp(
    theme: tomTheme(Brightness.light),
    home: Scaffold(body: Center(child: mark)),
  );

  testWidgets('it is the letter, at the square the design fixes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(
        const DiffMarkWidget(
          letter: 'A',
          ink: Color(0xFF3D7A52),
          fill: Color(0xFFE6F0E8),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(tester.getSize(find.byType(DiffMarkWidget)).width, TomMetrics.mark);
    expect(tester.getSize(find.byType(DiffMarkWidget)).height, TomMetrics.mark);
  });

  testWidgets('the letter is drawn in the ink and the square in the fill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(
        const DiffMarkWidget(
          letter: 'R',
          ink: Color(0xFFA24F46),
          fill: Color(0xFFF6E8E6),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text('R')).style?.color,
      const Color(0xFFA24F46),
    );
    expect(
      (tester.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration
              as BoxDecoration)
          .color,
      const Color(0xFFF6E8E6),
    );
  });

  testWidgets('the whole word is there for whoever has not learnt them', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(
        const DiffMarkWidget(
          letter: 'M',
          ink: Color(0xFF8F6F2E),
          fill: Color(0xFFF4EDDF),
          tooltip: 'Modified',
        ),
      ),
    );

    expect(find.byType(Tooltip), findsOneWidget);
    expect(tester.widget<Tooltip>(find.byType(Tooltip)).message, 'Modified');
  });

  testWidgets('without one there is no tooltip at all', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(
        const DiffMarkWidget(
          letter: 'A',
          ink: Color(0xFF3D7A52),
          fill: Color(0xFFE6F0E8),
        ),
      ),
    );

    expect(find.byType(Tooltip), findsNothing);
  });
}
