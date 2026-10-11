import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

/// A rule is one row of whole pixels wherever its box lands: a `Divider`
/// at a fractional offset smears into two half-lit rows, which the boards
/// never draw (`docs/design/screens/divergences.md`, stage 12.6).
void main() {
  testWidgets('a rule at a fractional offset lands on one row of pixels', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder)..translate(3.3, 10.4);
      const TomRulePainter(Color(0xFF000000)).paint(canvas, const Size(20, 1));
      final ui.Image image = await recorder.endRecording().toImage(30, 20);
      final ByteData data = (await image.toByteData())!;

      final Set<int> rows = <int>{};
      final Set<int> columns = <int>{};
      for (int y = 0; y < 20; y++) {
        for (int x = 0; x < 30; x++) {
          final int alpha = data.getUint8((y * 30 + x) * 4 + 3);
          if (alpha != 0) {
            // Whole, not a haze: a half-lit pixel is the bug.
            expect(alpha, 255, reason: 'pixel $x,$y');
            rows.add(y);
            columns.add(x);
          }
        }
      }
      expect(rows, <int>{10});
      expect(columns.first, 3);
      expect(columns.last, 22);
    });
  });
}
