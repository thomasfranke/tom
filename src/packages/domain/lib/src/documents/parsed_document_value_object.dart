/// A document once it has been split into blocks.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/documents/block_value_object.dart';
import 'package:tom_domain/src/documents/document_entity.dart';

part 'parsed_document_value_object.freezed.dart';

/// The blocks of a document, and the document scope they need to render.
///
/// A block is rendered on its own
/// ([runtime](../../../../../../docs/technical/runtime/documents.md)),
/// and the one thing that costs is the document-scoped link definitions.
@freezed
abstract class ParsedDocumentValueObject with _$ParsedDocumentValueObject {
  /// A parsed document.
  const factory ParsedDocumentValueObject({
    /// The document these blocks came from, source and all.
    required DocumentEntity document,

    /// The top-level blocks, in document order.
    ///
    /// Handed over unmodifiable, never copied: Freezed compares collections
    /// element-wise and copies nothing.
    required List<BlockValueObject> blocks,

    /// Every link reference definition in the document, as its own lines, so
    /// `[text][ref]` resolves in a block that does not hold the definition.
    /// Footnotes do not survive the same way (Decision 19).
    required String linkDefinitions,
  }) = _ParsedDocumentValueObject;
}
