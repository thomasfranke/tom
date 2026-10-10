/// The explorer's `⋮`: a folder made, the tree folded, and the disk re-read.
library;

import 'dart:io';

import 'package:tom_domain/tom_domain.dart';

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Arranges the tree from its menu',
    group: 'Workspace',
    describe:
        'What the `⋮` at the head of the explorer offers, on a real folder: '
        'a folder named in the tree the way a document is, every folder '
        'closed at once, and the disk read again for a file that arrived from '
        'outside TOM — which nothing else notices, since nothing watches the '
        'folder. Revealing it in the file manager is left to the unit tests, '
        'because a run that opened Finder would open it on whoever runs it.',
    steps: <Step>[
      Step('open the docs folder inside a repository', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheTree(<String>['writing.md']);
      }),
      Step('New folder asks for a name, and the folder appears', (
        TomRobot robot,
      ) async {
        await robot.createsAFolder('drafts');
        await robot.seesInTheTree(<String>['drafts']);
      }),
      Step('Collapse all closes every folder', (TomRobot robot) async {
        await robot.choosesFromTheMenu('Explorer menu', 'Collapse all');
        robot.seesNotInTheTree('writing.md');
        await robot.seesInTheTree(<String>['guides', 'index.md']);
      }),
      Step('a file written from outside waits for Reload', (
        TomRobot robot,
      ) async {
        File(
          '${docsInRepo.root}/from-outside.md',
        ).writeAsStringSync('# Written elsewhere\n');
        robot.seesNotInTheTree('from-outside.md');

        await robot.choosesFromTheMenu('Explorer menu', 'Reload');

        await robot.seesInTheTree(<String>['from-outside.md']);
        await robot.seesTheTreeMark('from-outside.md', FileStateEnum.untracked);
      }),
      Step('the menu offers four things, in three groups', (
        TomRobot robot,
      ) async {
        await robot.opensTheMenu('Explorer menu');
        await robot.seesInTheMenu(<String>[
          'New folder',
          'Collapse all',
          'Reload',
          'Reveal in Finder',
        ]);
      }),
      Step('Escape puts it away', (TomRobot robot) async {
        await robot.dismissesTheMenu();
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
