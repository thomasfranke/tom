import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/preferences/preferences_control_widget.dart';
import 'package:tom_desktop/screens/preferences/widgets/preferences_popover_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Preferences stored;
  late ProviderContainer container;

  setUp(() {
    stored = _Preferences();
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
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the button, under [brightness].
  Future<void> pumpControl(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    tester.view
      ..physicalSize = const Size(900, 600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(brightness),
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topRight,
              child: PreferencesControlWidget(),
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

  testWidgets('the language offers four, and the current one is ticked', (
    WidgetTester tester,
  ) async {
    await pumpControl(tester);
    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    for (final LanguageEnum language in LanguageEnum.values) {
      expect(find.text(language.label), findsWidgets);
    }
    // A tick, not a highlight alone — colour is never the only signal.
    // Scoped to the rows: the checkbox further down draws one of its own.
    expect(
      find.descendant(
        of: find.byType(MenuItemButton),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Português').last);
    await tester.pumpAndSettle();

    expect(now().language, LanguageEnum.portuguese);
  });

  testWidgets('the file button is drawn and cannot be pressed yet', (
    WidgetTester tester,
  ) async {
    // What it produces is a tab from outside the tree, and there is no tab
    // strip yet (`docs/design/screens/not-drawn-yet.md`).
    await pumpControl(tester);
    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    final OutlinedButton button = tester.widget(
      find.ancestor(
        of: find.text('Open preferences.json'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(button.onPressed, isNull);
  });
}

/// Preferences in memory, so a widget test needs no disk.
final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;

  @override
  Future<PreferencesValueObject> read() async => held;

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async {
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
