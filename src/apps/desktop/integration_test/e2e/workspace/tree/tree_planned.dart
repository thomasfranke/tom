/// Planned, not written: the file tree. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedTree() {
  plannedScenario(
    'Draws the same letter in the tree and the changes list',
    group: 'Workspace',
    submenu: 'Tree',
    describe:
        'A folder holding a change carries a dot; the same letter in both '
        'places, and D for a removed file (decision 47).',
    survey: '4-38',
    rule:
        'navigation/file-tree/change-marks/doc.md — one letter, one '
        'meaning.',
    control: 'the tree marks and the changes rows',
    fixture: 'docs-in-repo',
    steps: <String>[
      'a changed file carries the same letter in both places',
      'its folder carries a dot',
      'a deleted file is D in the list',
    ],
  );
  plannedScenario(
    'Arrives with the name field filled',
    group: 'Workspace',
    submenu: 'Tree',
    describe: 'untitled.md with the name selected; Escape creates nothing.',
    survey: '4-54',
    rule:
        'navigation/file-tree/new-document/doc.md — the name starts '
        'selected.',
    control: 'the plus at the head of the explorer',
    fixture: 'docs-in-repo',
    steps: <String>[
      'press plus: untitled.md is selected in the field',
      'Escape creates nothing',
      'the caret is on the first line of a new document',
    ],
  );
  plannedScenario(
    'Arranges the tree with a document open',
    group: 'Workspace',
    submenu: 'Tree',
    describe:
        'New folder goes beside the open document; Collapse all keeps its '
        'folder open; Reveal asks for the space folder; the menu rules and '
        'a click outside.',
    survey: '4-55',
    rule: 'navigation/file-tree/explorer-menu/doc.md — three groups of rows.',
    control: 'the explorer menu',
    fixture: 'docs-in-repo',
    steps: <String>[
      'New folder lands beside the open document',
      'Collapse all keeps the open document folder open',
      'Reveal asks for the space folder',
      'a click outside puts the menu away',
    ],
  );
  plannedScenario(
    'Lists what the tree does not open, in order',
    group: 'Workspace',
    submenu: 'Tree',
    describe:
        'Clicking the image opens no tab; folders first, each by name, '
        'ignoring case and accents.',
    survey: '4-56',
    rule: 'navigation/file-tree/doc.md — order and what opens.',
    control: 'tree rows',
    fixture: 'docs-in-repo',
    steps: <String>[
      'clicking an image opens no tab',
      'folders come first',
      'names sort ignoring case and accents',
    ],
  );
  plannedScenario(
    'Shows what the folder really holds, in order',
    group: 'Workspace',
    submenu: 'Tree',
    describe:
        'A dotfolder shown; a txt file and a link listed and inert; a link '
        'never followed; folders first at two levels.',
    survey: '4-60',
    rule: 'navigation/file-tree/doc.md — the tree is the folder.',
    control: 'tree rows of every kind',
    fixture: 'new: docs-with-oddities',
    steps: <String>[
      'a dotfolder is shown',
      'a txt file and a symbolic link are listed and inert',
      'the link is never followed',
      'folders come first at two levels',
    ],
  );
  plannedScenario(
    'Says why a folder has nothing to show',
    group: 'Workspace',
    submenu: 'Tree',
    describe:
        'An empty folder, one removed from outside, one TOM may not '
        'read.',
    survey: '5-22',
    rule: 'navigation/file-tree/doc.md — each empty state has its sentence.',
    control: 'the tree body',
    fixture: 'none (the scenario makes the folders)',
    steps: <String>[
      'an empty folder says This folder holds nothing yet',
      'a folder removed from outside says it is gone',
      'a folder TOM may not read says so',
    ],
  );
}
