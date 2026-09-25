/// Reading, writing and listing files on disk, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/src/filesystem/filesystem_failure.dart';

/// Reads, writes and lists files at an absolute path.
///
/// The storage capability ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)):
/// the file on disk is the truth for the whole product, so this is the
/// narrowest, most-depended-on capability in `tom_infra`.
abstract interface class Filesystem {
  /// Reads the file at [path] as UTF-8 text.
  ///
  /// Fails with [FilesystemEntryNotFound] if nothing exists at [path], and
  /// with [FilesystemNotUtf8] if what is there cannot be returned without
  /// losing a byte of it.
  Future<Result<String, FilesystemFailure>> readFile(String path);

  /// Writes [content] to the file at [path], creating or replacing it, with
  /// the parent directories it needs.
  ///
  /// The replacement is atomic — the file is either what it was or what it
  /// was asked to become, whatever happens to the machine mid-write. An
  /// implementation that cannot promise that does not fulfil this contract.
  Future<Result<void, FilesystemFailure>> writeFile(
    String path,
    String content,
  );

  /// Every entry inside the directory at [path], sorted by path — and, with
  /// [recursive], everything below it too.
  ///
  /// Nothing is filtered out: hiding `.git/` is the file tree's policy, not
  /// this capability's. A link is reported as [FilesystemEntryTypeEnum.link]
  /// and never followed, or a link to an ancestor would walk forever. A
  /// directory below [path] the machine will not open is skipped, with the
  /// rest still returned; only [path] itself failing fails the listing, with
  /// [FilesystemEntryNotFound] when no directory is there.
  Future<Result<List<FilesystemEntryDto>, FilesystemFailure>> listDirectory(
    String path, {
    bool recursive = false,
  });

  /// Whether a directory exists at [path].
  ///
  /// False for a folder that is gone, which Home offers to clean up
  /// (`docs/product/home/doc.md`); a failure when the machine will not say,
  /// which is a different answer.
  Future<Result<bool, FilesystemFailure>> directoryExists(String path);

  /// [path] with every symbolic link on it followed, as the machine spells
  /// the real location.
  ///
  /// What makes two spellings of one folder comparable: a picker answers with
  /// the link the user clicked, git with where it really is. Fails with
  /// [FilesystemEntryNotFound] if nothing exists at [path].
  Future<Result<String, FilesystemFailure>> resolvePath(String path);
}
