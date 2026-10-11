/// Planned, not written: opening, editing and reading a document. Survey ids
/// are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedDocuments() {
  plannedScenario(
    'Says why a document will not open',
    group: 'Editor',
    submenu: 'Documents',
    describe:
        'Deleted from outside, one TOM may not read, one that is not UTF-8: '
        'each sentence.',
    survey: '4-46',
    rule: 'editor/source-mode/doc.md — a document that cannot open says why.',
    control: 'a tree row of each kind',
    fixture: 'docs-in-repo (the step prepares the three files)',
    steps: <String>[
      'a file deleted from outside says it is no longer there',
      'a file TOM may not read says so',
      'a file that is not UTF-8 says so',
    ],
  );
  plannedScenario(
    'Says Saved, and saving again changes nothing',
    group: 'Editor',
    submenu: 'Documents',
    describe:
        'Adds to Edits a document and saves it: the status bar, the '
        'modification time.',
    survey: '4-48',
    rule:
        'editor/source-mode/doc.md — a save with nothing changed writes '
        'nothing.',
    control: 'Cmd-S',
    fixture: 'docs-in-repo',
    steps: <String>[
      'the status bar says Saved after a save',
      'a second Cmd-S leaves the modification time as it was',
    ],
  );
  plannedScenario(
    'Keeps the mode when the next document opens',
    group: 'Editor',
    submenu: 'Documents',
    describe:
        'Adds to Reads a document with the source out of the way: the '
        'window mode, not the document.',
    survey: '4-49',
    rule: 'editor/markdown-preview/doc.md — the mode belongs to the window.',
    control: 'the mode control and the next tree row',
    fixture: 'docs-in-repo',
    steps: <String>[
      'choose Preview, open another document',
      'it opens in Preview',
    ],
  );
  plannedScenario(
    'Redoes in the source',
    group: 'Editor',
    submenu: 'Documents',
    describe: 'Undo, then Cmd-Shift-Z.',
    survey: '5-31',
    rule: 'editor/source-mode/doc.md — the editor history.',
    control: 'Cmd-Shift-Z',
    fixture: 'docs-in-repo',
    steps: <String>['type, undo', 'redo restores the text'],
  );
  plannedScenario(
    'Brings both panes back with Split',
    group: 'Editor',
    submenu: 'Documents',
    describe: 'Both panes are on screen after the press.',
    survey: '5-25',
    rule: 'editor/markdown-preview/doc.md — Split shows both.',
    control: 'Split',
    fixture: 'docs-in-repo',
    steps: <String>['choose Preview', 'choose Split: source and preview'],
  );
  plannedScenario(
    'Puts the document area where the boards do',
    group: 'Editor',
    submenu: 'Documents',
    describe:
        'Run with --board: tabs over tools over the document, both ends on '
        'the pane, line numbers.',
    survey: '5-24',
    rule: 'design/screens — the boards are the reference.',
    control: 'the whole document area',
    fixture: 'docs-in-repo',
    steps: <String>[
      'open a document at the board size',
      'the rows sit where the board puts them',
    ],
  );
  plannedScenario(
    'Leaves every surface the quiet way',
    group: 'Editor',
    submenu: 'Documents',
    describe:
        'Escape and a click outside for the space menu, the name row, the '
        'candidates menu and the [[ offer: the surface gone, nothing chosen.',
    survey: '5-30',
    rule: 'workspace/columns/doc.md — every popover closes without choosing.',
    control: 'Escape, a click outside',
    fixture: 'docs-with-wikilinks, docs-in-repo',
    steps: <String>[
      'Escape on the space menu',
      'a click outside the name row',
      'Escape on the candidates menu',
      'a click outside the [[ offer',
    ],
  );
}
