/// What the machine remembers about how the app looks and speaks.
library;

import 'package:tom_domain/tom_domain.dart';

/// The stored preferences, or the defaults.
///
/// **No `guard` and no `Result`**, which is the one place in the app that is
/// true: this read cannot fail into anything a surface could draw, and the
/// repository already answers the defaults for a missing file, a missing key
/// or a value nobody can read
/// (`docs/product/preferences/where-it-is-stored/doc.md`).
final class ReadPreferencesUseCase {
  /// Creates the use case.
  const ReadPreferencesUseCase({required this.preferences});

  /// Where they are kept.
  final PreferencesRepository preferences;

  /// What this machine holds.
  Future<PreferencesValueObject> read() => preferences.read();
}
