import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/bootstrap/run_tom.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// No account read: reading one runs `gh`, git and `ssh`.
final class _NoAccount extends AccountNotifier {
  @override
  AccountState build() => const AccountState();
}

void main() {
  late _Preferences stored;

  setUp(() => stored = _Preferences());

  /// Mounts the whole window on Home, on a machine speaking [machine].
  Future<void> pumpApp(WidgetTester tester, {required Locale machine}) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = <Locale>[machine];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    // Home's trunk never stops moving, so `pumpAndSettle` never would.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    const _Silent silent = _Silent();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          accountProvider.overrideWith(_NoAccount.new),
          readPreferencesProvider.overrideWithValue(
            ReadPreferencesUseCase(preferences: stored),
          ),
          writePreferencesProvider.overrideWithValue(
            WritePreferencesUseCase(preferences: stored, observability: silent),
          ),
          listRecentSpacesProvider.overrideWithValue(
            const ListRecentSpacesUseCase(
              recents: _NoRecents(),
              observability: silent,
            ),
          ),
        ],
        child: const TomApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('System, the default, follows a Portuguese machine', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, machine: const Locale('pt', 'BR'));

    expect(find.byTooltip('Preferências'), findsOneWidget);
  });

  testWidgets('System on a machine speaking neither falls back to English', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, machine: const Locale('de', 'DE'));

    expect(find.byTooltip('Preferences'), findsOneWidget);
  });

  testWidgets('a chosen language wins over the machine', (
    WidgetTester tester,
  ) async {
    stored.held = const PreferencesValueObject(language: LanguageEnum.english);

    await pumpApp(tester, machine: const Locale('pt', 'BR'));

    expect(find.byTooltip('Preferences'), findsOneWidget);
  });

  testWidgets('choosing Português changes the window at once, popover too', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, machine: const Locale('en', 'US'));
    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    // The select names System; the theme's segment says it too.
    await tester.tap(find.text('System').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Português').last);
    await tester.pumpAndSettle();

    expect(stored.held.language, LanguageEnum.portuguese);
    expect(find.text('TEMA'), findsOneWidget);
    expect(find.text('Mostrar a barra de formatação'), findsOneWidget);
    expect(find.byTooltip('Preferências'), findsOneWidget);
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

/// A machine that has never opened a space.
final class _NoRecents implements RecentSpacesRepository {
  const _NoRecents();

  @override
  Future<Result<List<RecentSpaceEntity>, Never>> list() async =>
      const Success<List<RecentSpaceEntity>, Never>(<RecentSpaceEntity>[]);

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async =>
      const Success<void, Never>(null);

  @override
  Future<Result<void, Never>> forget(String root) async =>
      const Success<void, Never>(null);
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
