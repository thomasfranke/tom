import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  /// [control] on its own, under the dark theme, in something paintable.
  ///
  /// These two draw rather than compose, so what they are for cannot be read
  /// off the widget tree: the tests below look at the pixels, which is the
  /// same thing the boards are compared against.
  Widget app(Widget control) => MaterialApp(
    theme: tomTheme(Brightness.dark),
    home: Scaffold(
      backgroundColor: TomColors.dark.surface,
      body: Center(
        child: RepaintBoundary(key: const Key('paint'), child: control),
      ),
    ),
  );

  /// The colour at ([x], [y]) inside the painted control.
  Future<Color> pixelAt(WidgetTester tester, int x, int y) async {
    final RenderRepaintBoundary boundary =
        tester.renderObject(find.byKey(const Key('paint')))
            as RenderRepaintBoundary;
    late Color found;
    await tester.runAsync(() async {
      final ui.Image image = await boundary.toImage();
      final ByteData pixels = (await image.toByteData())!;
      final int at = (y * image.width + x) * 4;
      found = Color.fromARGB(
        pixels.getUint8(at + 3),
        pixels.getUint8(at),
        pixels.getUint8(at + 1),
        pixels.getUint8(at + 2),
      );
      image.dispose();
    });
    return found;
  }

  /// A toggle for [side], [isOpen] or not, at the board's numbers.
  Widget toggle(TomPanelSideEnum side, {required bool isOpen}) =>
      TomPanelToggleWidget(
        side: side,
        isOpen: isOpen,
        width: 20,
        height: 16,
        radius: 3,
        stroke: 1.5,
        strip: 7,
      );

  group('the control that hides a column', () {
    testWidgets('the strip is filled while that column is open', (
      WidgetTester tester,
    ) async {
      // The rule the board draws: outline and divider always, the strip only
      // when it is open (`docs/product/workspace/columns/doc.md`).
      await tester.pumpWidget(app(toggle(TomPanelSideEnum.left, isOpen: true)));

      expect(await pixelAt(tester, 4, 8), TomColors.dark.textSecondary);
    });

    testWidgets('and empty while it is closed', (WidgetTester tester) async {
      await tester.pumpWidget(
        app(toggle(TomPanelSideEnum.left, isOpen: false)),
      );

      expect(await pixelAt(tester, 4, 8), isNot(TomColors.dark.textSecondary));
    });

    testWidgets('the two sides fill opposite ends of the same outline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        app(toggle(TomPanelSideEnum.right, isOpen: true)),
      );

      // Four in from the right is inside the strip; four in from the left is
      // the empty half.
      expect(await pixelAt(tester, 16, 8), TomColors.dark.textSecondary);
      expect(await pixelAt(tester, 4, 8), isNot(TomColors.dark.textSecondary));
    });

    testWidgets('it is the size the design gives it, never its own', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(app(toggle(TomPanelSideEnum.left, isOpen: true)));

      expect(
        tester.getSize(find.byType(TomPanelToggleWidget)),
        const Size(20, 16),
      );
    });
  });

  group('the control that switches the theme', () {
    testWidgets('in dark it fills the right half', (WidgetTester tester) async {
      // Drawn in the panel toggles' own ink, so the three read as one set.
      await tester.pumpWidget(
        app(const TomThemeToggleWidget(isDark: true, size: 16, stroke: 1.5)),
      );

      expect(await pixelAt(tester, 12, 8), TomColors.dark.textSecondary);
      expect(await pixelAt(tester, 4, 8), isNot(TomColors.dark.textSecondary));
    });

    testWidgets('and in light it fills the other one', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        app(const TomThemeToggleWidget(isDark: false, size: 16, stroke: 1.5)),
      );

      expect(await pixelAt(tester, 4, 8), TomColors.dark.textSecondary);
      expect(await pixelAt(tester, 12, 8), isNot(TomColors.dark.textSecondary));
    });
  });
}
