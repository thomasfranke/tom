/// Which language the app speaks.
library;

/// The languages the interface is translated into, and the machine's own.
///
/// **A member is a translation that exists**: one added here without its ARB
/// file offers a language the window cannot speak
/// ([Decision 34](../../../../../../docs/technical/decisions/034-the-interface-is-localised-with-gen-l10n.md)).
enum LanguageEnum {
  /// Whatever the machine speaks, and English where that is neither of the
  /// others.
  system(null, null),

  /// English, which every string is written in first.
  english('en', 'English'),

  /// Brazilian Portuguese.
  portuguese('pt', 'Português');

  const LanguageEnum(this.code, this.label);

  /// The language's ISO 639-1 code, or null for [system].
  final String? code;

  /// The language's own name for itself, which is how a chooser names it: a
  /// reader looking for their language is not reading the current one. Null
  /// for [system], which the interface names in its own words.
  ///
  /// **Not called `name`**, which would shadow `Enum.name` — the store
  /// writes the declared name and a generic reader compares against it.
  final String? label;
}
