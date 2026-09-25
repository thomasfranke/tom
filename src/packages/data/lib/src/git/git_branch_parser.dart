/// Turning the branch format `GitClient` asks for into [BranchEntity]es.
library;

import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// The reader of what [GitClient.branches] returned, in that format.
///
/// Total: a record it cannot read is skipped, because a switcher missing one
/// entry still switches and one that throws does not open.
final class GitBranchParser {
  /// A stateless parser, so one instance serves the whole app.
  const GitBranchParser();

  /// How many fields [GitClient.branches] promises per branch.
  static const int _fieldCount = 3;

  /// What git puts in the second field for the branch `HEAD` points at.
  static const String _head = '*';

  /// [branches] as entities, in the order git listed them.
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
