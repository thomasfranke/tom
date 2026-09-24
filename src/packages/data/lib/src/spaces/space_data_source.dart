/// Reading a space's folder off the disk.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_dto.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_type_enum.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where a space's entries come from, and how.
///
/// The repository above knows that a space has entries; this knows they are
/// gathered by walking a folder one level at a time. Nothing here names a
/// domain type — what comes out is what the capability produced, in the
/// order the tree wants it.
final class SpaceDataSource {
  /// Creates a source over [filesystem], making git clients with
  /// [gitClientFor].
  const SpaceDataSource({required this.filesystem, required this.gitClientFor});

  /// What lists the disk.
  final Filesystem filesystem;

  /// How to get a git client for a folder the user just picked.
  final GitClientFor gitClientFor;

  /// Whether [folder] is there.
  ///
  /// False for a folder that is gone; a failure when the machine will not
  /// say, which is not the same answer.
  Future<Result<bool, FilesystemFailure>> exists(String folder) =>
      filesystem.directoryExists(folder);

  /// Where [folder] really is, every link on the way followed.
  ///
  /// Asked before git is, so the two answers a space is built from spell the
  /// folder the same way: `git rev-parse` resolves links on its own, and a
  /// picker does not.
  Future<Result<String, FilesystemFailure>> resolve(String folder) =>
      filesystem.resolvePath(folder);

  /// The root of the repository [folder] sits in.
  ///
  /// The relationship a space is built on — a space is a folder, and the
  /// repository it belongs to is usually a folder above it (rule 12). Asking
  /// git is the only way to learn it, so it is gathered here with the rest.
  Future<Result<String, GitClientFailure>> repositoryRootOf(String folder) =>
      gitClientFor(folder).repositoryRoot();

  /// What git keeps its repository in, and the one name never descended into.
  ///
  /// Matched whatever it turns out to be: a folder in an ordinary clone, a
  /// *file* pointing elsewhere in a worktree or a submodule. Both are git's
  /// plumbing and neither is documentation
  /// (`docs/product/navigation/file-tree/doc.md`).
  static const String _gitDirectory = '.git';

  /// Everything under [root], deepest last, in tree order.
  ///
  /// **One level at a time rather than [Filesystem.listDirectory] with
  /// `recursive: true`**, for a reason that is not style: a recursive
  /// listing walks into `.git/` before anything can filter it out, and the
  /// `.git/` of a mature repository holds more entries than every document
  /// the product will ever show. Skipping a folder is only cheap if the
  /// decision is taken *before* descending into it — which is why the rule
  /// lives here, with the walk, rather than above it.
  ///
  /// The children of a folder are appended immediately after it, so the flat
  /// list is already in tree order.
  Future<Result<List<FilesystemEntryDto>, FilesystemFailure>> entries(
    String root,
  ) async {
    final List<FilesystemEntryDto> collected = <FilesystemEntryDto>[];
    final Result<void, FilesystemFailure> walked = await _walk(
      root,
      collected,
      isRoot: true,
    );
    return walked.map((_) => List<FilesystemEntryDto>.unmodifiable(collected));
  }

  /// Lists [directory], appending what it holds to [into].
  ///
  /// A folder below the root that the machine will not open is skipped and
  /// the rest is still returned: one unreadable folder costs that folder,
  /// not the file tree. [isRoot] is what makes the space's own folder the
  /// exception — a space whose root cannot be read has nothing to show.
  Future<Result<void, FilesystemFailure>> _walk(
    String directory,
    List<FilesystemEntryDto> into, {
    required bool isRoot,
  }) async {
    final Result<List<FilesystemEntryDto>, FilesystemFailure> listed =
        await filesystem.listDirectory(directory);
    if (listed case Failure<List<FilesystemEntryDto>, FilesystemFailure>(
      failure: final FilesystemFailure failure,
    )) {
      return isRoot ? Failure<void, FilesystemFailure>(failure) : _walked;
    }
    for (final FilesystemEntryDto entry
        in (listed as Success<List<FilesystemEntryDto>, FilesystemFailure>)
            .value) {
      if (_lastSegmentOf(entry.path) == _gitDirectory) {
        continue;
      }
      into.add(entry);
      if (entry.type == FilesystemEntryTypeEnum.directory) {
        await _walk(entry.path, into, isRoot: false);
      }
    }
    return _walked;
  }

  /// A walk that produced whatever it could — the only success this has.
  static const Result<void, FilesystemFailure> _walked =
      Success<void, FilesystemFailure>(null);

  /// The last segment of [path], either platform's separator.
  static String _lastSegmentOf(String path) =>
      path.replaceAll(r'\', '/').split('/').last;
}
