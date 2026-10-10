/// Remembering something between runs, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/settings/settings_failure.dart';

/// A small store of per-machine preferences, a JSON value under each key
/// ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)).
///
/// **Values, not text**: an object goes in as an object and is kept as one,
/// so the file reads the way a person would write it
/// (`docs/product/preferences/where-it-is-stored/doc.md`). **Per machine,
/// never per repository**, and **losing it is never fatal** — everything
/// here is a convenience the app can rebuild, so every caller carries on
/// past a failure.
abstract interface class Settings {
  /// What was stored under [key] — a map, a list, a string, a number, a
  /// bool — or null if nothing was, an ordinary answer on a first run.
  Future<Result<Object?, SettingsFailure>> read(String key);

  /// Stores [value] under [key], replacing whatever was there; anything
  /// `jsonEncode` cannot write is this capability's failure, not a throw.
  Future<Result<void, SettingsFailure>> write(String key, Object? value);

  /// Removes [key]; removing what was never stored succeeds.
  Future<Result<void, SettingsFailure>> remove(String key);
}
