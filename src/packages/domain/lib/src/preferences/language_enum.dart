/// Which language the app speaks.
library;

/// The four the product starts with.
///
/// **The list is not the feature.** What sits under it is: a language means
/// every literal the app shows becomes translatable, and nothing here does
/// that yet (`docs/product/preferences/what-it-holds/doc.md`).
enum LanguageEnum {
  /// English, which is what every literal is written in today.
  english('English'),

  /// Portuguese.
  portuguese('Português'),

  /// Spanish.
  spanish('Español'),

  /// German.
  german('Deutsch');

  const LanguageEnum(this.label);

  /// The language's own name for itself, which is how a chooser names it: a
  /// reader looking for their language is not reading the current one.
  ///
  /// **Not called `name`**, which would shadow `Enum.name` — the store
  /// writes the declared name and a generic reader compares against it, so
  /// the two would silently disagree about every language but English.
  final String label;
}
