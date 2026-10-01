/// The three preferences, applied as they are chosen.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/preferences/preferences_providers.dart';

part 'preferences_notifier.g.dart';

/// What the machine remembers, and the one place it is changed.
///
/// **A preference applies when it is chosen** — there is no OK and no Cancel,
/// so every setter writes the state first and the store after: the window
/// changes behind the popover, and a store that refused loses the choice
/// between runs rather than on screen
/// (`docs/product/preferences/the-popover/doc.md`).
///
/// Kept alive because the theme is read above the shell, by the window
/// itself: a provider nobody in the shell listened to would be disposed
/// between screens and the choice would go with it.
@Riverpod(keepAlive: true)
class PreferencesNotifier extends _$PreferencesNotifier {
  /// Reads what is stored.
  ReadPreferencesUseCase get readPreferences =>
      ref.read(readPreferencesProvider);

  /// Writes a choice back.
  WritePreferencesUseCase get writePreferences =>
      ref.read(writePreferencesProvider);

  @override
  PreferencesValueObject build() {
    // The defaults first and the file after: the window has to draw before
    // anything has been read, and the read is a disk trip.
    unawaited(Future<void>.microtask(_load));
    return PreferencesValueObject.defaults;
  }

  /// Draws [choice] from now on.
  void chooseTheme(ThemeChoiceEnum choice) =>
      _apply(state.copyWith(theme: choice));

  /// Speaks [language] from now on.
  ///
  /// Stored and nothing more, for now: no literal in the app is translatable
  /// yet (`docs/product/preferences/what-it-holds/doc.md`).
  void chooseLanguage(LanguageEnum language) =>
      _apply(state.copyWith(language: language));

  /// Shows the formatting bar, or puts it away.
  void toggleFormattingBar() =>
      _apply(state.copyWith(showingFormattingBar: !state.showingFormattingBar));

  /// Puts [chosen] on screen, then in the store.
  void _apply(PreferencesValueObject chosen) {
    state = chosen;
    unawaited(writePreferences.write(chosen));
  }

  /// Replaces the defaults with what the machine holds.
  Future<void> _load() async {
    final PreferencesValueObject stored = await readPreferences.read();
    if (!ref.mounted) {
      return;
    }
    state = stored;
  }
}
