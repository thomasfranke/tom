import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  Widget toggle(TomPanelSideEnum side, {required bool isOpen}) => MaterialApp(
    theme: tomTheme(Brightness.dark),
    home: Scaffold(
      body: Center(
        child: RepaintBoundary(
          child: TomPanelToggleWidget(
            side: side,
            isOpen: isOpen,
            width: 24,
            height: 18,
            radius: 3,
            stroke: 1.5,
            strip: 8,
          ),
        ),
      ),
    ),
  );

  Finder painted() => find.descendant(
    of: find.byType(TomPanelToggleWidget),
    matching: find.byType(CustomPaint),
  );

  for (final TomPanelSideEnum side in TomPanelSideEnum.values) {
    for (final bool isOpen in <bool>[false, true]) {
      testWidgets('${side.name} ${isOpen ? 'open' : 'closed'} is the size it '
          'was told and paints without a fault', (WidgetTester tester) async {
        await tester.pumpWidget(toggle(side, isOpen: isOpen));

        expect(
          tester.getSize(find.byType(TomPanelToggleWidget)),
          const Size(24, 18),
        );
        expect(painted(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('it repaints when what it draws changes, and only then', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(toggle(TomPanelSideEnum.left, isOpen: false));
    final CustomPainter before = tester.widget<CustomPaint>(painted()).painter!;

    await tester.pumpWidget(toggle(TomPanelSideEnum.left, isOpen: false));
    final CustomPainter same = tester.widget<CustomPaint>(painted()).painter!;
    expect(same.shouldRepaint(before), isFalse);

    for (final TomPanelSideEnum side in <TomPanelSideEnum>[
      TomPanelSideEnum.right,
      TomPanelSideEnum.bottom,
    ]) {
      await tester.pumpWidget(toggle(side, isOpen: false));
      expect(
        tester.widget<CustomPaint>(painted()).painter!.shouldRepaint(before),
        isTrue,
        reason: 'the side moved the divider',
      );
    }
    await tester.pumpWidget(toggle(TomPanelSideEnum.left, isOpen: true));
    expect(
      tester.widget<CustomPaint>(painted()).painter!.shouldRepaint(before),
      isTrue,
      reason: 'opening fills the strip',
    );
  });
}
