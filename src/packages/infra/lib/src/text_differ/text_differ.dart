/// Telling two sequences of text apart.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/src/text_differ/text_differ_failure.dart';

/// Lines two sequences of text up, entry by entry.
///
/// **Positions out, never text.** Nothing here knows what an entry is, which
/// keeps the rendered diff's rules out of the algorithm ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)).
abstract interface class TextDiffer {
  /// How [before] and [after] line up, in reading order.
  ///
  /// The format, exactly: every position of both sides appears in exactly
  /// one edit; `equal` and `changed` carry both positions, `added` only its
  /// `afterIndex`, `removed` only its `beforeIndex`; a removal is placed
  /// where the entry it names used to be. Two entries pair when they are at
  /// least [threshold] alike, 0 to 1 — what "alike" is measured in is the
  /// implementation's, what it has to be worth is the caller's.
  Future<Result<List<TextEditDto>, TextDifferFailure>> align(
    List<String> before,
    List<String> after, {
    required double threshold,
  });
}
