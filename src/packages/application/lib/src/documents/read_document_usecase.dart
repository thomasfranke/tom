/// Reading a document, and splitting it into what the app draws.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Reads one document and returns its blocks.
///
/// Two steps rather than one because they fail differently: a file that is
/// gone is `DocumentNotFound` and sends the user to another document, while
/// a parse that broke is a bug that still has to say something on screen.
///
/// The disk is read every time. There is no cache to go stale, which is what
/// makes editing a space beside TOM a supported way to work.
final class ReadDocumentUseCase with UseCase {
  /// Creates the use case.
  const ReadDocumentUseCase({
    required this.documentsFor,
    required this.blocks,
    required this.observability,
  });

  /// How to reach the documents of a space.
  final DocumentRepositoryFor documentsFor;

  /// What splits a document into blocks.
  final BlockReader blocks;

  @override
  final Observability observability;

  /// The document at [path] inside [space], parsed.
  Future<Result<ParsedDocument, AppFailure>> read(
    Space space,
    SpaceRelativePath path,
  ) => guard(
    // Read then split, and both fail in the document's vocabulary, so the
    // two steps chain rather than being switched over.
    () => documentsFor(space).read(path).flatMap(blocks.read),
  );
}
