/// Reading and writing one document's bytes.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where a document's text comes from, and where it goes.
///
/// Absolute paths, because the disk answers in them; the space-relative half
/// is the repository's ([Decision
/// 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md)).
/// The disk is read on every call, so there is no cache to go stale.
final class DocumentDataSource {
  /// Creates a source over [filesystem].
  const DocumentDataSource({required this.filesystem});

  /// What reads and writes the disk.
  final Filesystem filesystem;

  /// The text at [absolutePath].
  Future<Result<String, FilesystemFailure>> read(String absolutePath) =>
      filesystem.readFile(absolutePath);

  /// Puts [content] at [absolutePath], creating what the path needs.
  Future<Result<void, FilesystemFailure>> write(
    String absolutePath,
    String content,
  ) => filesystem.writeFile(absolutePath, content);
}
