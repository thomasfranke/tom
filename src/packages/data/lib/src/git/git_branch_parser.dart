/// Turning the branch format `GitClient` asks for into [BranchEntity]es.
library;

import 'package:tom_data/src/capabilities/git_client/git_client.dart';
import 'package:tom_domain/tom_domain.dart';

/// Reads what `GitClient.branches` returned.
///
/// **Total, and deliberately so.** A record it cannot read is skipped: a
/// branch switcher missing one entry still switches, and one that throws
/// does not open.
final class GitBranchParser {
  /// Creates a parser.
  ///
  /// Stateless, so one instance serves the whole app
  /// (`docs/technical/flows.md#wiring-three-lifetimes`).
  const GitBranchParser();

  /// How many fields `GitClient.branches` promises per branch.
  static const int _fieldCount = 3;

  /// What git puts in the second field for the branch `HEAD` points at.
  static const String _head = '*';

  /// Reads [branches] into branches, in the order git listed them.
  List<BranchEntity> parse(String branches) => <BranchEntity>[
    for (final String record in branches.split(GitClient.recordSeparator))
      if (_parseRecord(record) case final BranchEntity branch) branch,
  ];

  /// One record: short name, `*` or a space, short upstream or empty.
  BranchEntity? _parseRecord(String record) {
    final List<String> fields = record.trim().split(GitClient.unitSeparator);
    if (fields.length != _fieldCount) {
      return null;
    }
    final BranchNameValueObject? name = BranchNameValueObject.tryParse(
      fields[0],
    );
    if (name == null) {
      return null;
    }
    return BranchEntity(
      name: name,
      isCurrent: fields[1] == _head,
      upstream: BranchNameValueObject.tryParse(fields[2]),
    );
  }
}
