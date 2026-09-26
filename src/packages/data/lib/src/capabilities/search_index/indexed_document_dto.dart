/// One document, as the index is given it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'indexed_document_dto.freezed.dart';

/// A key and the text filed under it.
///
/// A DTO because it crosses the contract ([Decision
/// 21](../../../../../../../docs/technical/decisions/021-dtos-and-daos-when-they-are-real.md));
/// the key is opaque to the index, which never learns it is a path.
@freezed
abstract class IndexedDocumentDto with _$IndexedDocumentDto {
  /// Creates a document to index.
  const factory IndexedDocumentDto({
    /// What the caller calls it; unique, and echoed back by every hit.
    required String key,

    /// Everything about it that can be searched for.
    required String text,
  }) = _IndexedDocumentDto;
}
