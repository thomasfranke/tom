/// The git column's `⋮`: its rows, and the discard that asks first.
library;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Goes back to the last commit from the git menu',
    group: 'Git — local',
    describe:
        'What the `⋮` at the head of the git column offers, against a real '
        'repository holding one modified document and one untracked one. '
        '`Discard all changes` asks first and names how many documents go '
        'back; answered, the modified one is the last commit again — in the '
        'changes list and in the preview on screen — and the untracked one '
        'is still there, because git never recorded it. Opening a terminal or '
        'the file manager is left to the unit tests: a run that did would do '
        'it on whoever runs it.',
    steps: <Step>[
      Step('open the docs folder, and the document that changed', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('writing.md');
        await robot.seesInThePreview('One line added, uncommitted.');
      }),
      Step('the git menu offers three rows, then the discard apart', (
        TomRobot robot,
      ) async {
        await robot.opensTheMenu('Git menu');
        await robot.seesInTheMenu(<String>[
          'Reload',
          'Open in terminal',
          'Open repository in Finder',
          'Discard all changes',
        ]);
      }),
      Step('the discard asks first, naming how many go back', (
        TomRobot robot,
      ) async {
        await robot.tapText('Discard all changes');
        await robot.seesOnScreen(<String>[
          'Discard all changes?',
          '1 document goes back to the last commit.',
        ]);
      }),
      Step('answered, the document is the last commit again', (
        TomRobot robot,
      ) async {
        await robot.tapInTheDialog('Discard all changes');
        await robot.seesNotInTheChanges('writing.md');
        await robot.seesNotInThePreview('One line added, uncommitted.');
      }),
      Step('and the untracked document is untouched', (TomRobot robot) async {
        await robot.seesInTheChanges(<String>['untracked.md']);
      }),
      Step('and nothing is broken', (TomRobot robot) async {
        robot.seesNothingBroken();
      }),
    ],
  );
}
