/// Reading and writing files on disk, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/filesystem/filesystem_failure.dart';

/// Reads and writes files at an absolute path.
///
/// The capability contract for storage ([Decision
/// 7](../../../../../../../docs/decisions/007-external-dependencies-behind-contracts.md)):
/// the file on disk is the truth for the whole product, so this is the
/// narrowest, most-depended-on capability in `tom_infra`. One implementation
/// today, `dart_io/`; a sandboxed mobile implementation is a sibling folder
/// when Phase 3 needs one, and this contract does not change.
abstract interface class Filesystem {
  /// Reads the file at [path] as text.
  ///
  /// Fails with [FilesystemEntryNotFound] if nothing exists at [path].
  Future<Result<String>> readFile(String path);

  /// Writes [content] to the file at [path], creating or overwriting it.
  Future<Result<void>> writeFile(String path, String content);
}
