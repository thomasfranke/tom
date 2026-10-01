/// [TomDialogWidget] against the four boards that draw it (`docs/design/screens/desktop/**/*unsaved*`, `aborting-the-pull-*`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Brightness brightness = Brightness.light,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: tomTheme(brightness),
      home: Scaffold(body: child),
    ),
  );

  group('the dialog', () {
    testWidgets('asks the question and says what it costs', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        TomDialogWidget(
          title: 'Abort the pull?',
          body: const <String>[
            'The space goes back to what it was before the pull.',
            'What arrived from the remote stays fetched.',
          ],
          actions: <TomDialogAction>[
            TomDialogAction(label: 'Keep the conflict', onPressed: () {}),
            TomDialogAction(
              label: 'Abort the pull',
              onPressed: () {},
              destructive: true,
            ),
          ],
        ),
      );

      expect(find.text('Abort the pull?'), findsOneWidget);
      expect(
        find.text('The space goes back to what it was before the pull.'),
        findsOneWidget,
      );
      expect(
        find.text('What arrived from the remote stays fetched.'),
        findsOneWidget,
      );
    });

    testWidgets('is 400 wide, whatever it says', (WidgetTester tester) async {
      await pump(
        tester,
        TomDialogWidget(
          title: 'A question so long it would stretch a box that could grow',
          actions: <TomDialogAction>[
            TomDialogAction(label: 'Fine', onPressed: () {}),
          ],
        ),
      );

      expect(
        tester.getSize(find.byType(TomDialogWidget).first).width,
        greaterThanOrEqualTo(TomDialogWidget.width),
      );
      final Finder card = find.descendant(
        of: find.byType(TomDialogWidget),
        matching: find.byType(Container),
      );
      expect(tester.getSize(card.first).width, TomDialogWidget.width);
    });

    // Every board stacks them at the card's full width; a pair at the right
    // corner reads in two directions instead of one.
    testWidgets('stacks its actions, first one filled', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        TomDialogWidget(
          title: 'roadmap.md has unsaved changes.',
          actions: <TomDialogAction>[
            TomDialogAction(label: 'Save and switch', onPressed: () {}),
            TomDialogAction(label: 'Discard and switch', onPressed: () {}),
            TomDialogAction(label: 'Stay on this branch', onPressed: () {}),
          ],
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNWidgets(2));
      final Offset first = tester.getTopLeft(find.byType(FilledButton));
      final Offset second = tester.getTopLeft(
        find.byType(OutlinedButton).first,
      );
      expect(second.dx, first.dx, reason: 'stacked, not side by side');
      expect(second.dy, greaterThan(first.dy));
    });

    testWidgets('its actions are as tall and as wide as the board draws them',
        (WidgetTester tester) async {
      await pump(
        tester,
        TomDialogWidget(
          title: 'Abort the pull?',
          actions: <TomDialogAction>[
            TomDialogAction(label: 'Keep the conflict', onPressed: () {}),
            TomDialogAction(label: 'Abort the pull', onPressed: () {}),
          ],
        ),
      );

      final Size filled = tester.getSize(find.byType(FilledButton));
      expect(filled.height, TomDialogWidget.actionHeight);
      expect(
        filled.width,
        TomDialogWidget.width - TomDialogWidget.inset * 2,
      );
    });

    // The press that needs no thought is the one that changes nothing.
    testWidgets('the safe action is the filled one, never the destructive', (
      WidgetTester tester,
    ) async {
      final List<String> pressed = <String>[];
      await pump(
        tester,
        TomDialogWidget(
          title: 'Abort the pull?',
          actions: <TomDialogAction>[
            TomDialogAction(
              label: 'Keep the conflict',
              onPressed: () => pressed.add('keep'),
            ),
            TomDialogAction(
              label: 'Abort the pull',
              onPressed: () => pressed.add('abort'),
              destructive: true,
            ),
          ],
        ),
      );

      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.text('Keep the conflict'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Abort the pull'));
      await tester.pump();

      expect(pressed, <String>['abort']);
    });

    testWidgets('an action with nothing to do is unavailable', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const TomDialogWidget(
          title: 'Abort the pull?',
          actions: <TomDialogAction>[
            TomDialogAction(label: 'Keep the conflict', onPressed: null),
          ],
        ),
      );

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('it draws in the dark theme too', (WidgetTester tester) async {
      await pump(
        tester,
        TomDialogWidget(
          title: 'Abort the pull?',
          actions: <TomDialogAction>[
            TomDialogAction(label: 'Keep the conflict', onPressed: () {}),
          ],
        ),
        brightness: Brightness.dark,
      );

      expect(find.text('Abort the pull?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

}
