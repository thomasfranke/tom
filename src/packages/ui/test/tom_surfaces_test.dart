/// The surfaces the shell draws on: the bar, the column's island, the rule.
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  Widget app(Widget child, {Brightness brightness = Brightness.dark}) =>
      MaterialApp(
        theme: tomTheme(brightness),
        home: Scaffold(
          body: Align(alignment: Alignment.topLeft, child: child),
        ),
      );

  testWidgets('a bar is as wide as its parent, the height it was told, and '
      'the window’s own fill', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(const TomBarWidget(height: 40, child: SizedBox())),
    );

    final Finder bar = find.byType(TomBarWidget);
    expect(tester.getSize(bar), const Size(800, 40));
    final Container box = tester.widget<Container>(
      find.descendant(of: bar, matching: find.byType(Container)),
    );
    expect(box.color, TomColors.dark.surface);
  });

  testWidgets('a bar with no child still takes its whole width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(const TomBarWidget(height: 36, child: SizedBox.shrink())),
    );

    expect(tester.getSize(find.byType(TomBarWidget)).width, 800);
  });

  testWidgets('a column island is raised, rounded, and its edge is painted '
      'over what it holds', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const SizedBox(
          width: 120,
          height: 80,
          child: TomColumnBoxWidget(child: ColoredBox(color: Colors.red)),
        ),
        brightness: Brightness.light,
      ),
    );

    final Container island = tester.widget<Container>(
      find.descendant(
        of: find.byType(TomColumnBoxWidget),
        matching: find.byType(Container),
      ),
    );
    final BoxDecoration fill = island.decoration! as BoxDecoration;
    final BoxDecoration edge = island.foregroundDecoration! as BoxDecoration;
    expect(fill.color, TomColors.light.surfaceRaised);
    expect(fill.borderRadius, BorderRadius.circular(TomMetrics.radiusIsland));
    expect(edge.border!.top.color, TomColors.light.border);
    expect(island.clipBehavior, Clip.antiAlias);
    expect(
      tester.getSize(find.byType(TomColumnBoxWidget)),
      const Size(120, 80),
    );
  });

  group('the rule', () {
    testWidgets('is one point tall, as wide as its parent plus the bleed on '
        'each side', (WidgetTester tester) async {
      await tester.pumpWidget(
        app(
          SizedBox(width: 100, child: TomRulePainter.of(Colors.red, bleed: 4)),
        ),
      );

      final Finder paint = find.descendant(
        of: find.byType(OverflowBox),
        matching: find.byType(CustomPaint),
      );
      expect(tester.getSize(paint), const Size(108, 1));
      expect(tester.getTopLeft(paint).dx, -4);
    });

    testWidgets('lands on one whole row of device pixels when the box sits '
        'on a fraction', (WidgetTester tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(100, 60);
      addTearDown(tester.view.reset);
      final GlobalKey shot = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: shot,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.3, top: 20.2),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 50,
                    child: TomRulePainter.of(const Color(0xFFFF0000)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final ByteData? data = await tester.runAsync<ByteData?>(() async {
        final RenderRepaintBoundary boundary =
            shot.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage();
        return image.toByteData();
      });
      bool isRed(int x, int y) {
        final int at = (y * 100 + x) * 4;
        return data!.getUint8(at) == 255 &&
            data.getUint8(at + 1) == 0 &&
            data.getUint8(at + 2) == 0;
      }

      expect(isRed(10, 20), isTrue, reason: '10.3 and 20.2 round to 10, 20');
      expect(isRed(59, 20), isTrue);
      expect(isRed(10, 19), isFalse);
      expect(isRed(10, 21), isFalse, reason: 'one row, not two half-lit ones');
      expect(isRed(9, 20), isFalse);
      expect(isRed(61, 20), isFalse);
    });

    test('repaints only when its colour changes', () {
      expect(
        const TomRulePainter(
          Colors.red,
        ).shouldRepaint(const TomRulePainter(Colors.blue)),
        isTrue,
      );
      expect(
        const TomRulePainter(
          Colors.red,
        ).shouldRepaint(const TomRulePainter(Colors.red)),
        isFalse,
      );
    });

    test('a collapsed transform draws the box as it is', () {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder)
        ..transform(
          Float64List.fromList(<double>[
            0, 0, 0, 0, //
            0, 0, 0, 0, //
            0, 0, 1, 0, //
            0, 0, 0, 1,
          ]),
        );

      // Nothing to round against: it must not divide by the zero scale.
      expect(
        () => const TomRulePainter(Colors.red).paint(canvas, const Size(5, 1)),
        returnsNormally,
      );
      recorder.endRecording().dispose();
    });
  });
}
