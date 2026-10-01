/// Reading and writing what the machine remembers.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/preferences/preferences_value_object.dart';

/// Where preferences come from and go back to.
///
/// **It cannot fail into nothing.** A read answers the defaults rather than
/// an error, because refusing to start over a preference file would be worse
/// than starting with the wrong theme
/// (`docs/product/preferences/where-it-is-stored/doc.md`).
abstract interface class PreferencesRepository {
  /// What is stored, or the defaults where anything is missing.
  Future<PreferencesValueObject> read();

  /// Stores [preferences], replacing what was there.
  ///
  /// A failure is reported rather than swallowed: the choice is already on
  /// screen, and the caller decides whether losing it between runs is worth
  /// saying.
  Future<Result<void, AppFailure>> write(PreferencesValueObject preferences);
}
