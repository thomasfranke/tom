import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  /// The button at the right of a 400-wide window, its menu holding [chosen].
  Future<void> pump(WidgetTester tester, List<String> chosen, {double? drop}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: tomTheme(Brightness.dark),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topRight,
              child: TomMenuButtonWidget(
                tooltip: 'Explorer menu',
                width: 200,
                drop: drop ?? TomMenuButtonWidget.defaultDrop,
                groups: <List<TomMenuEntry>>[
                  <TomMenuEntry>[
                    TomMenuEntry(
                      glyph: TomGlyphEnum.plus,
                      label: 'New document',
                      onSelected: () => chosen.add('new'),
                    ),
                  ],
                  <TomMenuEntry>[
                    TomMenuEntry(
                      glyph: TomGlyphEnum.discard,
                      label: 'Delete',
                      isDestructive: true,
                      onSelected: () => chosen.add('delete'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

  Color glyphColor(WidgetTester tester) => tester
      .widget<TomGlyphWidget>(
        find.descendant(
          of: find.byType(Tooltip),
          matching: find.byType(TomGlyphWidget),
        ),
      )
      .color;

  testWidgets('is the board’s square, and closed there is no menu', (
    WidgetTester tester,
  ) async {
    await pump(tester, <String>[]);

    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(TomMenuButtonWidget),
          matching: find.byType(SizedBox).first,
        ),
      ),
      const Size.square(TomMenuButtonWidget.box),
    );
    expect(find.byType(TomMenuWidget), findsNothing);
    expect(glyphColor(tester), TomColors.dark.textMuted);
  });

  testWidgets('pressing it opens the menu right-aligned under the glyph and '
      'lights the glyph', (WidgetTester tester) async {
    await pump(tester, <String>[]);

    await tester.tap(find.byType(TomMenuButtonWidget));
    await tester.pump();

    expect(find.byType(TomMenuWidget), findsOneWidget);
    final Rect button = tester.getRect(find.byType(TomMenuButtonWidget));
    final Rect menu = tester.getRect(find.byType(TomMenuWidget));
    expect(menu.width, 200);
    expect(
      menu.top,
      closeTo(button.bottom + TomMenuButtonWidget.defaultDrop, 1),
    );
    expect(
      menu.right,
      closeTo(button.center.dx + 5 + 0, 6),
      reason: 'it hangs from the right, overhang past the glyph’s centre',
    );
    expect(glyphColor(tester), TomColors.dark.textPrimary);
  });

  testWidgets('pressing it again closes the menu instead of reopening it', (
    WidgetTester tester,
  ) async {
    await pump(tester, <String>[]);
    await tester.tap(find.byType(TomMenuButtonWidget));
    await tester.pump();

    await tester.tap(find.byType(TomMenuButtonWidget));
    await tester.pump();

    expect(find.byType(TomMenuWidget), findsNothing);
  });

  testWidgets('choosing a row closes the menu and does what the row says', (
    WidgetTester tester,
  ) async {
    final List<String> chosen = <String>[];
    await pump(tester, chosen);
    await tester.tap(find.byType(TomMenuButtonWidget));
    await tester.pump();

    await tester.tap(find.text('Delete'));
    await tester.pump();

    expect(chosen, <String>['delete']);
    expect(find.byType(TomMenuWidget), findsNothing);
  });

  testWidgets('a press outside puts the menu away without choosing', (
    WidgetTester tester,
  ) async {
    final List<String> chosen = <String>[];
    await pump(tester, chosen);
    await tester.tap(find.byType(TomMenuButtonWidget));
    await tester.pump();

    await tester.tapAt(const Offset(10, 500));
    await tester.pump();

    expect(find.byType(TomMenuWidget), findsNothing);
    expect(chosen, isEmpty);
  });

  testWidgets('a destructive row wears the removed role, and a rule sits '
      'between the groups', (WidgetTester tester) async {
    await pump(tester, <String>[]);
    await tester.tap(find.byType(TomMenuButtonWidget));
    await tester.pump();

    final Text delete = tester.widget<Text>(find.text('Delete'));
    expect(delete.style!.color, TomColors.dark.removed);
    expect(
      tester.widget<Text>(find.text('New document')).style!.color,
      TomColors.dark.textPrimary,
    );
    expect(find.byType(CustomPaint), findsWidgets);
    final Rect first = tester.getRect(find.text('New document'));
    final Rect second = tester.getRect(find.text('Delete'));
    expect(
      second.top - first.top,
      TomMenuWidget.rowHeight + TomMenuWidget.ruleBand,
    );
  });

  testWidgets('a different drop moves the menu the same distance', (
    WidgetTester tester,
  ) async {
    await pump(tester, <String>[], drop: 11.5);
    await tester.tap(find.byType(TomMenuButtonWidget));
    await tester.pump();

    final Rect button = tester.getRect(find.byType(TomMenuButtonWidget));
    expect(
      tester.getRect(find.byType(TomMenuWidget)).top,
      closeTo(button.bottom + 11.5, 1),
    );
  });
}
