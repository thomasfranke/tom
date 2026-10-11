/// Comparing two versions of a file, line by line.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/diff/line_aligner_port.dart';
import 'package:tom_domain/src/diff/line_diff_value_object.dart';
import 'package:tom_domain/src/diff/line_run_value_object.dart';
import 'package:tom_domain/src/diff/sequence_edit_kind_enum.dart';
import 'package:tom_domain/src/diff/sequence_edit_value_object.dart';
import 'package:tom_domain/src/documents/document_entity.dart';
import 'package:tom_domain/src/documents/document_failure.dart';

/// Two versions in, runs of changed lines out — the diff of a file that is
/// not markdown (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
///
/// The product's rule over [LineAlignerPort]: what a line is, how alike two
/// must be to be one line rewritten, and how verdicts gather into runs.
final class LineDifferService {
  /// A differ over [aligner].
  const LineDifferService({required this.aligner});

  /// How the two line lists are lined up.
  final LineAlignerPort aligner;

  /// How alike two lines have to be to be the same line rewritten; the
  /// blocks' number, so a sentence edited reads the same in either diff.
  static const double pairingThreshold = 0.5;

  /// What changed from [before] to [after].
  ///
  /// Total: a file the old version did not hold is every line added.
  Future<Result<LineDiffValueObject, DocumentFailure>> diff({
    required DocumentEntity before,
    required DocumentEntity after,
  }) => aligner
      .align(
        linesOf(before.content),
        linesOf(after.content),
        path: after.path,
        threshold: pairingThreshold,
      )
      .map(_runsOf);

  /// [text] cut at its line breaks, as the source pane numbers them; a final
  /// break ends the last line rather than starting an empty one.
  static List<String> linesOf(String text) {
    if (text.isEmpty) {
      return const <String>[];
    }
    // A carriage return is part of the break, not of the line: a file saved
    // on Windows has the lines its LF twin has.
    final List<String> lines = text.replaceAll('\r\n', '\n').split('\n');
    if (text.endsWith('\n')) {
      lines.removeLast();
    }
    return lines;
  }

  /// [edits] gathered into runs, each placed in the new version's lines.
  static LineDiffValueObject _runsOf(List<SequenceEditValueObject> edits) {
    final List<LineRunValueObject> runs = <LineRunValueObject>[];
    SequenceEditKindEnum? kind;
    int from = 0;
    int to = 0;
    // The next line of the new version: where a removal is a seam above.
    int next = 0;

    void close() {
      switch (kind) {
        case SequenceEditKindEnum.added:
          runs.add(LineRunValueObject.added(from: from, to: to));
        case SequenceEditKindEnum.changed:
          runs.add(LineRunValueObject.modified(from: from, to: to));
        case SequenceEditKindEnum.removed:
          runs.add(LineRunValueObject.removed(at: from, count: to - from + 1));
        case SequenceEditKindEnum.equal || null:
          break;
      }
      kind = null;
    }

    for (final SequenceEditValueObject edit in edits) {
      // A removal is counted on its own line of the old version, so a run
      // of them grows by one each; the others by the new version's line.
      final int at = edit.kind == SequenceEditKindEnum.removed
          ? (kind == SequenceEditKindEnum.removed ? to + 1 : next)
          : edit.afterIndex!;
      if (edit.kind != kind ||
          (edit.kind != SequenceEditKindEnum.removed && at != to + 1)) {
        close();
        kind = edit.kind;
        from = at;
      }
      to = at;
      if (edit.afterIndex case final int after) {
        next = after + 1;
      }
    }
    close();
    return LineDiffValueObject(
      runs: List<LineRunValueObject>.unmodifiable(runs),
    );
  }
}
