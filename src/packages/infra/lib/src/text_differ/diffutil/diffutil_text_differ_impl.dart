/// The text-diff capability, over the `diffutil_dart` package.
///
/// Two halves in one file: the contract above, and below it the two things
/// the package does not offer — how alike two entries are, and the original
/// positions, which its update stream only says by implication.
library;

import 'package:diffutil_dart/diffutil.dart' as diffutil;
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

/// [TextDiffer] over Myers as `diffutil_dart` implements it.
///
/// The package answers an *edit script* — what to insert and remove to turn
/// one list into the other — so the positions this contract promises are
/// recovered by replaying that script over the old ones ([_Replay]).
final class DiffutilTextDifferImpl implements TextDiffer {
  /// Creates the differ.
  const DiffutilTextDifferImpl();

  @override
  Future<Result<List<TextEditDto>, TextDifferFailure>> align(
    List<String> before,
    List<String> after, {
    required double threshold,
  }) async {
    try {
      final _Similarity similarity = _Similarity();
      final diffutil.DiffResult<String> result = diffutil
          .calculateListDiff<String>(
            before,
            after,
            // Off: an entry that moved is a removal and an addition, which
            // is what a reader sees at both ends anyway. Pairing the two
            // across a document is a diff v2 question.
            detectMoves: false,
            equalityChecker: (String old, String fresh) =>
                similarity.of(old, fresh) >= threshold,
          );
      return Success<List<TextEditDto>, TextDifferFailure>(
        _editsOf(before, after, _Replay(before.length).of(result)),
      );
    } on Object catch (error) {
      return Failure<List<TextEditDto>, TextDifferFailure>(
        TextDifferFailed(error.toString()),
      );
    }
  }

  /// The edits [paired] describes, in reading order.
  ///
  /// The pairs are anchors and everything between two of them is a gap —
  /// which is emitted as what went before what arrived, the order a reader
  /// expects a rewrite to be shown in.
  static List<TextEditDto> _editsOf(
    List<String> before,
    List<String> after,
    List<int?> paired,
  ) {
    final List<TextEditDto> edits = <TextEditDto>[];
    int fromBefore = 0;
    int fromAfter = 0;

    void closeGap(int upToBefore, int upToAfter) {
      for (; fromBefore < upToBefore; fromBefore++) {
        edits.add(
          TextEditDto(kind: TextEditKindEnum.removed, beforeIndex: fromBefore),
        );
      }
      for (; fromAfter < upToAfter; fromAfter++) {
        edits.add(
          TextEditDto(kind: TextEditKindEnum.added, afterIndex: fromAfter),
        );
      }
    }

    for (int afterIndex = 0; afterIndex < paired.length; afterIndex++) {
      final int? beforeIndex = paired[afterIndex];
      if (beforeIndex == null) {
        continue;
      }
      closeGap(beforeIndex, afterIndex);
      edits.add(
        TextEditDto(
          kind: before[beforeIndex] == after[afterIndex]
              ? TextEditKindEnum.equal
              : TextEditKindEnum.changed,
          beforeIndex: beforeIndex,
          afterIndex: afterIndex,
        ),
      );
      fromBefore = beforeIndex + 1;
      fromAfter = afterIndex + 1;
    }
    closeGap(before.length, after.length);
    return List<TextEditDto>.unmodifiable(edits);
  }
}

/// The edit script replayed, to recover which old entry each new one is.
///
/// The package reports positions in the list *as it is being changed*, not
/// in either original: applying the script to the old positions leaves a
/// list as long as the new side, holding the old position of every entry
/// that survived and null where one arrived.
final class _Replay {
  const _Replay(this.beforeLength);

  /// How many entries the old side had.
  final int beforeLength;

  /// [result] applied to the old positions.
  List<int?> of(diffutil.DiffResult<String> result) {
    final List<int?> positions = <int?>[
      for (int index = 0; index < beforeLength; index++) index,
    ];
    for (final diffutil.DiffUpdate update in result.getUpdates(batch: false)) {
      update.when(
        insert: (int position, int count) =>
            positions.insertAll(position, List<int?>.filled(count, null)),
        remove: (int position, int count) =>
            positions.removeRange(position, position + count),
        // A pair the package found and kept in place: it stays where it is,
        // and which of the two texts it holds is decided by comparing them.
        change: (int position, Object? payload) {},
        move: (int from, int to) =>
            throw StateError('move detection is off, and a move was reported'),
      );
    }
    return positions;
  }
}

/// How alike two entries are, from 0 to 1.
///
/// Word overlap (Sørensen–Dice) rather than a second Myers run: Myers asks
/// this once per candidate pair, which on a document-sized list is tens of
/// thousands of times, so each entry is counted once and a comparison is
/// then a walk over the shorter of two maps.
final class _Similarity {
  /// The word counts of every entry this has been asked about.
  final Map<String, Map<String, int>> _counts = <String, Map<String, int>>{};

  /// How alike [old] and [fresh] are.
  double of(String old, String fresh) {
    if (old == fresh) {
      return 1;
    }
    final Map<String, int> left = _countsOf(old);
    final Map<String, int> right = _countsOf(fresh);
    final int total = _sizeOf(left) + _sizeOf(right);
    // Two different entries with no words between them share nothing, and
    // the division below would have no answer to give.
    if (total == 0) {
      return 0;
    }
    final Map<String, int> shorter = left.length <= right.length ? left : right;
    final Map<String, int> longer = identical(shorter, left) ? right : left;
    int shared = 0;
    for (final MapEntry<String, int> word in shorter.entries) {
      final int? other = longer[word.key];
      if (other != null) {
        shared += word.value < other ? word.value : other;
      }
    }
    return 2 * shared / total;
  }

  /// The words of [text], counted.
  Map<String, int> _countsOf(String text) =>
      _counts.putIfAbsent(text, () => _countWords(text));

  /// How many words [counts] was taken from.
  static int _sizeOf(Map<String, int> counts) =>
      counts.values.fold(0, (int total, int count) => total + count);

  /// [text] split into words, each with how often it occurs.
  ///
  /// Case and the punctuation around a word are dropped, because neither
  /// decides whether two texts are *about* the same thing: `Prose.` becoming
  /// `Prose, rewritten.` is one sentence being rewritten, and counting the
  /// full stop as part of the word makes it two unrelated ones.
  static Map<String, int> _countWords(String text) {
    final Map<String, int> counts = <String, int>{};
    for (final String token in text.toLowerCase().split(RegExp(r'\s+'))) {
      final String word = token.replaceAll(_edgePunctuation, '');
      if (word.isEmpty) {
        continue;
      }
      counts[word] = (counts[word] ?? 0) + 1;
    }
    return counts;
  }

  /// Everything that is not a letter or a digit, at either end of a token.
  ///
  /// Unicode-aware, so an accented word is one word: markdown is prose, and
  /// prose is not written in ASCII everywhere.
  static final RegExp _edgePunctuation = RegExp(
    r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$',
    unicode: true,
  );
}
