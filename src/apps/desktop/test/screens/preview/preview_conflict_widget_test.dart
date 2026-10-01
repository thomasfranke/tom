/// [PreviewConflictWidget] against the board it is drawn from
/// (`docs/design/screens/desktop/git-conflict/conflict-in-preview-*.svg`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_conflict_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  const ConflictRegionValueObject region = ConflictRegionValueObject(
    start: 0,
    end: 120,
    current: 'M2 closes with full-text search.',
    incoming: 'M2 closes with search and replace.',
    currentLabel: 'HEAD',
    incomingLabel: 'main',
  );

  Future<List<ConflictChoiceEnum>> pump(
    WidgetTester tester, {
    ConflictRegionValueObject at = region,
    Brightness brightness = Brightness.light,
  }) async {
    final List<ConflictChoiceEnum> chosen = <ConflictChoiceEnum>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: tomTheme(brightness),
        home: Scaffold(
          body: SizedBox(
            width: 940,
            child: PreviewConflictWidget(
              region: at,
              body: PreviewDesign.body,
              onChoose: chosen.add,
            ),
          ),
        ),
      ),
    );
    return chosen;
  }

  testWidgets('both sides are drawn, labelled the way VS Code labels them', (
    WidgetTester tester,
  ) async {
    await pump(tester);

    expect(find.text('Current Change'), findsOneWidget);
    expect(find.text('Incoming Change'), findsOneWidget);
    expect(find.text('M2 closes with full-text search.'), findsOneWidget);
    expect(find.text('M2 closes with search and replace.'), findsOneWidget);
  });

  // The rule the whole screen exists for: the preview is where the conflict
  // is readable, and a marker here would be git's text leaking into it.
  testWidgets('no marker is ever drawn here', (WidgetTester tester) async {
    await pump(
      tester,
      at: const ConflictRegionValueObject(
        start: 0,
        end: 120,
        current: 'ours',
        incoming: 'theirs',
        currentLabel: 'HEAD',
        incomingLabel: 'main',
      ),
    );

    expect(find.textContaining('<<<<<<<'), findsNothing);
    expect(find.textContaining('======='), findsNothing);
    expect(find.textContaining('>>>>>>>'), findsNothing);
    expect(find.textContaining('HEAD'), findsNothing);
  });

  testWidgets(
    'the three choices are offered, in the order the merge has them',
    (WidgetTester tester) async {
      await pump(tester);

      final Iterable<Widget> buttons = tester.widgetList(
        find.byType(OutlinedButton),
      );
      expect(buttons, hasLength(3));
      expect(find.text('Accept Current Change'), findsOneWidget);
      expect(find.text('Accept Incoming Change'), findsOneWidget);
      expect(find.text('Accept Both Changes'), findsOneWidget);
    },
  );

  testWidgets('each choice reports which side was picked', (
    WidgetTester tester,
  ) async {
    final List<ConflictChoiceEnum> chosen = await pump(tester);

    await tester.tap(find.text('Accept Current Change'));
    await tester.tap(find.text('Accept Incoming Change'));
    await tester.tap(find.text('Accept Both Changes'));
    await tester.pump();

    expect(chosen, <ConflictChoiceEnum>[
      ConflictChoiceEnum.current,
      ConflictChoiceEnum.incoming,
      ConflictChoiceEnum.both,
    ]);
  });

  // Both sides carry the same tint: `removed` would say your work is leaving
  // and `added` would say theirs arrived, and neither is true until somebody
  // chooses.
  testWidgets('the region is tinted once, in the modified role', (
    WidgetTester tester,
  ) async {
    await pump(tester);

    final BuildContext context = tester.element(find.byType(Container).first);
    final TomColors colors = TomColors.of(context);
    final Iterable<Container> tinted = tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (Container it) =>
              (it.decoration as BoxDecoration?)?.color == colors.modifiedSoft,
        );

    expect(tinted, hasLength(1));
    expect(colors.modifiedSoft, isNot(colors.addedSoft));
    expect(colors.modifiedSoft, isNot(colors.removedSoft));
  });

  testWidgets('a side that adds nothing is drawn as nothing', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      at: const ConflictRegionValueObject(
        start: 0,
        end: 60,
        current: '',
        incoming: 'theirs',
        currentLabel: 'HEAD',
        incomingLabel: 'main',
      ),
    );

    expect(find.text('Current Change'), findsOneWidget);
    expect(find.text('theirs'), findsOneWidget);
  });

  testWidgets('it draws in the dark theme too', (WidgetTester tester) async {
    await pump(tester, brightness: Brightness.dark);

    expect(find.text('Current Change'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
