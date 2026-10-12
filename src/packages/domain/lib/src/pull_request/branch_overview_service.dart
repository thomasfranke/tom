/// Counting what a branch did.
library;

import 'package:tom_domain/src/diff/diff_block_value_object.dart';
import 'package:tom_domain/src/diff/document_diff_value_object.dart';
import 'package:tom_domain/src/documents/block_kind_enum.dart';
import 'package:tom_domain/src/documents/block_value_object.dart';
import 'package:tom_domain/src/git/branch_change_value_object.dart';
import 'package:tom_domain/src/git/commit_entity.dart';
import 'package:tom_domain/src/git/file_state_enum.dart';
import 'package:tom_domain/src/pull_request/branch_overview_value_object.dart';

/// Git's readings and the block differ's, folded into one overview.
///
/// No port: the diffs arrive already made, by the same differ the rendered
/// diff runs, so the words and blocks here are the ones the preview marks.
final class BranchOverviewService {
  /// Creates the service.
  const BranchOverviewService();

  /// Words a reviewer reads in a minute — a careful silent reading, slower
  /// than skimming because a review reads to judge.
  static const int wordsPerMinute = 200;

  /// The overview of a branch with [commits] (newest first), [changes], and
  /// the block diff of each changed document that could be read.
  BranchOverviewValueObject summarise({
    required List<CommitEntity> commits,
    required List<BranchChangeValueObject> changes,
    required List<DocumentDiffValueObject> diffs,
  }) {
    int wordsAdded = 0;
    int wordsRemoved = 0;
    final Map<BlockKindEnum, int> blocks = <BlockKindEnum, int>{};
    for (final DocumentDiffValueObject diff in diffs) {
      for (final DiffBlockValueObject block in diff.blocks) {
        final (int gained, int lost) = switch (block) {
          DiffBlockUnchanged() => (0, 0),
          DiffBlockAdded(block: final BlockValueObject added) => (
            words(added.source).length,
            0,
          ),
          DiffBlockRemoved(block: final BlockValueObject removed) => (
            0,
            words(removed.source).length,
          ),
          DiffBlockModified(
            before: final BlockValueObject before,
            after: final BlockValueObject after,
          ) =>
            _exchanged(words(before.source), words(after.source)),
        };
        wordsAdded += gained;
        wordsRemoved += lost;
        if (block.isChange) {
          blocks.update(block.drawn.kind, (int n) => n + 1, ifAbsent: () => 1);
        }
      }
    }
    final Map<String, int> folders = <String, int>{};
    for (final BranchChangeValueObject change in changes) {
      final String path = change.path.value;
      final int slash = path.lastIndexOf('/');
      folders.update(
        slash < 0 ? '' : path.substring(0, slash),
        (int n) => n + 1,
        ifAbsent: () => 1,
      );
    }
    final List<BranchChangeValueObject> counted = changes
        .where((BranchChangeValueObject it) => it.added != null)
        .toList();
    final int changed = wordsAdded + wordsRemoved;
    return BranchOverviewValueObject(
      commits: commits.length,
      firstCommit: commits.isEmpty ? null : commits.last.date,
      added: _count(changes, FileStateEnum.added),
      modified: _count(changes, FileStateEnum.modified),
      deleted: _count(changes, FileStateEnum.deleted),
      wordsAdded: wordsAdded,
      wordsRemoved: wordsRemoved,
      blocks: _mostFirst(blocks),
      folders: _mostFirst(folders),
      mostChanged: counted.isEmpty
          ? null
          : counted.reduce(
              (BranchChangeValueObject a, BranchChangeValueObject b) =>
                  _lines(b) > _lines(a) ? b : a,
            ),
      readingMinutes: (changed / wordsPerMinute).ceil(),
    );
  }

  /// The words of [text]: runs of letters and digits, an apostrophe or a
  /// hyphen inside one, so markdown's marks are never counted.
  static List<String> words(String text) => <String>[
    for (final RegExpMatch match in _word.allMatches(text))
      match.group(0)!.toLowerCase(),
  ];

  /// What [after] has that [before] does not, and the other way round,
  /// counted as multisets — a rewritten sentence costs the words it
  /// changed, not the whole sentence twice.
  static (int, int) _exchanged(List<String> before, List<String> after) {
    final Map<String, int> pool = <String, int>{};
    for (final String word in before) {
      pool.update(word, (int n) => n + 1, ifAbsent: () => 1);
    }
    int gained = 0;
    for (final String word in after) {
      final int left = pool[word] ?? 0;
      if (left > 0) {
        pool[word] = left - 1;
      } else {
        gained++;
      }
    }
    final int lost = pool.values.fold(0, (int sum, int n) => sum + n);
    return (gained, lost);
  }

  static int _count(List<BranchChangeValueObject> changes, FileStateEnum s) =>
      changes.where((BranchChangeValueObject it) => it.state == s).length;

  static int _lines(BranchChangeValueObject change) =>
      (change.added ?? 0) + (change.removed ?? 0);

  static Map<K, int> _mostFirst<K>(Map<K, int> counts) =>
      Map<K, int>.unmodifiable(<K, int>{
        for (final MapEntry<K, int> entry in _sorted(counts))
          entry.key: entry.value,
      });

  static List<MapEntry<K, int>> _sorted<K>(Map<K, int> counts) =>
      List<MapEntry<K, int>>.of(
        counts.entries.toList()..sort(
          (MapEntry<K, int> a, MapEntry<K, int> b) =>
              b.value.compareTo(a.value),
        ),
      );

  static final RegExp _word = RegExp(
    r"[\p{L}\p{N}]+(?:['’-][\p{L}\p{N}]+)*",
    unicode: true,
  );
}
