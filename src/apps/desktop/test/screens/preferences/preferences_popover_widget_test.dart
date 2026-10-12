import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/preferences/preferences_control_widget.dart';
import 'package:tom_desktop/screens/preferences/widgets/preferences_popover_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

import '../../support/load_tom_faces.dart';

void main() {
  late _Preferences stored;
  late _Approvals approvals;
  late ProviderContainer container;

  setUp(() {
    stored = _Preferences();
    approvals = _Approvals();
    container = ProviderContainer(
      overrides: <Override>[
        readPreferencesProvider.overrideWithValue(
          ReadPreferencesUseCase(preferences: stored),
        ),
        writePreferencesProvider.overrideWithValue(
          WritePreferencesUseCase(
            preferences: stored,
            observability: const _Silent(),
          ),
        ),
        preferencesFileProvider.overrideWithValue(
          SpaceRelativePathValueObject('preferences.json'),
        ),
        seedApprovalsProvider.overrideWithValue(
          SeedApprovalsUseCase(
            approvals: approvals,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the button, under [brightness], speaking [locale].
  Future<void> pumpControl(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    Locale locale = const Locale('en'),
    bool atTheBoard = false,
  }) async {
    // The board's window puts the gear's 24 box at x 1368, y 8.
    tester.view
      ..physicalSize = atTheBoard ? const Size(1440, 900) : const Size(900, 600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(brightness),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: Scaffold(
            body: atTheBoard
                ? const Stack(
                    children: <Widget>[
                      Positioned(
                        left: 1368,
                        top: 8,
                        child: PreferencesControlWidget(),
                      ),
                    ],
                  )
                // The account button ends the bar, 34 to the gear's right.
                : const Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 34),
                      child: PreferencesControlWidget(),
                    ),
                  ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  PreferencesValueObject now() => container.read(preferencesProvider);

  testWidgets('the gear opens a popover, and opens nothing before it', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester);
    expect(find.byType(PreferencesPopoverWidget), findsNothing);

    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    expect(find.byType(PreferencesPopoverWidget), findsOneWidget);
  });

  testWidgets('pressing it again closes it, which is the visible way out', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester);
    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    expect(find.byType(PreferencesPopoverWidget), findsNothing);
  });

  testWidgets('it hangs from the button, never off the window', (
    WidgetTester tester,
  ) async {
    // A control at the right of a bar with a popover under its left edge
    // lands off the window — the trap the branch switcher paid for.
    await pumpControl(tester);

    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    final Rect card = tester.getRect(find.byType(PreferencesPopoverWidget));
    expect(card.left, greaterThanOrEqualTo(0));
    expect(card.right, lessThanOrEqualTo(900));
  });

  testWidgets('it holds three preferences and the file behind them', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester);

    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    expect(find.text('THEME'), findsOneWidget);
    expect(find.text('LANGUAGE'), findsOneWidget);
    expect(find.text('Show the formatting bar'), findsOneWidget);
    expect(find.text('Open preferences.json'), findsOneWidget);
  });

  testWidgets('on a fresh preferences file the update check is ticked', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester);
    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    // The two boxes, in the order they are drawn: the formatting bar's, then
    // the update check's.
    final List<TomCheckWidget> boxes = tester
        .widgetList<TomCheckWidget>(find.byType(TomCheckWidget))
        .toList();
    expect(boxes, hasLength(2));
    expect(boxes.last.isChecked, isTrue);
    expect(now().checkingForUpdates, isTrue);

    await tester.tap(find.text('Check for updates when TOM opens'));
    await tester.pumpAndSettle();

    expect(now().checkingForUpdates, isFalse);
  });

  testWidgets('in Portuguese, every word of the popover is translated', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester, locale: const Locale('pt'));

    await tester.tap(find.byTooltip('Preferências'));
    await tester.pumpAndSettle();

    expect(find.text('TEMA'), findsOneWidget);
    expect(find.text('IDIOMA'), findsOneWidget);
    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Escuro'), findsOneWidget);
    // The theme's segment and the language's select, both following the
    // machine; the languages keep their own names.
    expect(find.text('Sistema'), findsNWidgets(2));
    expect(find.text('Mostrar a barra de formatação'), findsOneWidget);
    expect(find.text('Abrir preferences.json'), findsOneWidget);
    expect(find.text('THEME'), findsNothing);
  });

  testWidgets('a theme applies when it is pressed, with no OK', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester);
    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    // Closing decides nothing, because pressing already did.
    expect(now().theme, ThemeChoiceEnum.dark);
    expect(find.byType(PreferencesPopoverWidget), findsOneWidget);
  });

  testWidgets('the theme offers System beside Light and Dark, and lights '
      'the choice rather than the colour on screen', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester);
    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    // The theme's segment first; the language's select says System too.
    expect(find.text('System'), findsNWidgets(2));
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('System').first);
    await tester.pumpAndSettle();

    expect(now().theme, ThemeChoiceEnum.system);
    // The lit segment is the one wearing `control`, whatever theme System
    // landed on.
    final Iterable<DecoratedBox> lit = tester
        .widgetList<DecoratedBox>(
          find.ancestor(
            of: find.text('System').first,
            matching: find.byType(DecoratedBox),
          ),
        )
        .where(
          (DecoratedBox box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).color != null &&
              (box.decoration as BoxDecoration).color != Colors.transparent,
        );
    expect(lit, isNotEmpty);
  });

  testWidgets('the checkbox takes the formatting bar away', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester);
    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show the formatting bar'));
    await tester.pumpAndSettle();

    expect(now().showingFormattingBar, isFalse);
  });

  testWidgets('the language offers System, English and Português — the two '
      'translations — and ticks the current one', (WidgetTester tester) async {
    await pumpControl(tester);
    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    // System is the default, so it is what the select names.
    await tester.tap(find.text('System').last);
    await tester.pumpAndSettle();

    expect(find.byType(MenuItemButton), findsNWidgets(3));
    for (final String language in <String>['System', 'English', 'Português']) {
      expect(
        find.descendant(
          of: find.byType(MenuItemButton),
          matching: find.text(language),
        ),
        findsOneWidget,
      );
    }
    // Offered once, before any translation existed.
    expect(find.text('Español'), findsNothing);
    expect(find.text('Deutsch'), findsNothing);
    // A tick, not a highlight alone — colour is never the only signal.
    // Scoped to the rows: the checkbox further down draws one of its own.
    expect(
      find.descendant(
        of: find.byType(MenuItemButton),
        matching: find.byType(TomGlyphWidget),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Português').last);
    await tester.pumpAndSettle();

    expect(now().language, LanguageEnum.portuguese);
    // The menu opens in the overlay; choosing there is not a tap outside.
    expect(find.byType(PreferencesPopoverWidget), findsOneWidget);
  });

  // The numbers of `preferences/preferences-dark.svg`, measured off a render
  // of it: the card 280 wide with its top at y 38 and its right edge at
  // x 1394, the select 32 and the two buttons 34 tall, the boxes 26 apart.
  group('at the size the boards draw it', () {
    setUpAll(loadTomFaces);

    Future<Rect> open(WidgetTester tester) async {
      await pumpControl(tester, atTheBoard: true);
      await tester.tap(find.byTooltip('Preferences'));
      await tester.pumpAndSettle();
      return tester.getRect(find.byType(PreferencesPopoverWidget));
    }

    Finder button(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byType(OutlinedButton),
    );

    testWidgets('the card hangs 38 from the top, its right edge at 1394', (
      WidgetTester tester,
    ) async {
      final Rect card = await open(tester);

      expect(card.top, 38);
      expect(card.right, 1394);
      expect(card.width, 280);
      // 486 rows from the top stroke to the bottom one on the board, whose
      // sentence under the git control runs three lines: take the sentence
      // out, whatever length the copy has, and what is left is the board's
      // 486 less its 48.3.
      final double why = tester
          .getSize(
            find.text(
              'Every command runs as soon as it is asked for; the Commands '
              'panel only keeps the record.',
            ),
          )
          .height;
      expect(card.height - why, closeTo(486 - 3 * 16.1, 1));
    });

    testWidgets('it keeps 13 from the edge on both sides', (
      WidgetTester tester,
    ) async {
      final Rect card = await open(tester);

      final Rect select = tester.getRect(find.byType(MenuAnchor));
      expect(select.left - card.left, 13);
      expect(card.right - select.right, 13);
      expect(select.width, 254);
    });

    testWidgets('the select is 32 tall and ends in a down chevron', (
      WidgetTester tester,
    ) async {
      await open(tester);

      expect(tester.getSize(find.byType(MenuAnchor)).height, 32);
      expect(
        find.descendant(
          of: find.byType(MenuAnchor),
          matching: find.byWidgetPredicate(
            (Widget w) => w is TomChevronWidget && w.isOpen,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('both Open buttons are 34 tall and lead with a document', (
      WidgetTester tester,
    ) async {
      await open(tester);

      for (final String label in <String>[
        'Open git-approvals.json',
        'Open preferences.json',
      ]) {
        expect(tester.getSize(button(label)).height, 34, reason: label);
        expect(
          find.descendant(
            of: button(label),
            matching: find.byWidgetPredicate(
              (Widget w) => w is TomGlyphWidget && w.glyph == TomGlyphEnum.file,
            ),
          ),
          findsOneWidget,
          reason: label,
        );
      }
    });

    testWidgets('the checkboxes are 26 apart, the first 138 under the top', (
      WidgetTester tester,
    ) async {
      final Rect card = await open(tester);

      final Offset first = tester.getTopLeft(find.byType(TomCheckWidget).at(0));
      final Offset second = tester.getTopLeft(
        find.byType(TomCheckWidget).at(1),
      );
      expect(second.dy - first.dy, 26);
      expect(first.dy - card.top, closeTo(138, 1));
    });

    testWidgets('the theme control starts 31 under the top, 28 tall', (
      WidgetTester tester,
    ) async {
      final Rect card = await open(tester);

      // A segment is the control's 28 less its 2 of inset on both sides.
      final Rect segment = tester.getRect(
        find
            .ancestor(
              of: find.text('Light'),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(segment.top - card.top, 31 + 2);
      expect(segment.height, 28 - 2 * 2);
    });

    Finder rules() => find.descendant(
      of: find.byType(PreferencesPopoverWidget),
      matching: find.byWidgetPredicate(
        (Widget w) => w is CustomPaint && w.painter is TomRulePainter,
      ),
    );

    testWidgets('two rules, one above each of the last two rows, each '
        'running from stroke to stroke', (WidgetTester tester) async {
      final Rect card = await open(tester);

      expect(rules(), findsNWidgets(2));
      for (final Element rule in rules().evaluate()) {
        final Rect box = tester.getRect(find.byWidget(rule.widget));
        // 278 of the board's `preferences-light.svg`: x 1115 to 1393, inside
        // the card's own stroke on both sides.
        expect(box.left, card.left + 1);
        expect(box.right, card.right - 1);
        expect(box.height, 1);
      }
    });

    testWidgets('the language select wears the theme track fill and stroke, '
        'in light and the same roles in dark', (WidgetTester tester) async {
      await open(tester);

      final OutlinedButton select = tester.widget<OutlinedButton>(
        find.descendant(
          of: find.byType(MenuAnchor),
          matching: find.byType(OutlinedButton),
        ),
      );
      final TomColors colors = TomColors.of(
        tester.element(find.byType(PreferencesPopoverWidget)),
      );
      final Set<WidgetState> none = <WidgetState>{};
      expect(
        select.style!.backgroundColor!.resolve(none),
        colors.surfaceSunken,
      );
      expect(select.style!.side!.resolve(none)!.color, colors.border);
      // `#ECEAE5` on `preferences-light.svg`, rect at x 1128, y 130.
      expect(colors.surfaceSunken, const Color(0xFFECEAE5));
    });

    testWidgets('the gear is ringed while it is open, and only then', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester, atTheBoard: true);
      expect(find.byKey(const Key('gearRing')), findsNothing);

      await tester.tap(find.byTooltip('Preferences'));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.byKey(const Key('gearRing'))),
        const Rect.fromLTWH(1369, 7, 26, 26),
      );

      await tester.tap(find.byTooltip('Preferences'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('gearRing')), findsNothing);
    });
  });

  OutlinedButton fileButton(WidgetTester tester) => tester.widget(
    find.ancestor(
      of: find.text('Open preferences.json'),
      matching: find.byType(OutlinedButton),
    ),
  );

  testWidgets('the file button opens the file in a tab, and the popover '
      'goes', (WidgetTester tester) async {
    // A tab from outside the tree
    // (`docs/product/preferences/where-it-is-stored/doc.md`).
    container
        .read(spaceSessionProvider.notifier)
        .open(
          SpaceEntity(
            root: '/code/docs',
            repositoryRoot: '/code/docs',
            name: 'docs',
          ),
        );
    await pumpControl(tester);
    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open preferences.json'));
    await tester.pumpAndSettle();

    expect(find.byType(PreferencesPopoverWidget), findsNothing);
    expect(
      container.read(spaceSessionProvider)?.appFile,
      SpaceRelativePathValueObject('preferences.json'),
    );
    // What is in force is in the file before it is shown.
    expect(stored.writes, 1);
  });

  testWidgets('on Home the file button is dim: there are no tabs there', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester);
    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    expect(fileButton(tester).onPressed, isNull);
  });

  group('git commands', () {
    OutlinedButton approvalsButton(WidgetTester tester) => tester.widget(
      find.ancestor(
        of: find.text('Open git-approvals.json'),
        matching: find.byType(OutlinedButton),
      ),
    );

    testWidgets('the section names the default and says what it does', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester);
      await tester.tap(find.byTooltip('Preferences'));
      await tester.pumpAndSettle();

      expect(find.text('GIT COMMANDS'), findsOneWidget);
      for (final String mode in <String>['Automatic', 'Semi', 'Manual']) {
        expect(find.text(mode), findsOneWidget);
      }
      expect(now().gitApprovals, GitApprovalModeEnum.automatic);
      expect(
        find.text(
          'Every command runs as soon as it is asked for; the Commands panel '
          'only keeps the record.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('each mode applies when pressed, is stored, and is explained '
        'in one sentence', (WidgetTester tester) async {
      await pumpControl(tester);
      await tester.tap(find.byTooltip('Preferences'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Semi'));
      await tester.pumpAndSettle();

      expect(now().gitApprovals, GitApprovalModeEnum.semi);
      expect(stored.held.gitApprovals, GitApprovalModeEnum.semi);
      expect(
        find.text(
          'A command waits for your approval unless git-approvals.json '
          'allows it.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Manual'));
      await tester.pumpAndSettle();

      expect(now().gitApprovals, GitApprovalModeEnum.manual);
      expect(stored.held.gitApprovals, GitApprovalModeEnum.manual);
      expect(
        find.text('Every command waits for your approval, reads included.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Automatic'));
      await tester.pumpAndSettle();

      expect(now().gitApprovals, GitApprovalModeEnum.automatic);
      // Pressing decided; the popover is still open.
      expect(find.byType(PreferencesPopoverWidget), findsOneWidget);
    });

    for (final (
          String name,
          Brightness brightness,
          Locale locale,
          List<String> words,
        )
        in <(String, Brightness, Locale, List<String>)>[
          (
            'light',
            Brightness.light,
            const Locale('en'),
            <String>['Automatic', 'Semi', 'Manual'],
          ),
          (
            'dark',
            Brightness.dark,
            const Locale('en'),
            <String>['Automatic', 'Semi', 'Manual'],
          ),
          (
            'pt-BR',
            Brightness.light,
            const Locale('pt'),
            <String>['Automático', 'Semi', 'Manual'],
          ),
        ]) {
      testWidgets('only the chosen mode is bold ($name)', (
        WidgetTester tester,
      ) async {
        await pumpControl(tester, brightness: brightness, locale: locale);
        await tester.tap(
          find.byTooltip(
            locale.languageCode == 'pt' ? 'Preferências' : 'Preferences',
          ),
        );
        await tester.pumpAndSettle();

        FontWeight? weightOf(String word) =>
            tester.widget<Text>(find.text(word)).style?.fontWeight;

        // Automatic is the default: it alone is semibold.
        expect(weightOf(words[0]), TomFonts.segmentChosen);
        expect(weightOf(words[1]), TomFonts.segmentRest);
        expect(weightOf(words[2]), TomFonts.segmentRest);
        expect(TomFonts.segmentChosen, FontWeight.w600);
        expect(TomFonts.segmentRest, FontWeight.w400);

        await tester.tap(find.text(words[2]));
        await tester.pumpAndSettle();
        expect(weightOf(words[0]), TomFonts.segmentRest);
        expect(weightOf(words[2]), TomFonts.segmentChosen);
      });
    }

    testWidgets('in Portuguese the section and its sentences are translated', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester, locale: const Locale('pt'));
      await tester.tap(find.byTooltip('Preferências'));
      await tester.pumpAndSettle();

      expect(find.text('COMANDOS DO GIT'), findsOneWidget);
      expect(find.text('Automático'), findsOneWidget);
      expect(find.text('Abrir git-approvals.json'), findsOneWidget);
      expect(find.text('GIT COMMANDS'), findsNothing);
    });

    testWidgets('the list opens in a tab, seeded first, and the popover '
        'goes', (WidgetTester tester) async {
      container
          .read(spaceSessionProvider.notifier)
          .open(
            SpaceEntity(
              root: '/code/docs',
              repositoryRoot: '/code/docs',
              name: 'docs',
            ),
          );
      await pumpControl(tester);
      await tester.tap(find.byTooltip('Preferences'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open git-approvals.json'));
      await tester.pumpAndSettle();

      expect(find.byType(PreferencesPopoverWidget), findsNothing);
      expect(
        container.read(spaceSessionProvider)?.appFile,
        PreferencesNotifier.approvalsFile,
      );
      expect(approvals.seeded, 1);
    });

    testWidgets('on Home the list button is dim, as the other file is', (
      WidgetTester tester,
    ) async {
      await pumpControl(tester);
      await tester.tap(find.byTooltip('Preferences'));
      await tester.pumpAndSettle();

      expect(approvalsButton(tester).onPressed, isNull);
    });
  });
}

/// `git-approvals.json`, in memory.
final class _Approvals implements ApprovalsRepository {
  int seeded = 0;

  @override
  Future<ApprovalsValueObject> read() async => ApprovalsValueObject.none;

  @override
  Future<Result<void, AppFailure>> write(
    String key, {
    required bool allowed,
  }) async => const Success<void, AppFailure>(null);

  @override
  Future<Result<void, AppFailure>> seed() async {
    seeded++;
    return const Success<void, AppFailure>(null);
  }
}

/// Preferences in memory, so a widget test needs no disk.
final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;
  int writes = 0;

  @override
  Future<PreferencesValueObject> read() async => held;

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async {
    writes++;
    held = preferences;
    return const Success<void, AppFailure>(null);
  }
}

/// The no-op observability, which is also the shipping default.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
