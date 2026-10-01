import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

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

  /// Starts the notifier and answers its first state.
  PreferencesValueObject start() {
    container.listen<PreferencesValueObject>(preferencesProvider, (_, _) {});
    return container.read(preferencesProvider);
  }

  /// Everything scheduled, run.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  PreferencesValueObject now() => container.read(preferencesProvider);

  test('it draws the defaults before the file has been read', () {
    // The window has to draw before anything has been read, and the read is
    // a disk trip.
    expect(start(), PreferencesValueObject.defaults);
  });

  test('what the machine holds replaces them', () async {
    stored.held = const PreferencesValueObject(theme: ThemeChoiceEnum.dark);
    start();

    await settle();

    expect(now().theme, ThemeChoiceEnum.dark);
  });

  test('a choice applies at once, with no OK and no Cancel', () async {
    start();
    await settle();

    container.read(preferencesProvider.notifier).chooseTheme(
      ThemeChoiceEnum.light,
    );

    // On screen before the disk: the window changes behind the popover.
    expect(now().theme, ThemeChoiceEnum.light);
  });

  test('and it reaches the store', () async {
    start();
    await settle();

    container.read(preferencesProvider.notifier).chooseTheme(
      ThemeChoiceEnum.dark,
    );
    await settle();

    expect(stored.held.theme, ThemeChoiceEnum.dark);
  });

  test('the language is stored, and nothing yet reads it', () async {
    // No literal in the app is translatable: the list is not the feature.
    start();
    await settle();

    container.read(preferencesProvider.notifier).chooseLanguage(
      LanguageEnum.portuguese,
    );
    await settle();

    expect(now().language, LanguageEnum.portuguese);
    expect(stored.held.language, LanguageEnum.portuguese);
  });

  test('the formatting bar is a toggle, and it persists', () async {
    start();
    await settle();

    container.read(preferencesProvider.notifier).toggleFormattingBar();
    await settle();

    expect(now().showingFormattingBar, isFalse);
    expect(stored.held.showingFormattingBar, isFalse);
  });

  test('a store that refuses loses the choice between runs, not on screen', () {
    // The choice is already applied; there is nothing to take back.
    stored.refuses = true;
    start();

    container.read(preferencesProvider.notifier).toggleFormattingBar();

    expect(now().showingFormattingBar, isFalse);
  });

  test('one preference changing leaves the other two alone', () async {
    stored.held = const PreferencesValueObject(
      theme: ThemeChoiceEnum.dark,
      language: LanguageEnum.german,
      showingFormattingBar: false,
    );
    start();
    await settle();

    container.read(preferencesProvider.notifier).chooseTheme(
      ThemeChoiceEnum.light,
    );
    await settle();

    expect(stored.held.language, LanguageEnum.german);
    expect(stored.held.showingFormattingBar, isFalse);
  });
}

/// Preferences in memory, refusing to write when a test says so.
final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;
  bool refuses = false;

  @override
  Future<PreferencesValueObject> read() async => held;

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async {
    if (refuses) {
      return const Failure<void, AppFailure>(UnexpectedFailure('no store'));
    }
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
