/// Which of the two themes the window draws.
library;

/// The reader's choice of theme, or the platform's.
///
/// The app's own enum rather than Flutter's `ThemeMode`, because this package
/// is pure Dart and may not reach a widget
/// ([Decision 14](../../../../../../docs/technical/decisions/014-each-layer-is-its-own-package.md)).
///
/// In the domain because the choice is **stored**: it is one of the three
/// preferences, and a value that crosses a repository belongs to the model
/// rather than to the window that draws it
/// (`docs/product/preferences/what-it-holds/doc.md`).
enum ThemeChoiceEnum {
  /// Whatever the operating system is set to; the state a window opens in.
  system,

  /// Light, chosen explicitly.
  light,

  /// Dark, chosen explicitly.
  dark,
}
