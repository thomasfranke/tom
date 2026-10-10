/// The text of `git-approvals.json`, read and written whole.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where the list of allowed commands is kept: one file, at [path], beside
/// the preferences and never in a repository.
///
/// A file of its own rather than a key of the settings store, because the
/// person reads and edits it as a list (`docs/product/git-workflow/approvals/doc.md`).
/// Read on every call, so a save by hand is in force at the next question.
final class ApprovalsDataSource {
  /// Creates a source over the file at [path].
  const ApprovalsDataSource({required this.filesystem, required this.path});

  /// What reads and writes the disk.
  final Filesystem filesystem;

  /// The absolute path of the file.
  final String path;

  /// The file's text, or null when nobody has written it yet.
  Future<Result<String?, FilesystemFailure>> read() async =>
      switch (await filesystem.readFile(path)) {
        Success<String, FilesystemFailure>(value: final String text) =>
          Success<String?, FilesystemFailure>(text),
        Failure<String, FilesystemFailure>(
          failure: FilesystemEntryNotFound(),
        ) =>
          const Success<String?, FilesystemFailure>(null),
        Failure<String, FilesystemFailure>(
          failure: final FilesystemFailure failure,
        ) =>
          Failure<String?, FilesystemFailure>(failure),
      };

  /// Replaces the file with [text], atomically.
  Future<Result<void, FilesystemFailure>> write(String text) =>
      filesystem.writeFile(path, text);
}
