/// Splitting a document into the blocks the app draws.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Turns a document's source into its blocks.
///
/// Separate from `ReadDocumentUseCase` because the source does not have to
/// come from the disk: what the preview renders while someone is typing is
/// the editor's buffer, which no file holds yet.
final class SplitDocumentUseCase with UseCase {
  /// Creates the use case.
  const SplitDocumentUseCase({
    required this.blocks,
    required this.observability,
  });

  /// What splits a document into blocks.
  final BlockReaderPort blocks;

  @override
  final Observability observability;

  /// The blocks of [document], in order.
  Future<Result<ParsedDocumentValueObject, AppFailure>> split(
    DocumentEntity document,
  ) => guard(() => blocks.read(document));
}
