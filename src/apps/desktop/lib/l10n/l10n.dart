/// The interface's words, in the language the window speaks.
library;

import 'package:flutter/widgets.dart';
import 'package:tom_desktop/l10n/generated/app_localizations.dart';
import 'package:tom_domain/tom_domain.dart';

export 'package:tom_desktop/l10n/generated/app_localizations.dart';

/// [AppLocalizations] from any widget's context.
extension L10nContext on BuildContext {
  /// The words for this context's locale.
  ///
  /// English where no delegate is in scope: a widget test mounts a screen
  /// without the app's `MaterialApp`, and English is the template every key
  /// is written in first
  /// ([Decision 34](../../../../../docs/technical/decisions/034-the-interface-is-localised-with-gen-l10n.md)).
  AppLocalizations get l10n => AppLocalizations.of(this) ?? _english;
}

/// The template's words, for a context nobody localised.
final AppLocalizations _english = lookupAppLocalizations(const Locale('en'));

/// The locale [language] pins the window to, or null to follow the machine.
///
/// Null hands the choice to `MaterialApp`, which matches the platform's
/// locales against [AppLocalizations.supportedLocales] and falls back to the
/// first of them — English, by `preferred-supported-locales` in `l10n.yaml`.
Locale? localeOf(LanguageEnum language) => switch (language.code) {
  null => null,
  final String code => Locale(code),
};
