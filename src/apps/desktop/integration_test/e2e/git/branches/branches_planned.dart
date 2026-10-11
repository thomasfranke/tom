/// Planned, not written: the branch switcher. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedGitBranches() {
  plannedScenario(
    'Filters the branch switcher, and refuses what git refuses',
    group: 'Git',
    submenu: 'Branches',
    describe:
        'The filter and No branch by that name, a name git refuses and a name '
        'taken both leave Create branch unpressable, Back to the list, '
        'Escape and a click outside.',
    survey: '4-08',
    rule:
        'git-workflow/branch-switch/doc.md — the switcher lists, filters '
        'and creates; a bad name is refused in words.',
    control: 'the filter field, Create branch, Back to the list',
    fixture: 'docs-with-branches',
    steps: <String>[
      'typing a name filters the list',
      'a name that matches nothing says No branch by that name',
      'a name git refuses leaves Create branch unavailable',
      'a name already taken leaves Create branch unavailable',
      'Back to the list returns to the branches',
      'Escape and a click outside both close the popover',
    ],
  );
  plannedScenario(
    'Names the held document in the switch question',
    group: 'Git',
    submenu: 'Branches',
    describe:
        'An edit behind another tab raises the switch question, but the '
        'question names the document on screen, not the one held. Intended: '
        'name the held one. A defect found by Saves the edit and switches.',
    survey: 'D-35',
    rule:
        'git-workflow/branch-switch/doc.md — the question names what would '
        'be replaced.',
    control: 'the branch popover question',
    fixture: 'docs-with-branches',
    steps: <String>[
      'edit guides/writing.md, open index.md',
      'switch: the question names guides/writing.md',
    ],
  );
}
