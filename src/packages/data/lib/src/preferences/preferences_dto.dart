/// The preferences as the store keeps them.
library;

import 'package:tom_domain/tom_domain.dart';

/// One JSON object, keys to strings, and the translation both ways.
///
/// Names rather than indexes, so reordering an enum cannot silently change
/// somebody's theme, and so the file stays readable — which is the point of
/// keeping it as JSON at all
/// (`docs/product/preferences/where-it-is-stored/doc.md`).
final class PreferencesDto {
  /// Creates the row.
  const PreferencesDto({
    required this.theme,
    required this.language,
    required this.showingFormattingBar,
  });

  /// [row] as a DTO, with anything missing or unreadable left null.
  factory PreferencesDto.fromRow(Map<String, Object?> row) => PreferencesDto(
    theme: row['theme'] is String ? row['theme']! as String : null,
    language: row['language'] is String ? row['language']! as String : null,
    showingFormattingBar: row['showingFormattingBar'] is bool
        ? row['showingFormattingBar']! as bool
        : null,
  );

  /// The theme's name, or null where the store had none.
  final String? theme;

  /// The language's name, or null.
  final String? language;

  /// Whether the formatting bar is drawn, or null.
  final bool? showingFormattingBar;

  /// The row this becomes in the file.
  Map<String, Object?> toRow() => <String, Object?>{
    if (theme != null) 'theme': theme,
    if (language != null) 'language': language,
    if (showingFormattingBar != null)
      'showingFormattingBar': showingFormattingBar,
  };

  /// [preferences] as a row.
  static PreferencesDto of(PreferencesValueObject preferences) =>
      PreferencesDto(
        theme: preferences.theme.name,
        language: preferences.language.name,
        showingFormattingBar: preferences.showingFormattingBar,
      );

  /// What this says, with the defaults standing in for anything it does not.
  PreferencesValueObject toValueObject() => PreferencesValueObject(
    theme: _named(ThemeChoiceEnum.values, theme, ThemeChoiceEnum.system),
    language: _named(LanguageEnum.values, language, LanguageEnum.english),
    showingFormattingBar: showingFormattingBar ?? true,
  );

  /// The member of [values] called [name], or [fallback].
  static T _named<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final T value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }
}
