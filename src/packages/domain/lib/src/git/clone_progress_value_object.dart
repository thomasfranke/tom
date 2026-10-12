/// How far a clone has got.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/git/clone_stage_enum.dart';

part 'clone_progress_value_object.freezed.dart';

/// One report from a clone in flight, so it is never a silent hang
/// (`docs/product/home/cloning/doc.md`).
@freezed
abstract class CloneProgressValueObject with _$CloneProgressValueObject {
  /// [stage], [percent] of the way through it when git says.
  @Assert('percent == null || (percent >= 0 && percent <= 100)')
  const factory CloneProgressValueObject({
    /// Which stage the clone is in.
    required CloneStageEnum stage,

    /// How far through [stage], 0 to 100, or null when git gives no
    /// fraction — the remote counting what it has, for one.
    int? percent,
  }) = _CloneProgressValueObject;
}
