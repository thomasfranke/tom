import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/commands/commands_count_widget.dart';
import 'package:tom_desktop/screens/commands/commands_panel.dart';
import 'package:tom_desktop/screens/commands/widgets/command_row_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The commands tab against the board's numbers: a panel 1166 wide, the
/// document column of a 1440 window (`docs/product/workspace/commands/doc.md`).
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  const double width = 1166;

  void ran(
    List<String> arguments, {
    int? exitCode = 0,
    int milliseconds = 38,
    String stdout = '',
    String stderr = '',
    Set<int> answers = const <int>{},
    bool started = true,
  }) => container
      .read(commandsProvider.notifier)
      .record(
        CommandRecord.of(
          executable: 'git',
          arguments: arguments,
          startedAt: DateTime(2026, 10, 8, 14, 3, 12),
          duration: Duration(milliseconds: milliseconds),
          exitCode: exitCode,
          stdout: stdout,
          stderr: stderr,
          answers: answers,
          ran: started,
        ),
      );

  Future<void> pumpPanel(
    WidgetTester tester, {
    Brightness brightness = Brightness.dark,
    Locale? locale,
  }) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(brightness),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                height: 260,
                child: Column(
                  children: <Widget>[
                    CommandsCountWidget(),
                    Expanded(child: CommandsPanel()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder rowOf(String command) => find.ancestor(
    of: find.text(command),
    matching: find.byType(CommandRowWidget),
  );

  Future<TestGesture> hover(WidgetTester tester, String command) async {
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text(command)));
    await tester.pumpAndSettle();
    return mouse;
  }

  /// The fills drawn behind [row] — hover, failure, or none.
  List<Color?> fillsOf(WidgetTester tester, Finder row) => <Color?>[
    for (final DecoratedBox box in tester.widgetList<DecoratedBox>(
      find.descendant(of: row, matching: find.byType(DecoratedBox)),
    ))
      if (box.decoration case final BoxDecoration decoration) decoration.color,
  ];

  testWidgets('with nothing run yet it says so', (WidgetTester tester) async {
    await pumpPanel(tester);

    expect(find.text('No command has run yet.'), findsOneWidget);
    expect(find.text('0 this session'), findsOneWidget);
  });

  testWidgets('each row is the time, the command and how long it took', (
    WidgetTester tester,
  ) async {
    ran(<String>['status', '--porcelain=v2']);
    await pumpPanel(tester);

    expect(find.text('14:03:12'), findsOneWidget);
    expect(find.text('git status --porcelain=v2'), findsOneWidget);
    expect(find.text('38 ms'), findsOneWidget);
    expect(find.text('1 this session'), findsOneWidget);
    // At the board's x: the time at 14, the command at 110, the duration
    // ending 54 from the edge, the check centred on 94.
    expect(tester.getTopLeft(find.text('14:03:12')).dx, 14);
    expect(tester.getTopLeft(find.text('git status --porcelain=v2')).dx, 110);
    expect(tester.getTopRight(find.text('38 ms')).dx, width - 54);
    expect(tester.getCenter(find.byType(TomGlyphWidget)).dx, 94);
    expect(
      tester.widget<TomGlyphWidget>(find.byType(TomGlyphWidget)).color,
      TomColors.dark.added,
    );
  });

  testWidgets('newest at the bottom', (WidgetTester tester) async {
    ran(<String>['status']);
    ran(<String>['fetch'], milliseconds: 1240);
    await pumpPanel(tester);

    expect(
      tester.getTopLeft(find.text('git fetch')).dy,
      greaterThan(tester.getTopLeft(find.text('git status')).dy),
    );
    expect(find.text('1.2 s'), findsOneWidget);
  });

  testWidgets('a failure is tinted, crossed, and says how it ended', (
    WidgetTester tester,
  ) async {
    ran(<String>['push'], exitCode: 1, milliseconds: 1800);
    ran(<String>['fetch'], exitCode: null, milliseconds: 120000);
    await pumpPanel(tester);

    expect(find.text('exit 1 · 1.8 s'), findsOneWidget);
    expect(find.text('did not finish · 2 min 0 s'), findsOneWidget);
    expect(fillsOf(tester, rowOf('git push')), <Color?>[
      TomColors.dark.removedSoft,
    ]);
    final TomGlyphWidget cross = tester.widget<TomGlyphWidget>(
      find.descendant(
        of: rowOf('git push'),
        matching: find.byType(TomGlyphWidget),
      ),
    );
    expect(cross.glyph, TomGlyphEnum.close);
    expect(cross.color, TomColors.dark.removed);
  });

  group('an exit the app asked for as an answer', () {
    // `git config --get` of a key nobody set is 1, and that is the answer:
    // neither a check nor a cross, no tint, the code muted.
    for (final Brightness brightness in Brightness.values) {
      testWidgets('is neutral in ${brightness.name}', (
        WidgetTester tester,
      ) async {
        final TomColors colors = brightness == Brightness.dark
            ? TomColors.dark
            : TomColors.light;
        ran(
          <String>['config', '--get', 'user.name'],
          exitCode: 1,
          milliseconds: 23,
          answers: const <int>{1},
        );
        await pumpPanel(tester, brightness: brightness);
        final Finder row = rowOf('git config --get user.name');

        expect(
          find.descendant(of: row, matching: find.byType(TomGlyphWidget)),
          findsNothing,
        );
        expect(fillsOf(tester, row), isEmpty);
        expect(
          tester.widget<Text>(find.text('exit 1 · 23 ms')).style?.color,
          colors.textMuted,
        );
      });
    }

    testWidgets('but an exit it did not ask for is still a failure', (
      WidgetTester tester,
    ) async {
      ran(
        <String>['config', '--get', 'user.name'],
        exitCode: 128,
        answers: const <int>{1},
      );
      await pumpPanel(tester);

      expect(fillsOf(tester, rowOf('git config --get user.name')), <Color?>[
        TomColors.dark.removedSoft,
      ]);
    });
  });

  testWidgets('a program that could not start did not run', (
    WidgetTester tester,
  ) async {
    ran(<String>['status'], exitCode: null, milliseconds: 2, started: false);
    await pumpPanel(tester);

    expect(find.text('did not run · 2 ms'), findsOneWidget);
  });

  testWidgets('under the pointer a row lights up and offers the copy', (
    WidgetTester tester,
  ) async {
    final List<String?> copied = <String?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add(
            (call.arguments as Map<Object?, Object?>)['text'] as String?,
          );
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    ran(<String>['commit', '-m', "it's done"]);
    await pumpPanel(tester);
    expect(find.byTooltip('Copy the command'), findsNothing);

    const String line = r"git commit -m 'it'\''s done'";
    await hover(tester, line);

    expect(fillsOf(tester, rowOf(line)), <Color?>[TomColors.dark.control]);
    final Finder copy = find.byTooltip('Copy the command');
    expect(copy, findsOneWidget);
    expect(tester.getTopLeft(copy).dx, width - 26);

    await tester.tap(copy);
    await tester.pumpAndSettle();

    expect(copied, <String>[line]);
    expect(
      container.read(commandsProvider).expanded,
      isEmpty,
      reason: 'copying is not opening',
    );
  });

  testWidgets('a press opens the row onto what it printed, and closes it', (
    WidgetTester tester,
  ) async {
    ran(<String>['status'], stdout: '## main\n?? notes.md\n');
    ran(<String>['add']);
    await pumpPanel(tester);

    await tester.tap(find.text('git status'));
    await tester.pumpAndSettle();

    final Finder output = find.text('## main\n?? notes.md');
    expect(output, findsOneWidget);
    expect(tester.getTopLeft(output).dx, 110 + 8);
    // Two below the row, which is 24 tall.
    expect(
      tester.getTopLeft(output).dy -
          tester.getTopLeft(find.byType(CommandRowWidget).first).dy,
      24 + 2 + 8,
    );

    await tester.tap(find.text('git status'));
    await tester.pumpAndSettle();

    expect(output, findsNothing);
  });

  testWidgets('a row that printed nothing says so when opened', (
    WidgetTester tester,
  ) async {
    ran(<String>['add']);
    await pumpPanel(tester);

    await tester.tap(find.text('git add'));
    await tester.pumpAndSettle();

    expect(find.text('Printed nothing.'), findsOneWidget);
  });

  testWidgets('a failure asked for is opened in view', (
    WidgetTester tester,
  ) async {
    ran(<String>['fetch'], exitCode: 128, stderr: 'fatal: no network');
    for (int i = 0; i < 30; i++) {
      ran(<String>['status', '$i']);
    }
    await pumpPanel(tester);

    container.read(commandsProvider.notifier).revealLastFailure();
    await tester.pumpAndSettle();

    final Finder said = find.text('fatal: no network');
    expect(said, findsOneWidget);
    expect(tester.getRect(said).bottom, lessThanOrEqualTo(260));
    expect(tester.getRect(said).top, greaterThanOrEqualTo(0));
    expect(container.read(commandsProvider).revealing, isNull);
  });

  testWidgets('it reads the same in light', (WidgetTester tester) async {
    ran(<String>['push'], exitCode: 1);
    await pumpPanel(tester, brightness: Brightness.light);

    expect(fillsOf(tester, rowOf('git push')), <Color?>[
      TomColors.light.removedSoft,
    ]);
    expect(
      tester.widget<Text>(find.text('git push')).style?.color,
      TomColors.light.textPrimary,
    );
  });

  testWidgets('it speaks Portuguese too', (WidgetTester tester) async {
    ran(<String>['push'], exitCode: 1, milliseconds: 1800);
    ran(<String>['fetch'], exitCode: null, milliseconds: 2, started: false);
    await pumpPanel(tester, locale: const Locale('pt'));

    expect(find.text('2 nesta sessão'), findsOneWidget);
    expect(find.text('saída 1 · 1,8 s'), findsOneWidget);
    expect(find.text('não rodou · 2 ms'), findsOneWidget);
  });
}
