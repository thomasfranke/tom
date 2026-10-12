/// Turning the standings `GitClient` reports into [BranchStandingValueObject]s.
library;

import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// The reader of what [GitClient.branchStandings] returned, in that format.
///
/// Total, like the branch parser: a record it cannot read is skipped, since a
/// base deduced from one branch fewer is still a base.
final class GitStandingParser {
  /// A stateless parser, so one instance serves the whole app.
  const GitStandingParser();

  /// How many fields [GitClient.branchStandings] promises per ref.
  static const int _fieldCount = 3;

  static const String _local = 'refs/heads/';

  static const String _remote = 'refs/remotes/';

  /// [standings] as value objects, a symbolic ref left out; [headCommits]
  /// is how many commits `HEAD` has, which a ref with no shared history is
  /// behind by all of.
  List<BranchStandingValueObject> parse(
    String standings, {
    required int headCommits,
  }) => <BranchStandingValueObject>[
    for (final String record in standings.split(GitClient.recordSeparator))
      if (_parseRecord(record, headCommits)
          case final BranchStandingValueObject standing)
        standing,
  ];

  /// One record: full ref, symbolic target or empty, `ahead behind`.
  BranchStandingValueObject? _parseRecord(String record, int headCommits) {
    final List<String> fields = record.trim().split(GitClient.unitSeparator);
    if (fields.length != _fieldCount || fields[1].isNotEmpty) {
      return null;
    }
    final BranchRefValueObject? branch = _refOf(fields[0]);
    final List<int?> counts = fields[2]
        .trim()
        .split(' ')
        .map(int.tryParse)
        .toList();
    if (branch == null ||
        counts.length != 2 ||
        counts[0] == null ||
        counts[1] == null) {
      return null;
    }
    return BranchStandingValueObject(
      branch: branch,
      ahead: counts[0]!,
      behind: counts[1]!,
      sharesHistory: counts[1]! < headCommits,
    );
  }

  /// `refs/heads/develop` as a local branch, `refs/remotes/origin/develop`
  /// as `origin`'s — the remote's name is the first segment, which is the
  /// one place a remote-tracking ref keeps it.
  static BranchRefValueObject? _refOf(String ref) {
    if (ref.startsWith(_local)) {
      final BranchNameValueObject? name = BranchNameValueObject.tryParse(
        ref.substring(_local.length),
      );
      return name == null ? null : BranchRefValueObject(name: name);
    }
    if (ref.startsWith(_remote)) {
      final String rest = ref.substring(_remote.length);
      final int slash = rest.indexOf('/');
      if (slash <= 0) {
        return null;
      }
      final BranchNameValueObject? name = BranchNameValueObject.tryParse(
        rest.substring(slash + 1),
      );
      return name == null
          ? null
          : BranchRefValueObject(name: name, remote: rest.substring(0, slash));
    }
    return null;
  }
}
