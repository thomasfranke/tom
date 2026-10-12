import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  const TomColors colors = TomColors.dark;

  /// The document column's width: `pull-worked` draws 876, which the test
  /// window's 800 cannot hold, and nothing measured here depends on it.
  const double width = 760;

  /// The band in the document column's width, as `pull-worked` draws it.
  Widget app({String? action = 'Push', VoidCallback? onAction}) => MaterialApp(
    theme: tomTheme(Brightness.dark),
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: NoticeBandWidget(
            // One line even in the test font, whose every glyph is square.
            sentence: 'Pulled 3 commits from origin/main.',
            ink: colors.added,
            fill: colors.addedSoft,
            action: action,
            onAction: onAction,
          ),
        ),
      ),
    ),
  );

  Finder inBand(Finder matching) =>
      find.descendant(of: find.byType(NoticeBandWidget), matching: matching);

  testWidgets('the band is 36 tall and filled with the soft colour', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app());

    final Rect band = tester.getRect(find.byType(NoticeBandWidget));
    expect(band.size, const Size(width, 36));
    expect(
      tester.widget<ColoredBox>(inBand(find.byType(ColoredBox)).first).color,
      colors.addedSoft,
    );
  });

  testWidgets('a bar of ink 3 wide runs the band\'s height at its left', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app());

    final Finder bar = inBand(
      find.byWidgetPredicate(
        (Widget widget) => widget is ColoredBox && widget.color == colors.added,
      ),
    );
    expect(tester.getRect(bar), const Rect.fromLTWH(0, 0, 3, 36));
  });

  testWidgets('the sentence starts 19 in, at 12.5 and 500, in ink', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app());

    final Finder sentence = find.textContaining('Pulled 3 commits');
    expect(tester.getTopLeft(sentence).dx, 19);
    final Rect rect = tester.getRect(sentence);
    expect(rect.center.dy, closeTo(18, 0.5));
    final Text text = tester.widget<Text>(sentence);
    expect(text.style?.fontSize, 12.5);
    expect(text.style?.fontWeight, FontWeight.w500);
    expect(text.style?.color, colors.added);
    expect(text.maxLines, isNull);
  });

  testWidgets('a long sentence wraps, the band grows and the pill stays on '
      'its first line', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: tomTheme(Brightness.dark),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 360,
              child: NoticeBandWidget(
                sentence:
                    'Git refused the pull: it would overwrite the uncommitted '
                    'changes to guide.md. Nothing changed here — commit '
                    'them, then try again.',
                ink: colors.modified,
                fill: colors.modifiedSoft,
                action: 'Try again',
                onAction: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final Rect band = tester.getRect(find.byType(NoticeBandWidget));
    expect(band.height, greaterThan(36));
    final Rect sentence = tester.getRect(find.textContaining('Git refused'));
    expect(sentence.top, closeTo(9.875, 0.5));
    expect(band.height - sentence.bottom, closeTo(9.875, 0.5));
    final Finder bar = inBand(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is ColoredBox && widget.color == colors.modified,
      ),
    );
    expect(tester.getRect(bar).height, band.height);
    final Rect pill = tester.getRect(inBand(find.byType(OutlinedButton)));
    expect(pill.top, 6);
    expect(pill.right, 360 - 13);
  });

  testWidgets('the action is a 24 pill, 6 from the top and 13 from the right', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(onAction: () {}));

    final Rect pill = tester.getRect(inBand(find.byType(OutlinedButton)));
    expect(pill.height, 24);
    expect(pill.top, 6);
    expect(pill.right, width - 13);
    final double label = tester.getSize(find.text('Push')).width;
    expect(pill.width, closeTo(label + 28, 0.5));
  });

  testWidgets('the pill follows its label rather than a fixed width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(onAction: () {}));
    final double short = tester
        .getSize(inBand(find.byType(OutlinedButton)))
        .width;

    await tester.pumpWidget(app(action: 'Abort the pull', onAction: () {}));
    final double long = tester
        .getSize(inBand(find.byType(OutlinedButton)))
        .width;

    expect(long, greaterThan(short));
    expect(
      long,
      closeTo(tester.getSize(find.text('Abort the pull')).width + 28, 0.5),
    );
  });

  testWidgets('the pill is an outline of ink with nothing behind it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(onAction: () {}));

    final ButtonStyle style = tester
        .widget<OutlinedButton>(inBand(find.byType(OutlinedButton)))
        .style!;
    expect(style.backgroundColor?.resolve(<WidgetState>{}), Colors.transparent);
    expect(
      style.side?.resolve(<WidgetState>{}),
      BorderSide(color: colors.added),
    );
    final Text label = tester.widget<Text>(find.text('Push'));
    expect(label.data, 'Push');
    final TextStyle? text = style.textStyle?.resolve(<WidgetState>{});
    expect(text?.fontSize, 12);
    expect(text?.fontWeight, FontWeight.w600);
    expect(style.foregroundColor?.resolve(<WidgetState>{}), colors.added);
  });

  testWidgets('without a callback the action stays, faded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app());

    final ButtonStyle style = tester
        .widget<OutlinedButton>(inBand(find.byType(OutlinedButton)))
        .style!;
    const Set<WidgetState> disabled = <WidgetState>{WidgetState.disabled};
    expect(
      style.foregroundColor?.resolve(disabled),
      colors.added.withValues(alpha: 0.4),
    );
    expect(
      style.side?.resolve(disabled)?.color,
      colors.added.withValues(alpha: 0.4),
    );
  });

  testWidgets('with no action the band holds only the sentence', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(action: null));

    expect(inBand(find.byType(OutlinedButton)), findsNothing);
  });

  testWidgets('an alternative sits before the action, 8 apart', (
    WidgetTester tester,
  ) async {
    final List<String> pressed = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: tomTheme(Brightness.dark),
        home: Scaffold(
          body: SizedBox(
            width: width,
            child: NoticeBandWidget(
              sentence: 'preferences.json changed on disk.',
              ink: colors.modified,
              fill: colors.modifiedSoft,
              action: 'Reload',
              onAction: () => pressed.add('Reload'),
              alternative: 'Keep mine',
              onAlternative: () => pressed.add('Keep mine'),
            ),
          ),
        ),
      ),
    );

    final Rect keep = tester.getRect(
      inBand(find.widgetWithText(OutlinedButton, 'Keep mine')),
    );
    final Rect reload = tester.getRect(
      inBand(find.widgetWithText(OutlinedButton, 'Reload')),
    );
    expect(reload.left - keep.right, NoticeBandWidget.actionGap);
    expect(width - reload.right, NoticeBandWidget.actionInset);

    await tester.tap(find.text('Keep mine'));
    await tester.tap(find.text('Reload'));
    expect(pressed, <String>['Keep mine', 'Reload']);
  });
}
