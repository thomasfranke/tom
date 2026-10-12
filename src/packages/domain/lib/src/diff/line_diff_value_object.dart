/// A file compared against another version of itself, line by line.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/diff/line_run_value_object.dart';

part 'line_diff_value_object.freezed.dart';

/// What changed between two versions of a file that is not markdown, where
/// there is no rendered page to mark and the line is the unit
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
@freezed
abstract class LineDiffValueObject with _$LineDiffValueObject {
  /// A diff.
  const factory LineDiffValueObject({
    /// Every stretch that changed, in reading order; unchanged lines are the
    /// gaps between them. Handed over unmodifiable, never copied.
    required List<LineRunValueObject> runs,
  }) = _LineDiffValueObject;

  const LineDiffValueObject._();

  /// Whether the two versions hold the same lines.
  bool get isUnchanged => runs.isEmpty;
}
