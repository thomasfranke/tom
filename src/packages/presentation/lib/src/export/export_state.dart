/// Where the last export stands.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

part 'export_state.freezed.dart';

/// The one export the band can talk about (`docs/product/export/doc.md`).
@freezed
sealed class ExportState with _$ExportState {
  /// Nothing to say.
  const factory ExportState.idle() = ExportIdle;

  /// A file is being written at [destination].
  const factory ExportState.working({
    required ExportFormatEnum format,
    required String destination,
  }) = ExportWorking;

  /// The file is at [destination].
  const factory ExportState.exported({
    required ExportFormatEnum format,
    required String destination,
  }) = ExportExported;

  /// Nothing was written at [destination], and [failure] says why.
  const factory ExportState.failed({
    required ExportFormatEnum format,
    required String destination,
    required AppFailure failure,
  }) = ExportFailed;
}
