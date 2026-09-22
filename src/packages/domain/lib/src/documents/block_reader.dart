/// What splits a document into the blocks the app draws.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/documents/document.dart';
import 'package:tom_domain/src/documents/document_failure.dart';
import 'package:tom_domain/src/documents/parsed_document.dart';

/// Turns a document into its blocks.
///
/// A port rather than a domain service: splitting markdown is the domain's
/// vocabulary but a parser's work, and a parser is infrastructure ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)).
/// `BlockDiffer` is the domain service; this is the seam under it.
///
/// Asynchronous like every other contract here, though the work is pure
/// CPU — it leaves room for an isolate the day a document is large enough to
/// drop a frame, and costs a keyword until then.
abstract interface class BlockReader {
  /// The blocks of [document], in order.
  ///
  /// Total by contract: a construct the parser cannot place is left out
  /// rather than guessed at, and a document that holds nothing readable is
  /// an empty list. Only something genuinely broken fails, as
  /// `DocumentOperationFailed`.
  Future<Result<ParsedDocument, DocumentFailure>> read(Document document);
}
