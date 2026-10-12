/// A change outside the space, opened from the changes list.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture beside = fixtures['docs-changed-beside'];

  scenario(
    'Opens a change from beside the space',
    group: 'Git',
    submenu: 'Local',
    describe:
        'The space is a folder of the repository and every change is beside '
        'it, which is where a row that only opened the space\'s documents '
        'opened nothing at all. Pressing the README opens it in a tab with '
        'the diff on, though the tree lists no such file, and an edit is '
        'saved at the repository\'s root; a YAML file opens as text with its '
        'lines marked; a deleted document opens rendered with every block '
        'removed and no way back to a now that is gone; and a binary file '
        'says so instead of showing noise '
        '(`docs/product/git-workflow/commit/opening-a-change/doc.md`).',
    steps: <Step>[
      Step('open a space whose changes are all beside it', (
        TomRobot robot,
      ) async {
        // Both before the app starts, so the first reading of git has them.
        File('${beside.repositoryRoot}/CHANGELOG.md').deleteSync();
        // A PNG's own signature, whose zero bytes are git's test for binary.
        File('${beside.repositoryRoot}/logo.png').writeAsBytesSync(<int>[
          0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
          0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        ]);
        await robot.launchWindowed(pickFolder: beside.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.seesInTheChanges(<String>[
          'CHANGELOG.md',
          'README.md',
          'logo.png',
          'mkdocs.yml',
        ]);
      }),
      Step('the README beside it opens with the diff on', (
        TomRobot robot,
      ) async {
        await robot.opensTheChange('README.md');

        await robot.seesTheTabs(<String>['README.md']);
        await robot.seesInThePreview(
          'A line added beside the docs, uncommitted.',
        );
        await robot.seesTheDiffMarks(<String>['A']);
        robot.seesNoOpenRowInTheTree();
      }),
      Step('an edit is saved to the file at the repository root', (
        TomRobot robot,
      ) async {
        await robot.typesAtTheEndOfTheSource('\nAnd one more, saved.\n');
        await robot.saves();

        await robot.seesSavedTo(
          '${beside.repositoryRoot}/README.md',
          'And one more, saved.',
        );
        expect(
          File('${beside.root}/README.md').existsSync(),
          isFalse,
          reason: 'the save landed in the space instead',
        );
      }),
      Step('a YAML file opens as text, its new line marked', (
        TomRobot robot,
      ) async {
        await robot.opensTheChange('mkdocs.yml');

        await robot.seesTheModes(chosen: 'Source', offered: <String>['Source']);
        await robot.seesTheLineMarks(<String>['A']);
        robot.seesNoDiffChip();
        await robot.seesTheFileKind('YAML');
        robot.seesNoOpenRowInTheTree();
      }),
      Step('a deleted document opens rendered, every block removed', (
        TomRobot robot,
      ) async {
        await robot.opensTheChange('CHANGELOG.md');

        await robot.seesInThePreview(
          'The first pass at the notes, written before the docs folder '
          'existed.',
        );
        await robot.seesEveryBlockRemoved();
        await robot.seesTheTabDeleted('CHANGELOG.md');
        await robot.seesTheModes(
          chosen: 'Preview',
          offered: <String>['Source', 'Split', 'Preview'],
        );
        robot
          ..seesNoWayBackToNow()
          ..seesNoDiffChip();
        await robot.seesTheFileKind('Markdown', readOnly: true);
      }),
      Step('a binary file says so, and offers the file itself', (
        TomRobot robot,
      ) async {
        await robot.opensTheChange('logo.png');

        await robot.seesABinaryFile();
        await robot.seesTheModes(chosen: null, offered: <String>[]);
        await robot.seesTheFileKind('Binary', readOnly: true);
      }),
      Step('Reveal asks the file manager for the folder that holds it', (
        TomRobot robot,
      ) async {
        await robot.revealsTheFile();

        await robot.seesTheFileManagerAskedFor(beside.repositoryRoot);
      }),
      Step('Discard all changes puts back what is beside the space, too', (
        TomRobot robot,
      ) async {
        await robot.choosesFromTheMenu('Git menu', 'Discard all changes');
        await robot.seesOnScreen(<String>[
          '3 documents go back to the last commit.',
        ]);
        await robot.tapInTheDialog('Discard all changes');

        await robot.seesNotInTheChanges('README.md');
        await robot.seesNotInTheChanges('mkdocs.yml');
        await robot.seesNotInTheChanges('CHANGELOG.md');
        // The binary file git never had is kept, untracked.
        await robot.seesInTheChanges(<String>['logo.png']);
        expect(
          File('${beside.repositoryRoot}/README.md').readAsStringSync(),
          isNot(contains('A line added beside the docs')),
        );
        expect(
          File('${beside.repositoryRoot}/CHANGELOG.md').existsSync(),
          isTrue,
        );
        expect(File('${beside.repositoryRoot}/logo.png').existsSync(), isTrue);
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
