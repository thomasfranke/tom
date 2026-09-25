/// [GitBranchParser] over fixtures in the format `GitClient.branches`
/// promises.
library;

import 'package:test/test.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const GitBranchParser parser = GitBranchParser();

  const String unit = GitClient.unitSeparator;
  const String record = GitClient.recordSeparator;

  /// A record as git writes it: the separator, then a newline; `*` or a space
  /// in the second field.
  String branches(List<String> records) =>
      records.map((String r) => '$r$record').join('\n');

  String branchRecord(
    String name, {
    bool current = false,
    String upstream = '',
  }) => <String>[name, current ? '*' : ' ', upstream].join(unit);

  test('marks the branch HEAD points at', () {
    final List<BranchEntity> parsed = parser.parse(
      branches(<String>[
        branchRecord('main', current: true, upstream: 'origin/main'),
        branchRecord('draft'),
      ]),
    );

    expect(parsed.map((BranchEntity b) => b.name.value), <String>[
      'main',
      'draft',
    ]);
    expect(parsed.first.isCurrent, isTrue);
    expect(parsed.last.isCurrent, isFalse);
  });

  test('a branch that tracks nothing has no upstream', () {
    final List<BranchEntity> parsed = parser.parse(
      branches(<String>[branchRecord('draft')]),
    );

    expect(parsed.single.upstream, isNull);
  });

  test('an upstream is kept as the short name git printed', () {
    final List<BranchEntity> parsed = parser.parse(
      branches(<String>[branchRecord('main', upstream: 'origin/main')]),
    );

    expect(parsed.single.upstream, BranchNameValueObject('origin/main'));
  });

  test('a slash in a branch name is ordinary', () {
    final List<BranchEntity> parsed = parser.parse(
      branches(<String>[branchRecord('feat/rendered-diff-v0')]),
    );

    expect(parsed.single.name, BranchNameValueObject('feat/rendered-diff-v0'));
  });

  group('what it refuses to guess at', () {
    test('no branches is not a failure', () {
      expect(parser.parse(''), isEmpty);
    });

    test('a record with the wrong field count is skipped', () {
      final List<BranchEntity> parsed = parser.parse(
        branches(<String>['main$unit*', branchRecord('draft')]),
      );

      expect(parsed.single.name, BranchNameValueObject('draft'));
    });

    test('a name git would not accept is skipped', () {
      final List<BranchEntity> parsed = parser.parse(
        branches(<String>[
          <String>['bad..name', ' ', ''].join(unit),
          branchRecord('draft'),
        ]),
      );

      expect(parsed.single.name, BranchNameValueObject('draft'));
    });
  });
}
