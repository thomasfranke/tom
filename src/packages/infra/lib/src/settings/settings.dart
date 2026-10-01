/// Remembering something between runs, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/settings/settings_failure.dart';

/// A small store of per-machine preferences, strings in and strings out
/// ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)).
///
/// **Per machine, never per repository**: a file TOM puts inside someone's
/// repository is a compatibility obligation, and this product owns no format
/// (`docs/technical/domain/open-questions.md`). **Losing it is never fatal** —
/// everything here is a convenience the app can rebuild, so every caller
/// carries on past a failure.
abstract interface class Settings {
  /// What was stored under [key], or null if nothing was — an ordinary
  /// answer, since a first run has nothing under any key.
  Future<Result<String?, SettingsFailure>> read(String key);

  /// Stores [value] under [key], replacing whatever was there.
  Future<Result<void, SettingsFailure>> write(String key, String value);

  /// Removes [key]; removing what was never stored succeeds.
  Future<Result<void, SettingsFailure>> remove(String key);
}
