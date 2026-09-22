/// [GitBranchParser] over fixtures in the format `GitClient.branches`
/// promises.
library;

import 'package:test/test.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const GitBranchParser parser = GitBranchParser();

  const String unit = GitClient.unitSeparator;
  const String record = GitClient.recordSeparator;

  /// What git actually writes: a record separator, then a newline. The
  /// second field is `*` for the checked-out branch and a space for the rest.
  String branches(List<String> records) =>
      records.map((String r) => '$r$record').join('\n');

  String branchRecord(
    String name, {
    bool current = false,
    String upstream = '',
  }) => <String>[name, current ? '*' : ' ', upstream].join(unit);

  test('marks the branch HEAD points at', () {
    final List<Branch> parsed = parser.parse(
      branches(<String>[
        branchRecord('main', current: true, upstream: 'origin/main'),
        branchRecord('draft'),
      ]),
    );

    expect(parsed.map((Branch b) => b.name.value), <String>['main', 'draft']);
    expect(parsed.first.isCurrent, isTrue);
    expect(parsed.last.isCurrent, isFalse);
  });

  test('a branch that tracks nothing has no upstream', () {
    final List<Branch> parsed = parser.parse(
      branches(<String>[branchRecord('draft')]),
    );

    expect(parsed.single.upstream, isNull);
  });

  test('an upstream is kept as the short name git printed', () {
    final List<Branch> parsed = parser.parse(
      branches(<String>[branchRecord('main', upstream: 'origin/main')]),
    );

    expect(parsed.single.upstream, BranchName('origin/main'));
  });

  test('a slash in a branch name is ordinary', () {
    final List<Branch> parsed = parser.parse(
      branches(<String>[branchRecord('feat/rendered-diff-v0')]),
    );

    expect(parsed.single.name, BranchName('feat/rendered-diff-v0'));
  });

  group('what it refuses to guess at', () {
    test('no branches is not a failure', () {
      expect(parser.parse(''), isEmpty);
    });

    test('a record with the wrong field count is skipped', () {
      final List<Branch> parsed = parser.parse(
        branches(<String>['main$unit*', branchRecord('draft')]),
      );

      expect(parsed.single.name, BranchName('draft'));
    });

    test('a name git would not accept is skipped', () {
      final List<Branch> parsed = parser.parse(
        branches(<String>[
          <String>['bad..name', ' ', ''].join(unit),
          branchRecord('draft'),
        ]),
      );

      expect(parsed.single.name, BranchName('draft'));
    });
  });
}
