import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

/// The formatting bar's glyph, measured in pixels the way the maintainer
/// sees it: Material Symbols at weight 300 drawn in the button's box, whose
/// ink must stay about 14-16 tall like the board's (the box is not the ink).
void main() {
  final GlobalKey boundary = GlobalKey();
  const double scale = 8;

  /// The inked rectangle of [outline] drawn in the button's box, in logical
  /// points from the box's top left.
  Future<Rect> ink(WidgetTester tester, TomOutline outline) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: boundary,
            child: ColoredBox(
              color: Colors.white,
              child: CustomPaint(
                size: const Size.square(TomToolbarButtonWidget.glyphBox),
                painter: TomOutlinePainter(outline, Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
    final Rect? found = await tester.runAsync(() async {
      final RenderRepaintBoundary render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await render.toImage(pixelRatio: scale);
      final ByteData data = (await image.toByteData())!;
      int top = image.height;
      int bottom = -1;
      int left = image.width;
      int right = -1;
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          if (data.getUint8((y * image.width + x) * 4) < 128) {
            top = math.min(top, y);
            bottom = math.max(bottom, y);
            left = math.min(left, x);
            right = math.max(right, x);
          }
        }
      }
      return Rect.fromLTRB(
        left / scale,
        top / scale,
        (right + 1) / scale,
        (bottom + 1) / scale,
      );
    });
    return found!;
  }

  testWidgets('the glyph is drawn in a 22 box, tuned by eye', (
    WidgetTester tester,
  ) async {
    expect(TomToolbarButtonWidget.glyphBox, 22);
    expect(TomToolbarButtonWidget.size, 28);
  });

  testWidgets('every glyph of the bar stays within 14-16 of ink', (
    WidgetTester tester,
  ) async {
    final Map<TomGlyphEnum, Rect> measured = <TomGlyphEnum, Rect>{};
    for (final TomGlyphEnum glyph in tomToolbarOutlines.keys) {
      measured[glyph] = await ink(tester, tomToolbarOutlines[glyph]!);
    }
    for (final MapEntry<TomGlyphEnum, Rect> entry in measured.entries) {
      debugPrint(
        'ink ${entry.key.name}: '
        '${entry.value.width.toStringAsFixed(1)} x '
        '${entry.value.height.toStringAsFixed(1)}',
      );
      final double longest = math.max(entry.value.width, entry.value.height);
      // The board holds 14-16; `strikethrough` is wide (18) and
      // `ordered-list` tall (17.5), which the 28 cell carries.
      expect(entry.value.height, lessThanOrEqualTo(18), reason: 'height');
      expect(entry.value.width, lessThanOrEqualTo(18.5), reason: 'width');
      expect(longest, greaterThanOrEqualTo(10), reason: entry.key.name);
    }
    // The tallest are the box and the triangle: about 15.5 and 16.
    expect(measured[TomGlyphEnum.table]!.height, closeTo(15.6, 0.6));
    expect(measured[TomGlyphEnum.alert]!.height, closeTo(16, 0.6));
    // The heading is a plain T of 600 on the 960 grid.
    expect(measured[TomGlyphEnum.heading]!.height, closeTo(13.75, 0.6));
  });

  testWidgets('no glyph’s ink leaves its box or the 28 cell’s middle 20', (
    WidgetTester tester,
  ) async {
    // Material's live area is the 20 inside the 24 grid; the glyph is not
    // re-centred by its ink, so `superscript` sits where its neighbours'
    // baselines are.
    const double box = TomToolbarButtonWidget.glyphBox;
    for (final TomGlyphEnum glyph in tomToolbarOutlines.keys) {
      final Rect found = await ink(tester, tomToolbarOutlines[glyph]!);
      expect(found.left, greaterThanOrEqualTo(box * 0.04), reason: glyph.name);
      expect(found.top, greaterThanOrEqualTo(box * 0.04), reason: glyph.name);
      expect(found.right, lessThanOrEqualTo(box * 0.96), reason: glyph.name);
      expect(found.bottom, lessThanOrEqualTo(box * 0.96), reason: glyph.name);
    }
  });
}
