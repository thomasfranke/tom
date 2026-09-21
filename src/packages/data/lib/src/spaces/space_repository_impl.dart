/// The domain's space contract, fulfilled by the filesystem capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// [SpaceRepository] over the [Filesystem] capability.
///
/// The file tree's policy lives here: `.git/` is out, every other dotfolder
/// is in (`docs/product/navigation/file-tree/doc.md`). The capability
/// filters nothing on purpose — it has no idea what a space is — so this is
/// the layer that knows.
final class SpaceRepositoryImpl implements SpaceRepository {
  /// Creates a repository over [filesystem], for [space].
  const SpaceRepositoryImpl({required this.filesystem, required this.space});

  /// What lists the disk.
  final Filesystem filesystem;

  /// The space being listed.
  final Space space;

  /// What git keeps its repository in, and the one name the tree hides.
  ///
  /// Matched whatever it turns out to be: a folder in an ordinary clone, a
  /// *file* pointing elsewhere in a worktree or a submodule. Both are git's
  /// plumbing and neither is documentation.
  static const String _gitDirectory = '.git';

  @override
  Future<Result<List<SpaceEntry>>> entries() async {
    final List<SpaceEntry> collected = <SpaceEntry>[];
    final Result<void> walked = await _walk(
      space.root,
      collected,
      isRoot: true,
    );
    return switch (walked) {
      Success<void>() => Success<List<SpaceEntry>>(
        List<SpaceEntry>.unmodifiable(collected),
      ),
      Failure<void>(failure: final AppFailure failure) =>
        Failure<List<SpaceEntry>>(failure),
    };
  }

  /// Lists [directory], appending what it holds to [into], deepest last.
  ///
  /// One level at a time rather than [Filesystem.listDirectory] with
  /// `recursive: true`, for a reason that is not style: a recursive listing
  /// walks into `.git/` before anything can filter it out, and the `.git/`
  /// of a mature repository holds more entries than every document the
  /// product will ever show. Skipping a folder is only cheap if the decision
  /// is taken *before* descending into it.
  ///
  /// The children of a folder are appended immediately after it, so the flat
  /// list a caller receives is already in tree order.
  ///
  /// A folder below the root that the machine will not open is skipped and
  /// the rest is still returned: one unreadable folder costs that folder,
  /// not the file tree. [isRoot] is what makes the space's own folder the
  /// exception — a space whose root cannot be read has nothing to show.
  Future<Result<void>> _walk(
    String directory,
    List<SpaceEntry> into, {
    required bool isRoot,
  }) async {
    final Result<List<FilesystemEntry>> listed = await filesystem.listDirectory(
      directory,
    );
    if (listed case Failure<List<FilesystemEntry>>(
      failure: final AppFailure failure,
    )) {
      return isRoot ? Failure<void>(_asSpaceFailure(failure)) : _skipped;
    }
    for (final FilesystemEntry entry
        in (listed as Success<List<FilesystemEntry>>).value) {
      final SpaceRelativePath? path = space.relativize(entry.path);
      if (path == null || path.name == _gitDirectory) {
        continue;
      }
      into.add(SpaceEntry(path: path, type: _asSpaceEntryType(entry.type)));
      if (entry.type == FilesystemEntryType.directory) {
        await _walk(entry.path, into, isRoot: false);
      }
    }
    return _skipped;
  }

  /// A walk that produced whatever it could — the only success this has.
  static const Result<void> _skipped = Success<void>(null);

  /// The same kind, in the product's vocabulary.
  ///
  /// A one-to-one map today, and still written out: the two enums answer to
  /// different owners, and the day the capability learns to report something
  /// the tree has no place for, this is where the compiler will say so.
  static SpaceEntryType _asSpaceEntryType(FilesystemEntryType type) =>
      switch (type) {
        FilesystemEntryType.file => SpaceEntryType.file,
        FilesystemEntryType.directory => SpaceEntryType.directory,
        FilesystemEntryType.link => SpaceEntryType.link,
      };

  /// What the filesystem reported, about the space's folder.
  ///
  /// Exhaustive over [FilesystemFailure] with no default branch. The path is
  /// the capability's own — absolute, and inside a walk rarely the space
  /// root — because a [SpaceFailure] is about a folder on the machine, not
  /// about somewhere inside a space the user can navigate to.
  ///
  /// [FilesystemNotUtf8] cannot come from a listing: it is what reading a
  /// file's bytes answers. It is mapped rather than ignored because leaving
  /// it out would mean a default branch, and a default branch is what stops
  /// the next variant from breaking this.
  static AppFailure _asSpaceFailure(AppFailure failure) => switch (failure) {
    final FilesystemFailure filesystemFailure => switch (filesystemFailure) {
      FilesystemEntryNotFound(path: final String path) => SpaceFolderMissing(
        path,
      ),
      FilesystemAccessDenied(path: final String path) => SpaceAccessDenied(
        path,
      ),
      FilesystemNotUtf8(path: final String path) => SpaceOperationFailed(
        path,
        'not UTF-8',
      ),
      FilesystemOperationFailed(
        path: final String path,
        description: final String description,
      ) =>
        SpaceOperationFailed(path, description),
    },
    // Unreachable by the capability's contract: `Filesystem` returns nothing
    // else.
    _ => failure,
  };
}
