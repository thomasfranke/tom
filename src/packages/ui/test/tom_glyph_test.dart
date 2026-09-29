import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  const Color ink = Color(0xFFECEAE4);

  /// [glyph] on its own, in something paintable.
  Widget app(Widget glyph) => MaterialApp(
    theme: tomTheme(Brightness.dark),
    home: Scaffold(
      backgroundColor: TomColors.dark.surface,
      body: Center(
        child: RepaintBoundary(key: const Key('paint'), child: glyph),
      ),
    ),
  );

  /// The box the painted ink actually occupies.
  ///
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

  testWidgets('a glyph is the box the icon set is drawn on', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(const TomGlyphWidget(glyph: TomGlyphEnum.folder, color: ink)),
    );

    expect(tester.getSize(find.byType(TomGlyphWidget)), const Size.square(16));
  });

  testWidgets('the folder fills the grid it is drawn on', (
    WidgetTester tester,
  ) async {
    // `icons/folder.svg` runs from 2 to 14 on the 16 grid, and the stroke
    // puts a unit of ink either side of that.
    await tester.pumpWidget(
      app(const TomGlyphWidget(glyph: TomGlyphEnum.folder, color: ink)),
    );

    final Rect painted = await inkBounds(tester);

    expect(painted.left, closeTo(1, 1));
    expect(painted.right, closeTo(15, 1));
  });

  testWidgets('and the link runs corner to corner, which the folder does not', (
    WidgetTester tester,
  ) async {
    // The chain is a diagonal: it reaches higher and lower than the folder,
    // which is what tells the two apart at 16 points.
    await tester.pumpWidget(
      app(const TomGlyphWidget(glyph: TomGlyphEnum.link, color: ink)),
    );

    final Rect painted = await inkBounds(tester);

    expect(painted.height, greaterThan(11));
  });

  testWidgets('it takes the size the host control gives it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(const TomGlyphWidget(glyph: TomGlyphEnum.link, color: ink, size: 24)),
    );

    expect(tester.getSize(find.byType(TomGlyphWidget)), const Size.square(24));
  });
}
