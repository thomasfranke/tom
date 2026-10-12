/// Planned, not written: a conflicted document. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedConflicts() {
  plannedScenario(
    'Treats a marker typed by hand as text',
    group: 'Editor',
    submenu: 'Conflicts',
    describe:
        'No C, no choices, it stages outside a merge; a switch, a push or a '
        'second pull mid-merge is refused by git, not earlier.',
    survey: '4-47',
    rule:
        'editor/conflicted-document/doc.md — regions are offered only '
        'while git says so.',
    control: 'the source of a document about merging',
    fixture: 'docs-in-repo, docs-conflicting-remote',
    steps: <String>[
      'type a conflict marker into a document: no C and no choices',
      'it stages like any text',
      'mid-merge a branch switch is refused by git',
      'mid-merge a push is refused by git',
      'mid-merge a second pull is refused by git',
    ],
  );
}
