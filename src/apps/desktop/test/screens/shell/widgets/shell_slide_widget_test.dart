import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/shell/widgets/shell_slide_widget.dart';

void main() {
  /// A row holding a 100-wide slide, [isOpen] or not, beside a filler.
  Widget app({
    required bool isOpen,
    double extent = 100,
    bool reduceMotion = false,
    Axis axis = Axis.horizontal,
  }) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: Flex(
          direction: axis,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ShellSlideWidget(
              isOpen: isOpen,
              axis: axis,
              extent: extent,
              alignment: Alignment.centerRight,
              child: const ColoredBox(color: Colors.teal),
            ),
            const Expanded(child: SizedBox.expand()),
          ],
        ),
      ),
    ),
  );

  /// The room the slide takes along its axis.
  double taken(WidgetTester tester, [Axis axis = Axis.horizontal]) {
    final Finder slide = find.byType(ShellSlideWidget);
    final Size size = tester.getSize(slide);
    return axis == Axis.horizontal ? size.width : size.height;
  }

  testWidgets('the first layout does not animate, open or closed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(isOpen: true));
    expect(taken(tester), 100);

    await tester.pumpWidget(app(isOpen: false));
    // A different widget tree state: closed from the start takes nothing.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app(isOpen: false));
    expect(taken(tester), 0);
  });

  testWidgets('opening runs between the two ends, and ends open', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(isOpen: false));

    await tester.pumpWidget(app(isOpen: true));
    await tester.pump(const Duration(milliseconds: 100));
    final double midway = taken(tester);
    expect(midway, greaterThan(0));
    expect(midway, lessThan(100));

    await tester.pump(ShellSlideWidget.duration);
    expect(taken(tester), 100);
  });

  testWidgets('closing runs between the two ends, and ends closed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(isOpen: true));

    await tester.pumpWidget(app(isOpen: false));
    await tester.pump(const Duration(milliseconds: 100));
    final double midway = taken(tester);
    expect(midway, greaterThan(0));
    expect(midway, lessThan(100));

    await tester.pump(ShellSlideWidget.duration);
    expect(taken(tester), 0);
  });

  testWidgets('a width changed while open follows at once: a drag', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(isOpen: true));

    await tester.pumpWidget(app(isOpen: true, extent: 140));

    expect(taken(tester), 140);
  });

  testWidgets('it slides in height as well', (WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(400, 600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(isOpen: false, axis: Axis.vertical));

    await tester.pumpWidget(app(isOpen: true, axis: Axis.vertical));
    await tester.pump(const Duration(milliseconds: 100));
    final double midway = taken(tester, Axis.vertical);
    expect(midway, greaterThan(0));
    expect(midway, lessThan(100));

    await tester.pump(ShellSlideWidget.duration);
    expect(taken(tester, Axis.vertical), 100);
  });

  testWidgets('with reduce motion on, it jumps to the end', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(isOpen: false, reduceMotion: true));

    await tester.pumpWidget(app(isOpen: true, reduceMotion: true));
    expect(taken(tester), 100);

    await tester.pumpWidget(app(isOpen: false, reduceMotion: true));
    expect(taken(tester), 0);
  });
}
