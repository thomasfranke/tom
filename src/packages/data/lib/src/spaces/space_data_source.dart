/// Reading a space's folder off the disk.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_dto.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_type_enum.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where a space's entries come from: a folder walked one level at a time,
/// answered in the capability's types and in tree order.
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
  /// Asked before git is, because `git rev-parse` resolves links on its own
  /// and a picker does not.
  Future<Result<String, FilesystemFailure>> resolve(String folder) =>
      filesystem.resolvePath(folder);

  /// The root of the repository [folder] sits in, usually a folder above it
  /// (rule 12).
  Future<Result<String, GitClientFailure>> repositoryRootOf(String folder) =>
      gitClientFor(folder).repositoryRoot();

  /// The one name never descended into, whether a folder or the file a
  /// worktree or submodule has (`docs/product/navigation/file-tree/doc.md`).
  static const String _gitDirectory = '.git';

  /// Everything under [root], in tree order: a folder's children follow it.
  ///
  /// **One level at a time, never [Filesystem.listDirectory] recursively**: a
  /// recursive listing walks into `.git/` before anything can filter it, and
  /// a mature repository keeps more there than the product will ever show.
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

  /// [directory]'s contents appended to [into], recursively.
  ///
  /// A folder the machine will not open costs that folder and not the tree,
  /// unless it [isRoot], since a space whose root cannot be read has nothing
  /// to show.
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

  /// The only success a walk has.
  static const Result<void, FilesystemFailure> _walked =
      Success<void, FilesystemFailure>(null);

  /// The last segment of [path], either platform's separator.
  static String _lastSegmentOf(String path) =>
      path.replaceAll(r'\', '/').split('/').last;
}
