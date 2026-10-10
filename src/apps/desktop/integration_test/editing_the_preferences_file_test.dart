/// The file behind the popover: opened in a tab, edited by hand, and applied
/// when it is saved.
library;

import 'package:flutter/material.dart' show Brightness;

import 'support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];

  scenario(
    'Opens the preferences file and edits it by hand',
    group: 'Workspace',
    describe:
        'A settings format a user can read is one a user will want to see. '
        '`Open preferences.json` puts the file in a tab of its own beside the '
        'documents — source only, JSON as a person would write it, no row of '
        'the tree open — and **saving it applies it**: the theme typed into '
        'the file is the window\'s the moment ⌘S lands.',
    steps: <Step>[
      Step('open a space, and choose Light so a change will show', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('untracked.md');
        await robot.opensThePreferences();
        await robot.tapText('Light');
        await robot.seesTheWindowIn(Brightness.light);
      }),
      Step('Open preferences.json puts the file in a tab of its own', (
        TomRobot robot,
      ) async {
        await robot.opensThePreferencesFile();

        await robot.seesTheTabs(<String>['untracked.md', 'preferences.json']);
        await robot.seesNotOnScreen('THEME');
        await robot.seesInTheSource('"theme": "light"');
      }),
      Step('it is source only, JSON, and in no repository', (
        TomRobot robot,
      ) async {
        robot
          ..seesThePanes(source: true, preview: false)
          ..seesOnlySourceOffered();
        await robot.seesOnScreen(<String>['JSON']);
        await robot.seesNotOnScreen('Markdown');
        await robot.seesNotOnScreen('Diff');
        await robot.seesNoMarksInTheSource();
      }),
      Step('typing dark over light and saving turns the window dark', (
        TomRobot robot,
      ) async {
        await robot.rewritesInTheSource('"theme": "light"', '"theme": "dark"');
        await robot.saves();

        await robot.seesTheWindowIn(Brightness.dark);
      }),
      Step('the file says it as plain JSON, never escaped in a string', (
        TomRobot robot,
      ) async {
        robot.seesThePreferencesFileSaying(<String>[
          '"app.preferences": {',
          '"theme": "dark"',
        ]);
      }),
      Step('a choice in the popover reaches the tab, which has no edit', (
        TomRobot robot,
      ) async {
        await robot.opensThePreferences();
        await robot.tapText('Light');
        await robot.opensThePreferences();

        await robot.seesTheWindowIn(Brightness.light);
        await robot.seesInTheSource('"theme": "light"');
      }),
      Step('with an edit in the tab, it asks instead, and Reload takes the '
          'file', (TomRobot robot) async {
        await robot.rewritesInTheSource('"system"', '"english"');
        await robot.opensThePreferences();
        await robot.tapText('Dark');
        await robot.opensThePreferences();

        await robot.seesOnScreen(<String>['Keep mine', 'Reload']);
        await robot.seesInTheSource('"english"');
        await robot.tapText('Reload');
        await robot.seesInTheSource('"theme": "dark"');
        await robot.seesNotOnScreen('Keep mine');
      }),
      Step('its tab closes like any other', (TomRobot robot) async {
        await robot.closesTheTabFromTheKeyboard();

        await robot.seesTheTabs(<String>['untracked.md']);
        robot.seesNothingBroken();
      }),
    ],
  );
}
