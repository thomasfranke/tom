/// Getting two sequences of text lined up.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/capabilities/text_differ/text_edit_dto.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where an alignment comes from.
///
/// Thin today, and deliberately declared anyway: the aligner above must not
/// reach a capability, and the day a diff is cached per pair of versions —
/// the preview diffs on every keystroke — the cache belongs here ([Decision
/// 25](../../../../../../docs/technical/decisions/025-a-repository-reads-through-a-data-source.md)).
final class TextDifferDataSource {
  /// Creates a source over [differ].
  const TextDifferDataSource({required this.differ});

  /// What lines the two sides up.
  final TextDiffer differ;

  /// How [before] and [after] line up, entry by entry.
  Future<Result<List<TextEditDto>, TextDifferFailure>> align(
    List<String> before,
    List<String> after, {
    required double threshold,
  }) => differ.align(before, after, threshold: threshold);
}
