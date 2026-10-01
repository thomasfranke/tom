/// A document once it has been split into blocks.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/documents/block_value_object.dart';
import 'package:tom_domain/src/documents/document_entity.dart';
import 'package:tom_domain/src/documents/footnote_value_object.dart';

part 'parsed_document_value_object.freezed.dart';

/// The blocks of a document, and the document scope they need to render.
///
/// A block is rendered on its own
/// ([runtime](../../../../../../docs/technical/runtime/preview.md)), and what
/// that costs is everything below the blocks: the link definitions and the
/// footnotes, both of which a block refers to and neither of which it holds.
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
    required String linkDefinitions,

    /// Every footnote, in citation order.
    ///
    /// Structured where [linkDefinitions] is a string, because the two are
    /// used differently: a definition is appended to a block and parsed
    /// again, while a footnote is **drawn** — its number in the prose and its
    /// text at the foot — and drawing needs the parts apart
    /// ([Decision 31](../../../../../../docs/technical/decisions/031-where-a-footnotes-text-goes.md)).
    @Default(<FootnoteValueObject>[]) List<FootnoteValueObject> footnotes,
  }) = _ParsedDocumentValueObject;
}
