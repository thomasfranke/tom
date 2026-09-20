/// Reading, writing and listing files on disk, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/filesystem/filesystem_entry.dart';
import 'package:tom_infra/src/filesystem/filesystem_entry_type.dart';
import 'package:tom_infra/src/filesystem/filesystem_failure.dart';

/// Reads, writes and lists files at an absolute path.
///
/// The capability contract for storage ([Decision
/// 7](../../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)):
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

  /// Every entry inside the directory at [path], sorted by path — and, with
  /// [recursive], everything below it too.
  ///
  /// Nothing is filtered out. The file tree hides `.git/` and keeps every
  /// other dotfolder (`docs/product/navigation/file-tree/doc.md`), which is
  /// the caller's policy and not this capability's.
  ///
  /// A symbolic link is reported as [FilesystemEntryType.link] and never
  /// followed: a link pointing at one of its own ancestors would otherwise
  /// make a recursive walk run forever.
  ///
  /// Fails with [FilesystemEntryNotFound] if no directory is at [path].
  Future<Result<List<FilesystemEntry>>> listDirectory(
    String path, {
    bool recursive = false,
  });

  /// Whether a directory exists at [path].
  ///
  /// False rather than a failure: a recent space whose folder was deleted or
  /// unmounted is a state Home offers to clean up, not an error
  /// (`docs/product/home/doc.md`). A parent the machine will not let it read
  /// is a different thing, and fails.
  Future<Result<bool>> directoryExists(String path);
}
