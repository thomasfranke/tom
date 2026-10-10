/// Running `git clone`, and handing back what it reported.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_dto.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_type_enum.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where a clone comes from: a client made for the folder it will fill, and
/// the disk that folder is on.
///
/// Apart from `GitDataSource`, which holds the client of a space that
/// already exists; one instance for the app.
final class GitCloneDataSource {
  /// Creates a source making clients with [gitClientFor] over [filesystem].
  const GitCloneDataSource({
    required this.gitClientFor,
    required this.filesystem,
  });

  /// How to get a git client for a folder, here one that is not there yet.
  final GitClientFor gitClientFor;

  /// What looks at the destination, and removes what a failed clone left.
  final Filesystem filesystem;

  /// Clones [url] into [destination], handing git's lines to [onLine].
  Future<Result<void, GitClientFailure>> clone(
    String url,
    String destination, {
    void Function(String line)? onLine,
  }) => gitClientFor(destination).clone(url, onProgress: onLine);

  /// What is at [path], or null for nothing.
  Future<Result<FilesystemEntryTypeEnum?, FilesystemFailure>> entryTypeOf(
    String path,
  ) => filesystem.entryTypeOf(path);

  /// The entries directly inside [folder].
  Future<Result<List<FilesystemEntryDto>, FilesystemFailure>> entriesOf(
    String folder,
  ) => filesystem.listDirectory(folder);

  /// Removes [path] and everything below it.
  Future<Result<void, FilesystemFailure>> remove(String path) =>
      filesystem.delete(path);
}
