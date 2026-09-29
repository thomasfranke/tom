/// Finding words inside the open document, and replacing them one by one.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Replaces a word inside the open document',
    group: 'Search',
    describe:
        'The other half of the box: the same words, asked of the open '
        'document instead of the space, and answered by the buffer rather '
        'than by the index. The chevron opens what they become, each '
        'occurrence shows the change before it is made, and the one under '
        'the pointer is the one that can be replaced or skipped.',
    steps: <Step>[
      Step('open the docs folder and a document in it', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        // No folder is opened first: the tree arrives with every one of them
        // open, so clicking `guides` would close it.
        await robot.clickInTheTree('writing.md');

        await robot.seesTheOpenDocument('guides/writing.md');
      }),
      Step('asked of this file, the answer comes from the buffer', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSearch('paragraph');
        await robot.searchesTheOpenFile();

        // Two in one line, under the document's own first heading.
        await robot.seesInTheOccurrences(<String>[
          '2 occurrences in writing.md',
          'Writing',
        ]);
      }),
      Step('the chevron opens what the words become', (TomRobot robot) async {
        await robot.opensTheReplacement();
        await robot.typesTheReplacement('section');

        await robot.seesInTheOccurrences(<String>['section']);
      }),
      Step('replacing the current one writes it into the document', (
        TomRobot robot,
      ) async {
        await robot.replacesTheCurrentOne();

        await robot.seesInTheOccurrences(<String>[
          '1 occurrence in writing.md',
        ]);
      }),
      Step('and the editor’s own undo puts it back', (TomRobot robot) async {
        // No control of its own: the replacement went into the buffer the
        // way a keystroke does, so ⌘Z walks back through it
        // (`docs/product/search/replacing/doc.md`).
        await robot.undoes();

        await robot.seesInTheOccurrences(<String>[
          '2 occurrences in writing.md',
        ]);
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
