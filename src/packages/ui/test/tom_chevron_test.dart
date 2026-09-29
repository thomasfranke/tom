import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  const Color ink = Color(0xFFECEAE4);

  /// [chevron] on its own, in something paintable.
  Widget app(Widget chevron) => MaterialApp(
    theme: tomTheme(Brightness.dark),
    home: Scaffold(
      backgroundColor: TomColors.dark.surface,
      body: Center(
        child: RepaintBoundary(key: const Key('paint'), child: chevron),
      ),
    ),
  );

  /// The box the painted ink actually occupies.
  ///
  /// Measured rather than assumed: the glyph is aligned by its ink and not
  /// by its box, so where it lands is the widget's answer, not arithmetic.
  /// **Ink is alpha**, not colour — inside a repaint boundary what is not
  /// painted is transparent rather than the surface behind it.
  Future<Rect> inkBounds(WidgetTester tester) async {
    final RenderRepaintBoundary boundary =
        tester.renderObject(find.byKey(const Key('paint')))
            as RenderRepaintBoundary;
    late Rect bounds;
    await tester.runAsync(() async {
      final ui.Image image = await boundary.toImage();
      final ByteData pixels = (await image.toByteData())!;
      double left = image.width.toDouble();
      double top = image.height.toDouble();
      double right = 0;
      double bottom = 0;
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          if (pixels.getUint8((y * image.width + x) * 4 + 3) > 0) {
            left = x < left ? x.toDouble() : left;
            top = y < top ? y.toDouble() : top;
            right = x > right ? x.toDouble() : right;
            bottom = y > bottom ? y.toDouble() : bottom;
          }
        }
      }
      bounds = Rect.fromLTRB(left, top, right, bottom);
      image.dispose();
    });
    return bounds;
  }

  testWidgets('open, it is wide and short — a chevron pointing down', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(const TomChevronWidget(isOpen: true, color: ink)),
    );

    final Rect painted = await inkBounds(tester);

    expect(painted.width, greaterThan(painted.height));
  });

  testWidgets('and closed it is narrow and tall — the same glyph, turned', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(const TomChevronWidget(isOpen: false, color: ink)),
    );

    final Rect painted = await inkBounds(tester);

    expect(painted.height, greaterThan(painted.width));
  });

  testWidgets('and it is the codicon, filled: the boards stroke none', (
    WidgetTester tester,
  ) async {
    // A stroked polyline of the same path is a third as wide again and
    // square at the ends; the filled glyph is 5.3 by 9.95 on the 16 grid
    // (`design/screens/desktop/workspace/shell-dark.svg`).
    await tester.pumpWidget(
      app(const TomChevronWidget(isOpen: false, color: ink)),
    );

    final Rect painted = await inkBounds(tester);

    expect(painted.width, closeTo(5.3, 1));
    expect(painted.height, closeTo(9.95, 1));
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
