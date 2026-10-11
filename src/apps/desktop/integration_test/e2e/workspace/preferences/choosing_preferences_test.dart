/// The gear at the end of the bar, and what choosing does to the window.
library;

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Chooses a preference, and the window answers at once',
    group: 'Workspace',
    submenu: 'Preferences',
    describe:
        'The rule that makes the absence of OK and Cancel honest: **a '
        'preference applies when it is chosen**. The scenario opens the '
        'popover, takes the formatting bar away and watches seventeen '
        'buttons leave the row while the popover is still open, speaks '
        'Portuguese and English again without a restart — then closes it by '
        'pressing the gear again, which is the one way out that is visible.',
    steps: <Step>[
      Step('open a space, with the bar above the document', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('untracked.md');
        await robot.seesTheFormattingBar();
      }),
      Step('the gear opens the preferences', (TomRobot robot) async {
        await robot.opensThePreferences();

        await robot.seesOnScreen(<String>[
          'THEME',
          'LANGUAGE',
          'Show the formatting bar',
        ]);
      }),
      Step('taking the bar away empties the row while the popover is open', (
        TomRobot robot,
      ) async {
        await robot.tapText('Show the formatting bar');

        await robot.seesNoFormattingBar();
        // No OK and no Cancel: the window changed behind the popover.
        await robot.seesOnScreen(<String>['THEME']);
      }),
      Step('choosing Português speaks it at once, the popover included', (
        TomRobot robot,
      ) async {
        await robot.choosesTheLanguage('Português');

        await robot.seesOnScreen(<String>[
          'TEMA',
          'IDIOMA',
          'Mostrar a barra de formatação',
        ]);
        await robot.seesNotOnScreen('THEME');
      }),
      Step('and English brings the words back', (TomRobot robot) async {
        await robot.choosesTheLanguage('English');

        await robot.seesOnScreen(<String>['THEME', 'LANGUAGE']);
      }),
      Step('the gear closes what it opened', (TomRobot robot) async {
        await robot.opensThePreferences();

        await robot.seesNotOnScreen('THEME');
      }),
      Step('and the view modes are still offered, in the top bar', (
        TomRobot robot,
      ) async {
        // The modes live in the top bar since the 1b restyle, so taking the
        // formatting bar away never takes the way to choose a view.
        await robot.seesOnScreen(<String>['Source', 'Split', 'Preview']);
        robot.seesNothingBroken();
      }),
    ],
  );
}
