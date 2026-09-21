/// The domain's space contract, fulfilled by the filesystem and by git.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// [SpaceRepository] over the [Filesystem] and [GitClient] capabilities.
///
/// Two jobs that look unrelated and are not. Opening a folder asks git where
/// the repository is; listing one asks the disk what is inside. Both are
/// about the *folder* a space is, which is why they are one contract and why
/// the failures they produce send the user to another space rather than to
/// another file.
///
/// The file tree's policy lives here too: `.git/` is out, every other
/// dotfolder is in (`docs/product/navigation/file-tree/doc.md`). The
/// capability filters nothing on purpose — it has no idea what a space is —
/// so this is the layer that knows.
final class SpaceRepositoryImpl implements SpaceRepository {
  /// Creates a repository over [filesystem], making git clients with
  /// [gitClientFor].
  const SpaceRepositoryImpl({
    required this.filesystem,
    required this.gitClientFor,
  });

  /// What lists the disk.
  final Filesystem filesystem;

  /// How to get a git client for a folder the user just picked.
  final GitClientFor gitClientFor;

  /// What git keeps its repository in, and the one name the tree hides.
  ///
  /// Matched whatever it turns out to be: a folder in an ordinary clone, a
  /// *file* pointing elsewhere in a worktree or a submodule. Both are git's
  /// plumbing and neither is documentation.
  static const String _gitDirectory = '.git';

  @override
  Future<Result<Space>> open(String folder) async {
    // The disk is asked first, and the order is the whole point: a folder
    // that is not there and a folder that holds no repository send the user
    // somewhere different — forget this space, against open another one —
    // and git reports both as "not a repository".
    final Result<bool> exists = await filesystem.directoryExists(folder);
    switch (exists) {
      case Failure<bool>(failure: final AppFailure failure):
        return Failure<Space>(_asSpaceFailure(failure));
      case Success<bool>(value: false):
        return Failure<Space>(SpaceFolderMissing(folder));
      case Success<bool>():
        break;
    }

    final Result<String> root = await gitClientFor(folder).repositoryRoot();
    return switch (root) {
      Success<String>(value: final String repositoryRoot) => Success<Space>(
        Space(
          root: folder,
          repositoryRoot: repositoryRoot,
          name: Space.nameOfFolder(folder),
        ),
      ),
      Failure<String>(failure: final AppFailure failure) => Failure<Space>(
        _asGitFailure(failure, folder),
      ),
    };
  }

  @override
  Future<Result<List<SpaceEntry>>> entries(Space space) async {
    final List<SpaceEntry> collected = <SpaceEntry>[];
    final Result<void> walked = await _walk(
      space,
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
    Space space,
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
      return isRoot ? Failure<void>(_asSpaceFailure(failure)) : _walked;
    }
    for (final FilesystemEntry entry
        in (listed as Success<List<FilesystemEntry>>).value) {
      final SpaceRelativePath? path = space.relativize(entry.path);
      if (path == null || path.name == _gitDirectory) {
        continue;
      }
      into.add(SpaceEntry(path: path, type: _asSpaceEntryType(entry.type)));
      if (entry.type == FilesystemEntryType.directory) {
        await _walk(space, entry.path, into, isRoot: false);
      }
    }
    return _walked;
  }

  /// A walk that produced whatever it could — the only success this has.
  static const Result<void> _walked = Success<void>(null);

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

  /// What git reported about [folder], in the product's vocabulary.
  ///
  /// Only the failures `repositoryRoot` can produce are named; anything else
  /// keeps the command and the stderr, which is what the UI's "details"
  /// disclosure shows.
  ///
  /// [GitClientNotARepository] carries the path git was asked about, and
  /// that is the one this hands on — it is the folder the user picked, and
  /// naming anything else would point them at a place they did not choose.
  static AppFailure _asGitFailure(AppFailure failure, String folder) =>
      switch (failure) {
        GitClientNotARepository() => GitNotARepository(folder),
        GitClientExecutableNotFound() => const GitNotInstalled(),
        GitClientTimedOut(command: final String command) => GitTimedOut(
          command,
        ),
        GitClientCommandFailed(
          command: final String command,
          stderr: final String stderr,
        ) =>
          GitCommandFailed(command, stderr),
        // The rest cannot come from asking where the repository is: there is
        // nothing to merge, nothing to push and no remote involved.
        _ => failure,
      };
}
