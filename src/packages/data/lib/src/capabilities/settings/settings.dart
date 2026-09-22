/// Remembering something between runs, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/settings/settings_failure.dart';

/// A small store of per-machine preferences.
///
/// The capability behind "recent spaces" and, later, the chosen theme
/// ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)).
///
/// **Per machine, never per repository.** Nothing here is written into the
/// user's space: a file TOM puts inside someone's repository becomes a
/// compatibility obligation from its first release, and this product's whole
/// claim is that it owns no format
/// (`docs/technical/domain-model.md`).
///
/// **Strings in, strings out.** The store knows nothing about what it holds;
/// giving structure to the text is `tom_data`'s job, the same way it is for
/// git's output. That keeps this contract stable while what is stored
/// changes.
///
/// **Losing it is never fatal.** Everything kept here is a convenience the
/// app can rebuild or live without — which is why a read that fails answers
/// a failure rather than throwing, and why every caller is expected to carry
/// on.
abstract interface class Settings {
  /// What was stored under [key], or null if nothing was.
  ///
  /// Null is an ordinary answer, not a failure: the first run of the app has
  /// nothing stored under any key.
  Future<Result<String?, SettingsFailure>> read(String key);

  /// Stores [value] under [key], replacing whatever was there.
  Future<Result<void, SettingsFailure>> write(String key, String value);

  /// Removes [key], if it is there.
  ///
  /// Removing what was never stored succeeds: the caller wanted it gone, and
  /// it is.
  Future<Result<void, SettingsFailure>> remove(String key);
}
