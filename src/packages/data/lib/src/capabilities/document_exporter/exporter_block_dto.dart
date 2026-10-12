/// One block of a document, as an exporter is handed it.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_data/src/capabilities/document_exporter/exporter_block_kind_enum.dart';

part 'exporter_block_dto.freezed.dart';

/// What a block says and what kind it is — no position, since an export has
/// no second version to align it against.
@freezed
abstract class ExporterBlockDto with _$ExporterBlockDto {
  /// Creates a block.
  const factory ExporterBlockDto({
    /// The document's own lines for the block, newline-joined.
    required String source,

    /// What kind of block it is.
    required ExporterBlockKindEnum kind,
  }) = _ExporterBlockDto;
}
