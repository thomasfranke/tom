import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/workspace/workspace_controls_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Preferences preferences;
  late ProviderContainer container;

  setUp(() {
    preferences = _Preferences();
    container = ProviderContainer(
      overrides: <Override>[
        readPreferencesProvider.overrideWithValue(
          ReadPreferencesUseCase(preferences: preferences),
        ),
        writePreferencesProvider.overrideWithValue(
          WritePreferencesUseCase(
            preferences: preferences,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the group under [brightness], which is what the theme control
  /// reads to decide what it offers.
  Future<void> pumpControls(
    WidgetTester tester, {
    Brightness brightness = Brightness.dark,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(brightness),
          home: const Scaffold(body: Center(child: WorkspaceControlsWidget())),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  WorkspaceState state() => container.read(workspaceProvider);

  testWidgets('it is three controls, read left to right', (
    WidgetTester tester,
  ) async {
    // One set: the two columns, then the gear
    // (`docs/product/preferences/the-popover/doc.md`).
    await pumpControls(tester);

    expect(find.byType(TomPanelToggleWidget), findsNWidgets(2));
    expect(find.byTooltip('Preferences'), findsOneWidget);
    expect(
      tester.getCenter(find.byType(TomPanelToggleWidget).first).dx,
      lessThan(tester.getCenter(find.byTooltip('Preferences')).dx),
    );
  });

  testWidgets('both columns open at the start, and each toggle closes one', (
    WidgetTester tester,
  ) async {
    await pumpControls(tester);
    expect(state().showingExplorer, isTrue);
    expect(state().showingAside, isTrue);

    await tester.tap(find.byTooltip('Hide explorer'));
    await tester.pumpAndSettle();

    expect(state().showingExplorer, isFalse);
    expect(
      state().showingAside,
      isTrue,
      reason: 'one toggle hides one column, never the other',
    );
  });

  testWidgets('a hidden column says how to bring it back', (
    WidgetTester tester,
  ) async {
    await pumpControls(tester);

    await tester.tap(find.byTooltip('Hide git'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Show git'), findsOneWidget);
  });

  testWidgets('the theme is no longer a control of its own', (
    WidgetTester tester,
  ) async {
    // It moved inside the preferences popover, and the gear took its place —
    // the bar trades one control for another rather than squeezing a fourth
    // into the same margin (`docs/product/preferences/the-popover/doc.md`).
    await pumpControls(tester);

    expect(find.byTooltip('Light theme'), findsNothing);
    expect(find.byTooltip('Dark theme'), findsNothing);
    expect(find.byType(TomThemeToggleWidget), findsNothing);
  });

  testWidgets('the gear is the last of the three, after both toggles', (
    WidgetTester tester,
  ) async {
    await pumpControls(tester);

    expect(find.byTooltip('Preferences'), findsOneWidget);
    expect(
      tester.getCenter(find.byTooltip('Preferences')).dx,
      greaterThan(tester.getCenter(find.byTooltip('Hide git')).dx),
    );
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
