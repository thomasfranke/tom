/// Planned, not written: leaving a space. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedLeavingASpace() {
  plannedScenario(
    'Treats Esc on the unsaved question as staying',
    group: 'Workspace',
    submenu: 'Leaving a space',
    describe:
        'Esc and a click outside while the unsaved question is up are Stay '
        '(decision 19). Written once, red: the question survives the key, '
        'a defect of the app.',
    survey: 'D-18',
    rule: 'workspace/leaving-a-space/doc.md — Esc is stay.',
    control: 'Esc on the unsaved question',
    fixture: 'docs-in-repo, repo-itself',
    steps: <String>[
      'edit, ask to open another space',
      'Esc puts the question away and keeps the edit',
      'a click outside does the same',
    ],
  );
}
