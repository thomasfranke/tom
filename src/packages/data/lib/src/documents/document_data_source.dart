/// Reading and writing one document's bytes.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where a document's text comes from, and where it goes.
///
/// Absolute paths, because that is what the disk answers in. Turning a
/// space-relative path into one is the repository's job — it is the half
/// that knows what a space is ([Decision
/// 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md)).
///
/// The disk is read on every call. There is no cache here to go stale,
/// which is the whole reason editing a space alongside VS Code is a
/// supported way to work rather than a race
/// ([flows](../../../../../../docs/technical/flows.md)).
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
