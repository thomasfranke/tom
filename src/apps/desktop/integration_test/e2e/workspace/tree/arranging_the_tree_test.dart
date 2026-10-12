/// The explorer's `⋮`: a folder made, the tree folded, and the disk re-read.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_domain/tom_domain.dart';

import '../../../support/harness.dart';

/// The explorer menu's last row, which names the platform's own file
/// manager (`file_manager_words.dart`'s `revealLabel`): `Finder` on macOS,
/// `Files` everywhere this suite runs.
final String _revealLabel = Platform.isMacOS
    ? 'Reveal in Finder'
    : 'Show in Files';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Arranges the tree from its menu',
    group: 'Workspace',
    submenu: 'Tree',
    describe:
        'What the `⋮` at the head of the explorer offers, on a real folder: '
        'a folder named in the tree the way a document is, every folder '
        'closed at once, and the disk read again for a file that arrived from '
        'outside TOM — which nothing else notices, since nothing watches the '
        'folder. Revealing the space in the file manager is asked of a '
        'desktop that writes the request down, so no run opens Finder on '
        'whoever runs it.',
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
        expect(Directory('${docsInRepo.root}/drafts').existsSync(), isTrue);
      }),
      Step('a folder name already taken is refused in place', (
        TomRobot robot,
      ) async {
        File('${docsInRepo.root}/drafts/keep.md').writeAsStringSync('# Kept\n');
        await robot.createsAFolder('drafts');
        await robot.seesTheNameRefused();
        await robot.cancelsTheNewDocument();
        expect(
          File('${docsInRepo.root}/drafts/keep.md').readAsStringSync(),
          '# Kept\n',
          reason: 'the folder that held the name was disturbed',
        );
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
      Step('names sort ignoring case and accents', (TomRobot robot) async {
        for (final String name in <String>['Zebra', 'ácido', 'apple']) {
          File('${docsInRepo.root}/$name.md').writeAsStringSync('# $name\n');
        }
        await robot.choosesFromTheMenu('Explorer menu', 'Reload');
        await robot.seesInTheTree(<String>['apple.md']);

        // A plain code-point sort would put `Zebra` first and `ácido` last.
        await robot.seesTheTreeInOrder(<String>[
          'ácido.md',
          'apple.md',
          'from-outside.md',
          'Zebra.md',
        ]);
      }),
      Step('the menu offers four things, in three groups', (
        TomRobot robot,
      ) async {
        await robot.opensTheMenu('Explorer menu');
        await robot.seesInTheMenu(<String>[
          'New folder',
          'Collapse all',
          'Reload',
          _revealLabel,
        ]);
      }),
      Step('Escape puts it away', (TomRobot robot) async {
        await robot.dismissesTheMenu();
      }),
      Step('Reveal asks the file manager for the space\'s folder', (
        TomRobot robot,
      ) async {
        await robot.choosesFromTheMenu('Explorer menu', _revealLabel);
        await robot.seesTheFileManagerAskedFor(docsInRepo.root);
      }),
      Step('Reload files what arrived into the search, too', (
        TomRobot robot,
      ) async {
        File(
          '${docsInRepo.root}/brewing.md',
        ).writeAsStringSync('# Brewing\n\nThe study of zymurgy.\n');
        await robot.choosesFromTheMenu('Explorer menu', 'Reload');
        await robot.seesInTheTree(<String>['brewing.md']);

        await robot.typesInTheSearch('zymurgy');

        await robot.seesInTheResults(<String>['brewing.md']);
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
