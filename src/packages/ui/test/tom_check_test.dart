import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  /// [check] on its own, under [brightness].
  Widget app(Widget check, {Brightness brightness = Brightness.dark}) =>
      MaterialApp(
        theme: tomTheme(brightness),
        home: Scaffold(body: Center(child: check)),
      );

  /// The box the component paints, which is not its tap target.
  BoxDecoration boxOf(WidgetTester tester) =>
      tester
              .widget<DecoratedBox>(
                find.descendant(
                  of: find.byType(TomCheckWidget),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .decoration
          as BoxDecoration;

  testWidgets('the box is the board’s, and smaller than what is clicked', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(TomCheckWidget(isChecked: false, onChanged: (bool _) {})),
    );

    expect(
      tester.getSize(find.byType(TomCheckWidget)).width,
      TomCheckWidget.target,
      reason: 'a fifteen-point target is a target somebody misses',
    );
    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(TomCheckWidget),
          matching: find.byType(DecoratedBox),
        ),
      ),
      const Size.square(TomCheckWidget.box),
    );
  });

  testWidgets('off is the raised surface behind a hairline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(TomCheckWidget(isChecked: false, onChanged: (bool _) {})),
    );

    expect(boxOf(tester).color, TomColors.dark.surfaceRaised);
    expect(boxOf(tester).border?.top.color, TomColors.dark.borderStrong);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('on is the accent, with the tick knocked out of it', (
    WidgetTester tester,
  ) async {
    // Not white, which on this accent glares
    // (`docs/design/components/controls.md`).
    await tester.pumpWidget(
      app(TomCheckWidget(isChecked: true, onChanged: (bool _) {})),
    );

    expect(boxOf(tester).color, TomColors.dark.accent);
    expect(boxOf(tester).border, isNull);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.check)).color,
      TomColors.dark.surfaceRaised,
    );
  });

  testWidgets('clicking it asks for the other state', (
    WidgetTester tester,
  ) async {
    bool? asked;
    await tester.pumpWidget(
      app(TomCheckWidget(isChecked: true, onChanged: (bool it) => asked = it)),
    );

    await tester.tap(find.byType(TomCheckWidget));

    expect(asked, isFalse);
  });

  testWidgets('and one with nothing to call is inert, not hidden', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(const TomCheckWidget(isChecked: false, onChanged: null)),
    );

    await tester.tap(find.byType(TomCheckWidget));

    expect(find.byType(TomCheckWidget), findsOneWidget);
  });

  testWidgets('it pins to the edge it was given, not to the middle', (
    WidgetTester tester,
  ) async {
    // The target is wider than the box, so a centred box sits inside the
    // column's margin (`docs/product/git-workflow/commit/README.md`).
    await tester.pumpWidget(
      app(
        TomCheckWidget(
          isChecked: false,
          onChanged: (bool _) {},
          alignment: Alignment.centerRight,
        ),
      ),
    );

    final Finder box = find.descendant(
      of: find.byType(TomCheckWidget),
      matching: find.byType(DecoratedBox),
    );
    expect(
      tester.getBottomRight(box).dx,
      tester.getBottomRight(find.byType(TomCheckWidget)).dx,
    );
  });
}
