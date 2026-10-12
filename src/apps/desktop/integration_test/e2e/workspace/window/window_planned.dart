/// Planned, not written: the window's columns. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedWindow() {
  plannedScenario(
    'Measures every toggle and every gutter',
    group: 'Workspace',
    submenu: 'Window',
    describe:
        'The bottom toggle, Show git and back to Git, both columns hidden, '
        'each gutter limits, a closed column gutter brings it back, no '
        'remote button with the git column shut.',
    survey: '4-37',
    rule:
        'workspace/columns/doc.md — a closed column keeps its gutter and '
        'dragging it opens the column (decision 16).',
    control: 'the three toggles and the gutters',
    fixture: 'docs-in-repo',
    steps: <String>[
      'the bottom toggle opens and closes the panel',
      'Show git and back to Git',
      'both columns hidden at once',
      'each gutter stops at its limits',
      'dragging a closed column gutter opens the column',
      'no remote button anywhere with the git column shut',
    ],
  );
}
