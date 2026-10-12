/// What the search box means by what is typed: words, never a query language.
library;

import '../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Reads what is typed as words',
    group: 'Search',
    describe:
        'The box takes words in any order, the last of them half typed, and '
        'every other character is a separator: no keyboard key means '
        '`AND`, `OR` or a quote to the index. The best match comes first, '
        'a hit shows the folder it is in and the words that matched, and '
        'clearing the box brings the tree back.',
    steps: <Step>[
      Step('open the docs folder inside a repository', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
      }),
      Step('words in any order find the document that says both', (
        TomRobot robot,
      ) async {
        // `runs` is only in writing.md; `paragraph` is in two guides.
        await robot.typesInTheSearch('runs paragraph');

        await robot.seesInTheResults(<String>['writing.md', '1 document']);
        await robot.seesNotInTheResults('reviewing.md');
      }),
      Step('the last word half typed still finds it', (TomRobot robot) async {
        await robot.typesInTheSearch('paragra');

        await robot.seesInTheResults(<String>['writing.md', 'reviewing.md']);
      }),
      Step('punctuation is a separator, not a rule', (TomRobot robot) async {
        await robot.typesInTheSearch('"paragraph", that-runs!');

        await robot.seesInTheResults(<String>['writing.md']);
        await robot.seesNotInTheResults('reviewing.md');
      }),
      Step('`OR` is a word, not an operator', (TomRobot robot) async {
        // As an operator it would add commands.md; as a word no document
        // has it beside `paragraph`.
        await robot.typesInTheSearch('paragraph OR commands');

        await robot.seesNoResults();
      }),
      Step('the best match is first', (TomRobot robot) async {
        await robot.typesInTheSearch('paragraph');

        await robot.seesTheResultsInOrder(<String>[
          'writing.md',
          'reviewing.md',
        ]);
      }),
      Step('a hit shows its folder and the words that matched', (
        TomRobot robot,
      ) async {
        await robot.seesTheFolderOfTheHits('guides/', hits: 2);
        await robot.seesMarkedInTheResults('paragraph');
      }),
      Step('clearing the box brings the tree back', (TomRobot robot) async {
        await robot.clearsTheSearch();

        await robot.seesInTheTree(<String>['index.md', 'guides']);
        await robot.seesNotInTheResults('writing.md');
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
