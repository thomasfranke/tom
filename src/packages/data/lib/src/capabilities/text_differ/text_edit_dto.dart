/// One step of an alignment, as the differ found it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_data/src/capabilities/text_differ/text_edit_kind_enum.dart';

part 'text_edit_dto.freezed.dart';

/// A verdict and the positions it is about.
///
/// A DTO because it exists to cross the contract and is not a domain type
/// ([Decision
/// 21](../../../../../../docs/technical/decisions/021-dtos-and-daos-when-they-are-real.md)):
/// positions travel, never the text, so the caller keeps the only copy of
/// whatever it handed in.
@freezed
abstract class TextEditDto with _$TextEditDto {
  /// Creates an edit.
  const factory TextEditDto({
    /// What happened to the entry.
    required TextEditKindEnum kind,

    /// Where it sat in the old sequence, or null when it is an addition.
    int? beforeIndex,

    /// Where it sits in the new sequence, or null when it was removed.
    int? afterIndex,
  }) = _TextEditDto;
}
