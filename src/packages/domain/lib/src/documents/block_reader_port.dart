/// What splits a document into the blocks the app draws.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/documents/document_entity.dart';
import 'package:tom_domain/src/documents/document_failure.dart';
import 'package:tom_domain/src/documents/parsed_document_value_object.dart';

/// Turns a document into its blocks.
///
/// A port rather than a domain service, because splitting markdown is a
/// parser's work ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)).
/// Asynchronous though the work is pure CPU, to leave room for an isolate.
abstract interface class BlockReaderPort {
  /// The blocks of [document], in order.
  ///
  /// Total: a construct the parser cannot place is left out, a document with
  /// nothing readable is an empty list, and only something genuinely broken
  /// fails, as `DocumentOperationFailed`.
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  );
}
