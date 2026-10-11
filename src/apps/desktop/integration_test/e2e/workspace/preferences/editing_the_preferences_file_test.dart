/// The file behind the popover: opened in a tab, edited by hand, and applied
/// when it is saved.
library;

import 'dart:io';

import 'package:flutter/material.dart' show Brightness;
import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  final E2eFixtures fixtures = E2eFixtures.load();
  final Fixture docsInRepo = fixtures['docs-in-repo'];
  const String broken = 'this is { not json, and nobody should lose it\n';

  scenario(
    'Keeps preferences.json and git-approvals.json in a tab each',
    group: 'Workspace',
    submenu: 'Preferences',
    describe:
        'The two files the app keeps for itself are open at once, side by '
        'side after the documents, each with its own text and its own '
        'unsaved edit: switching between them loses nothing, saving one '
        'writes that one and leaves the other alone, and closing one shows '
        'the other.',
    steps: <Step>[
      Step('open a space and the preferences file', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('untracked.md');
        await robot.opensThePreferences();
        await robot.opensThePreferencesFile();

        await robot.seesTheTabs(<String>['untracked.md', 'preferences.json']);
      }),
      Step('the list of commands opens in a tab of its own beside it', (
        TomRobot robot,
      ) async {
        await robot.opensThePreferences();
        await robot.opensTheApprovalsFile();

        await robot.seesTheTabs(<String>[
          'untracked.md',
          'preferences.json',
          'git-approvals.json',
        ]);
        await robot.seesInTheSource('"git --version": false');
      }),
      Step('an edit in the list waits there while the other tab is read', (
        TomRobot robot,
      ) async {
        await robot.rewritesInTheSource(
          '"git --version": false',
          '"git --version": true',
        );
        await robot.seesOnScreen(<String>['Unsaved']);

        await robot.choosesTheTab('preferences.json');

        await robot.seesInTheSource('"theme"');
        await robot.seesNotOnScreen('Unsaved');
        await robot.choosesTheTab('git-approvals.json');
        await robot.seesInTheSource('"git --version": true');
        await robot.seesOnScreen(<String>['Unsaved']);
      }),
      Step('saving the list writes the list, and the preferences stay', (
        TomRobot robot,
      ) async {
        final String before = File(robot.settingsPath).readAsStringSync();

        await robot.saves();

        await robot.seesNotOnScreen('Unsaved');
        robot.seesTheApprovalsFileSaying(<String>['"git --version": true']);
        expect(File(robot.settingsPath).readAsStringSync(), before);
      }),
      Step('closing the list on screen shows the preferences file', (
        TomRobot robot,
      ) async {
        await robot.closesTheTabFromTheKeyboard();

        await robot.seesTheTabs(<String>['untracked.md', 'preferences.json']);
        await robot.seesInTheSource('"theme"');
      }),
    ],
  );

  scenario(
    'Opens the preferences file and edits it by hand',
    group: 'Workspace',
    submenu: 'Preferences',
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
      Step('Keep mine keeps the buffer over what the popover chose', (
        TomRobot robot,
      ) async {
        await robot.rewritesInTheSource('"theme": "dark"', '"theme": "system"');
        await robot.opensThePreferences();
        await robot.tapText('Light');
        await robot.opensThePreferences();
        await robot.seesOnScreen(<String>['Keep mine', 'Reload']);

        await robot.tapText('Keep mine');

        await robot.seesNotOnScreen('Keep mine');
        await robot.seesInTheSource('"theme": "system"');
        robot.seesThePreferencesFileSaying(<String>['"theme": "light"']);
      }),
      Step('and the next save writes the buffer over what the popover wrote', (
        TomRobot robot,
      ) async {
        await robot.saves();

        await robot.seesNotOnScreen('Unsaved');
        robot.seesThePreferencesFileSaying(<String>['"theme": "system"']);
      }),
      Step('⌘W on the tab with an edit asks first', (TomRobot robot) async {
        await robot.rewritesInTheSource('"theme": "system"', '"theme": "dark"');

        await robot.closesTheTabFromTheKeyboard();

        await robot.seesOnScreen(<String>[
          'preferences.json has unsaved changes.',
        ]);
      }),
      Step('keeping the tab, leaving the space asks about it too', (
        TomRobot robot,
      ) async {
        await robot.tapInTheDialog('Keep the tab open');
        await robot.closesTheSpace();

        await robot.seesInTheSpaceMenu(<String>[
          'preferences.json has unsaved changes',
        ]);
      }),
      Step('staying, and saving, leaves nothing unsaved', (
        TomRobot robot,
      ) async {
        await robot.answersTheUnsavedQuestion('Stay in this space');
        await robot.saves();

        await robot.seesTheWindowIn(Brightness.dark);
      }),
      Step('its tab closes like any other', (TomRobot robot) async {
        await robot.closesTheTabFromTheKeyboard();

        await robot.seesTheTabs(<String>['untracked.md']);
        robot.seesNothingBroken();
      }),
    ],
  );

  scenario(
    'Breaks the preferences file by hand, and loses nothing',
    group: 'Workspace',
    submenu: 'Preferences',
    describe:
        'The file is the person\'s to edit, so it can be left in a state no '
        'program wrote. Text that is not JSON is saved exactly as typed and '
        'the window goes back to its defaults; a choice made in the popover '
        'meanwhile shows on screen and **is not written over the file**; '
        'and starting again finds the text intact.',
    steps: <Step>[
      Step('open a space, take the formatting bar away, open the file', (
        TomRobot robot,
      ) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();
        await robot.clickInTheTree('untracked.md');
        await robot.opensThePreferences();
        await robot.tapText('Show the formatting bar');
        await robot.seesNoFormattingBar();
        await robot.opensThePreferencesFile();
        await robot.seesTheTabs(<String>['untracked.md', 'preferences.json']);
      }),
      Step('text that is not JSON is saved as it was typed', (
        TomRobot robot,
      ) async {
        await robot.typesInTheSource(broken);
        await robot.saves();

        await robot.seesNotOnScreen('Unsaved');
        robot.seesThePreferencesFileSaying(<String>[broken]);
      }),
      Step('the window falls back to its defaults', (TomRobot robot) async {
        await robot.choosesTheTab('untracked.md');

        await robot.seesTheFormattingBar();
      }),
      Step('a choice made meanwhile shows, and does not write over the file', (
        TomRobot robot,
      ) async {
        await robot.opensThePreferences();
        await robot.tapText('Dark');

        await robot.seesTheWindowIn(Brightness.dark);
        robot.seesThePreferencesFileSaying(<String>[broken]);
        expect(
          File(robot.settingsPath).readAsStringSync(),
          isNot(contains('app.preferences')),
          reason: 'the broken file was written over',
        );
      }),
      Step('starting again finds the text intact', (TomRobot robot) async {
        await robot.launchWindowed(pickFolder: docsInRepo.root);
        await robot.chooseFolder();
        await robot.seesTheShell();

        robot
          ..seesThePreferencesFileSaying(<String>[broken])
          ..seesNothingBroken();
      }),
    ],
  );
}
