/// Where this machine keeps an application's own files, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/platform_paths/platform_paths_failure.dart';

/// The folders TOM may write its per-machine files into.
///
/// A capability like the others ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)):
/// what a folder is called is the platform's opinion, and a second
/// implementation is a sibling folder — a sandboxed mobile app is handed its
/// container rather than deriving it from a home directory (Phase 3, see
/// `layers.md#when-mobile-arrives-phase-3`).
///
/// **Synchronous, where every other capability is not.** The others touch
/// something that takes time to answer; this one reads what the machine
/// already told the process when it started. A `Future` here would turn the
/// composition root's settings wiring async for a string.
abstract interface class PlatformPaths {
  /// The folder for this application's own files.
  ///
  /// Not created here, and nothing has to create it: `Filesystem.writeFile`
  /// makes the directories its path needs, so the folder appears the first
  /// time something is actually stored and a user who never changes a
  /// preference never gets one.
  Result<String, PlatformPathsFailure> applicationData();
}
