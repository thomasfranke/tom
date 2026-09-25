/// One step of an alignment between two sequences.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/diff/sequence_edit_kind_enum.dart';

part 'sequence_edit_value_object.freezed.dart';

/// A verdict and the positions it is about.
///
/// Positions rather than entries, so the caller keeps the only copy of
/// whatever the strings came from.
@freezed
abstract class SequenceEditValueObject with _$SequenceEditValueObject {
  /// An edit.
  const factory SequenceEditValueObject({
    /// What happened to the entry.
    required SequenceEditKindEnum kind,

    /// Where it sat in the old sequence, or null when it is an addition.
    int? beforeIndex,

    /// Where it sits in the new sequence, or null when it was removed.
    int? afterIndex,
  }) = _SequenceEditValueObject;
}
