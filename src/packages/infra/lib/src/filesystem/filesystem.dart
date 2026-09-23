/// Reading, writing and listing files on disk, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
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
  /// Reads the file at [path] as UTF-8 text.
  ///
  /// Fails with [FilesystemEntryNotFound] if nothing exists at [path], and
  /// with [FilesystemNotUtf8] if what is there is not text this capability
  /// can return without losing a byte of it.
  Future<Result<String, FilesystemFailure>> readFile(String path);

  /// Writes [content] to the file at [path], creating or replacing it.
  ///
  /// Parent directories that do not exist yet are created: a document saved
  /// into a folder the user just named is a create, and reporting it as
  /// [FilesystemEntryNotFound] would name the wrong thing.
  ///
  /// The replacement is atomic — the file at [path] is either what it was or
  /// what it was asked to become, never half of either, whatever happens to
  /// the machine mid-write. An implementation that cannot promise that is not
  /// an implementation of this contract: the files are the truth for the
  /// whole product.
  Future<Result<void, FilesystemFailure>> writeFile(
    String path,
    String content,
  );

  /// Every entry inside the directory at [path], sorted by path — and, with
  /// [recursive], everything below it too.
  ///
  /// Nothing is filtered out. The file tree hides `.git/` and keeps every
  /// other dotfolder (`docs/product/navigation/file-tree/doc.md`), which is
  /// the caller's policy and not this capability's.
  ///
  /// A symbolic link is reported as [FilesystemEntryTypeEnum.link] and never
  /// followed: a link pointing at one of its own ancestors would otherwise
  /// make a recursive walk run forever.
  ///
  /// A directory below [path] that the machine will not open is skipped,
  /// with everything else still returned: one unreadable folder inside a
  /// space costs that folder, not the file tree. Only [path] itself failing
  /// fails the listing.
  ///
  /// Fails with [FilesystemEntryNotFound] if no directory is at [path].
  Future<Result<List<FilesystemEntryDto>, FilesystemFailure>> listDirectory(
    String path, {
    bool recursive = false,
  });

  /// Whether a directory exists at [path].
  ///
  /// False rather than a failure: a recent space whose folder was deleted or
  /// unmounted is a state Home offers to clean up, not an error
  /// (`docs/product/home/doc.md`). A parent the machine will not let it read
  /// is a different thing, and fails.
  Future<Result<bool, FilesystemFailure>> directoryExists(String path);
}
