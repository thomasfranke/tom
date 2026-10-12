import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  testWidgets('Escape puts the menu away even when something else had the '
      'keyboard first', (WidgetTester tester) async {
    int dismissed = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: tomTheme(Brightness.dark),
        home: Scaffold(
          // What the shell holds for its shortcuts: autofocus there is what
          // left an autofocused menu deaf to Escape.
          body: Focus(
            autofocus: true,
            child: Center(
              child: TomMenuWidget(
                width: 200,
                onDismissed: () => dismissed++,
                groups: <List<TomMenuEntry>>[
                  <TomMenuEntry>[
                    TomMenuEntry(
                      glyph: TomGlyphEnum.plus,
                      label: 'One',
                      onSelected: () {},
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);

    expect(dismissed, 1);
  });

  testWidgets('a detail sits in a column of its own, quieter than the label, '
      'and the row still chooses', (WidgetTester tester) async {
    final List<String> chosen = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: tomTheme(Brightness.dark),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: TomMenuWidget(
              width: 240,
              onDismissed: () {},
              groups: <List<TomMenuEntry>>[
                <TomMenuEntry>[
                  for (final String folder in <String>['docs', 'docs/archive'])
                    TomMenuEntry(
                      glyph: TomGlyphEnum.file,
                      // Short, since the test font draws every character
                      // a square of its size.
                      label: 'a.md',
                      detail: folder,
                      onSelected: () => chosen.add(folder),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // The board's column: 70 after the label starts, at 34.
    final TomColors colors = TomColors.of(tester.element(find.text('docs')));
    expect(
      tester.getTopLeft(find.text('docs')).dx -
          tester.getTopLeft(find.text('a.md').first).dx,
      TomMenuWidget.detailLeft,
    );
    final TextStyle detail = tester.widget<Text>(find.text('docs')).style!;
    expect(detail.color, colors.textMuted);
    expect(detail.fontSize, 11);

    await tester.tap(find.text('docs/archive'));
    await tester.pump();

    expect(chosen, <String>['docs/archive']);
  });
}
