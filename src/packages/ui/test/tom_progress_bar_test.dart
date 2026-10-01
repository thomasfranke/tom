import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  /// The bar on its own, under the theme, in a column's width.
  Widget app() => MaterialApp(
    theme: tomTheme(Brightness.light),
    home: const Scaffold(
      body: SizedBox(width: 280, child: TomProgressBarWidget()),
    ),
  );

  testWidgets('it is three points tall, the width of the column', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();

    expect(
      tester.getSize(find.byType(TomProgressBarWidget)).height,
      TomProgressBarWidget.height,
    );
    expect(tester.getSize(find.byType(TomProgressBarWidget)).width, 280);
    // Pumped rather than settled: the segment never stops, so settling would
    // wait on an animation that has no end.
    await tester.pump(TomProgressBarWidget.crossing);
  });

  testWidgets('the track is accent_soft and the segment accent', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();

    const TomColors colors = TomColors.light;
    final Iterable<ColoredBox> boxes = tester.widgetList<ColoredBox>(
      find.descendant(
        of: find.byType(TomProgressBarWidget),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(boxes.map((ColoredBox box) => box.color), <Color>[
      colors.accentSoft,
      colors.accent,
    ]);

    await tester.pump(TomProgressBarWidget.crossing);
  });

  testWidgets('the segment travels, because git reports no fraction', (
    WidgetTester tester,
  ) async {
    // A bar that filled to the end and sat there would be claiming a
    // fraction nothing measured.
    await tester.pumpWidget(app());
    await tester.pump();
    final Finder segment = find
        .descendant(
          of: find.byType(TomProgressBarWidget),
          matching: find.byType(SizedBox),
        )
        .last;
    final double first = tester.getTopLeft(segment).dx;

    await tester.pump(TomProgressBarWidget.crossing ~/ 3);

    expect(tester.getTopLeft(segment).dx, isNot(first));
    await tester.pump(TomProgressBarWidget.crossing);
  });
}
