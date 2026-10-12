/// Reading, writing and listing files on disk, behind a contract.
library;

import 'dart:typed_data';

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

  /// Reads the file at [path] as it is, for what is not text — an image an
  /// export embeds first.
  ///
  /// Fails with [FilesystemEntryNotFound] if nothing exists at [path].
  Future<Result<Uint8List, FilesystemFailure>> readBytes(String path);

  /// Writes [content] to the file at [path], creating or replacing it, with
  /// the parent directories it needs.
  ///
  /// The replacement is atomic — the file is either what it was or what it
  /// was asked to become, whatever happens to the machine mid-write. An
  /// implementation that cannot promise that does not fulfil this contract.
  ///
  /// What is replaced is the text and nothing else: a symbolic link stays a
  /// link and its target is written, and a file keeps the mode it had — so
  /// one nobody may write to refuses with [FilesystemAccessDenied].
  Future<Result<void, FilesystemFailure>> writeFile(
    String path,
    String content,
  );

  /// Writes [bytes] to the file at [path] as [writeFile] writes text: created
  /// or replaced, with its parent directories, atomically.
  ///
  /// For what is not text, an exported PDF first ([Decision
  /// 30](../../../../../../docs/technical/decisions/030-export-renders-the-preview-not-the-file.md)).
  Future<Result<void, FilesystemFailure>> writeBytes(
    String path,
    Uint8List bytes,
  );

  /// Creates the file at [path] holding [content], with the parent
  /// directories it needs — **only if nothing is there yet**.
  ///
  /// Fails with [FilesystemAlreadyExists] when the path is taken, and never
  /// replaces it: the check and the create are one operation on the machine,
  /// so two creates racing for one name cannot both succeed.
  Future<Result<void, FilesystemFailure>> createFile(
    String path,
    String content,
  );

  /// Creates an empty directory at [path], and any it needs above it.
  ///
  /// [FilesystemAlreadyExists] when anything — a folder or a file — already
  /// has that name, so a name somebody typed never quietly reuses one.
  Future<Result<void, FilesystemFailure>> createDirectory(String path);

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
  /// (`docs/product/home/opening-a-space/doc.md`); a failure when the machine will not say,
  /// which is a different answer.
  Future<Result<bool, FilesystemFailure>> directoryExists(String path);

  /// What is at [path], a link reported as itself, or null for nothing.
  ///
  /// Apart from [directoryExists], whose false also covers a file or a link:
  /// a caller about to remove what it made needs to tell the three apart.
  Future<Result<FilesystemEntryTypeEnum?, FilesystemFailure>> entryTypeOf(
    String path,
  );

  /// Removes what is at [path]: a file, a link but never what it points at,
  /// or a directory with everything below it.
  ///
  /// Nothing there is success, because nothing there is what was asked for.
  Future<Result<void, FilesystemFailure>> delete(String path);

  /// [path] with every symbolic link on it followed, as the machine spells
  /// the real location.
  ///
  /// What makes two spellings of one folder comparable: a picker answers with
  /// the link the user clicked, git with where it really is. Fails with
  /// [FilesystemEntryNotFound] if nothing exists at [path].
  Future<Result<String, FilesystemFailure>> resolvePath(String path);
}
