/// Where this machine keeps an application's own files, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/platform_paths/platform_paths_failure.dart';

/// The folders TOM may write its per-machine files into.
///
/// A capability like the others ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md));
/// a sandboxed mobile app is handed its container instead
/// (`docs/technical/architecture.md#when-mobile-arrives-phase-3`). **Synchronous, where every
/// other capability is not**: it reads what the machine told the process at
/// start, and a `Future` would make the settings wiring async for a string.
abstract interface class PlatformPaths {
  /// The folder for this application's own files, not created here.
  ///
  /// `Filesystem.writeFile` makes the directories it needs, so the folder
  /// appears the first time something is actually stored.
  Result<String, PlatformPathsFailure> applicationData();
}
