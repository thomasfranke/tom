/// Turning the two diffs `GitClient` prints into [BranchChangeValueObject]s.
library;

import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// The reader of [GitClient.diffNameStatus] and [GitClient.diffNumstat],
/// joined by path.
///
/// Total, like the other parsers: an entry whose path is not a path is
/// skipped. The name-status decides which paths there are; a path the
/// numstat missed keeps null counts rather than disappearing.
final class GitDiffParser {
  /// A stateless parser, so one instance serves the whole app.
  const GitDiffParser();

  /// [nameStatus] and [numstat] as one change per path, in git's order.
  List<BranchChangeValueObject> parse({
    required String nameStatus,
    required String numstat,
  }) {
    final Map<String, (int?, int?)> counts = _counts(numstat);
    final List<String> fields = nameStatus
        .split(GitClient.nulSeparator)
        .where((String field) => field.isNotEmpty)
        .toList();
    return <BranchChangeValueObject>[
      for (int at = 0; at + 1 < fields.length; at += 2)
        if (RepoRelativePathValueObject.tryParse(fields[at + 1])
            case final RepoRelativePathValueObject path)
          BranchChangeValueObject(
            path: path,
            state: _state(fields[at]),
            added: counts[path.value]?.$1,
            removed: counts[path.value]?.$2,
          ),
    ];
  }

  /// `added\tremoved\tpath` entries by path; `-` is a binary file's count.
  static Map<String, (int?, int?)> _counts(String numstat) =>
      <String, (int?, int?)>{
        for (final String entry in numstat.split(GitClient.nulSeparator))
          if (entry.split('\t') case [
            final String added,
            final String removed,
            final String path,
          ])
            path.trim(): (int.tryParse(added), int.tryParse(removed)),
      };

  /// Git's letter in the product's words. Renames are off, so `R` and `C`
  /// never come; a type change is a modification to anyone reading prose.
  static FileStateEnum _state(String letter) => switch (letter) {
    'A' => FileStateEnum.added,
    'D' => FileStateEnum.deleted,
    _ => FileStateEnum.modified,
  };
}
