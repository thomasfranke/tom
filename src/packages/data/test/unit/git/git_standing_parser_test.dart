/// [GitStandingParser] over fixtures in the format
/// `GitClient.branchStandings` promises.
library;

import 'package:test/test.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  const GitStandingParser parser = GitStandingParser();

  /// Records as `for-each-ref` writes them: the separator, then a newline.
  String standings(List<List<String>> records) => records
      .map(
        (List<String> r) =>
            '${r.join(GitClient.unitSeparator)}${GitClient.recordSeparator}',
      )
      .join('\n');

  List<BranchStandingValueObject> parse(
    List<List<String>> records, {
    int headCommits = 10,
  }) => parser.parse(standings(records), headCommits: headCommits);

  test('a local branch, with both counts', () {
    expect(
      parse(<List<String>>[
        <String>['refs/heads/feat/notes', '', '2 5'],
      ]),
      <BranchStandingValueObject>[
        BranchStandingValueObject(
          branch: BranchRefValueObject(
            name: BranchNameValueObject('feat/notes'),
          ),
          ahead: 2,
          behind: 5,
          sharesHistory: true,
        ),
      ],
    );
  });

  test('a remote-tracking branch keeps its remote apart from its name', () {
    expect(
      parse(<List<String>>[
        <String>['refs/remotes/upstream/release/2.0', '', '0 1'],
      ]).single.branch,
      BranchRefValueObject(
        name: BranchNameValueObject('release/2.0'),
        remote: 'upstream',
      ),
    );
  });

  test('a symbolic ref is a pointer, not a branch', () {
    expect(
      parse(<List<String>>[
        <String>['refs/remotes/origin/HEAD', 'refs/remotes/origin/main', '0 0'],
      ]),
      isEmpty,
    );
  });

  test('behind by every commit HEAD has is no shared history', () {
    expect(
      parse(<List<String>>[
        <String>['refs/heads/gh-pages', '', '3 4'],
      ], headCommits: 4).single.sharesHistory,
      isFalse,
    );
  });

  test('a record it cannot read is skipped', () {
    expect(
      parse(<List<String>>[
        <String>['refs/heads/main', '', 'not counts'],
        <String>['refs/tags/v1', '', '0 0'],
        <String>['refs/heads/ok', '', '0 1'],
        <String>['too few'],
      ]).map((BranchStandingValueObject it) => it.branch.spec),
      <String>['ok'],
    );
  });

  test('nothing is nothing', () {
    expect(parser.parse('', headCommits: 0), isEmpty);
  });
}
