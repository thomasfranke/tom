/// Planned, not written: the preferences. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedPreferences() {
  plannedScenario(
    'Keeps a preference across spaces and restarts',
    group: 'Workspace',
    submenu: 'Preferences',
    describe:
        'Theme, language and the formatting bar hold in another space and '
        'after a relaunch; on Home the gear opens and Open preferences.json '
        'is dim.',
    survey: '4-29',
    rule:
        'preferences/what-it-holds/doc.md — a choice is the person is '
        'kept.',
    control: 'the gear and its three choices',
    fixture: 'docs-in-repo, repo-itself',
    steps: <String>[
      'choose dark, Portuguese and no bar',
      'open another space: the three still hold',
      'relaunch: the three still hold',
      'on Home the gear opens and Open preferences.json is dim',
    ],
  );
  plannedScenario(
    'Reads a preferences file it did not write',
    group: 'Workspace',
    submenu: 'Preferences',
    describe:
        'A retired language and a wrong type open in the defaults; the older '
        'string-escaped shape is read; an open tab is not written over.',
    survey: '4-30',
    rule:
        'preferences/where-it-is-stored/doc.md — a value nobody can read is '
        'the default, silently.',
    control: 'the preferences store at launch',
    fixture: 'docs-in-repo (the file written before launch)',
    steps: <String>[
      'a retired language opens in the default',
      'a wrong type opens in the default',
      'the older shape is read',
      'a machine that never chose finds its three preferences',
    ],
  );
  plannedScenario(
    'Chooses every preference and leaves the popover every way',
    group: 'Workspace',
    submenu: 'Preferences',
    describe:
        'System for both, the lit segment and the tick, the gear lit while '
        'open, Esc and a click outside, the bar back on.',
    survey: '4-31',
    rule:
        'preferences/what-it-holds/doc.md — a preference applies when it '
        'is pressed; the popover closes three ways.',
    control: 'the theme and language selects, the bar checkbox, Esc',
    fixture: 'docs-in-repo',
    steps: <String>[
      'System theme and System language',
      'the chosen segment is lit and the choice ticked',
      'the gear is lit while the popover is open',
      'Esc closes it',
      'a click outside closes it',
      'the bar comes back and the row keeps Diff',
    ],
  );
  plannedScenario(
    'Treats the preferences tab as a tab',
    group: 'Workspace',
    submenu: 'Preferences',
    describe:
        'Formatting dim, no tree row open, a language and the bar typed into '
        'the file apply on save, a value it cannot use falls back, back by '
        'its tab.',
    survey: '4-32',
    rule: 'preferences/where-it-is-stored/doc.md — the file opens in a tab.',
    control: 'the preferences.json tab',
    fixture: 'docs-in-repo',
    steps: <String>[
      'the formatting buttons are dim and no tree row is open',
      'typing a language into the file applies it on save',
      'a value it cannot use falls back to the default',
      'choosing the other tab and back finds the file',
    ],
  );
}
