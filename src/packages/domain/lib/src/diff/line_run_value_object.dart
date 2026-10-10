/// A stretch of lines, and what happened to it between two versions.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'line_run_value_object.freezed.dart';

/// Consecutive lines that changed the same way, counted in the new version
/// from zero.
///
/// A run rather than a line, because the gutter letters a stretch once and
/// tints all of it, as it does a block.
@freezed
sealed class LineRunValueObject with _$LineRunValueObject {
  /// Lines in the new version only, [from] to [to] inclusive.
  const factory LineRunValueObject.added({required int from, required int to}) =
      LineRunAdded;

  /// Lines in both versions, written differently.
  const factory LineRunValueObject.modified({
    required int from,
    required int to,
  }) = LineRunModified;

  /// [count] lines in the old version only, which used to sit above line
  /// [at] of the new one — a seam, since they have no line of their own.
  const factory LineRunValueObject.removed({
    required int at,
    required int count,
  }) = LineRunRemoved;
}
