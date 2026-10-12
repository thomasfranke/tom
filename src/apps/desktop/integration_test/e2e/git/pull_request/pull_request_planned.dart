/// Planned, not written: the pull request page and its row. Survey ids are
/// the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedGitPullRequest() {
  plannedScenario(
    'Holds the pull request back over unfinished work',
    group: 'Git',
    submenu: 'Pull request',
    describe:
        'Uncommitted work and unpublished commits each have their sentence; '
        'both actions are unavailable over uncommitted work; the row Push '
        'publishes and the row turns to Ready.',
    survey: '4-22',
    rule:
        'git-workflow/pull-request/opening-it/doc.md — a branch with '
        'unfinished work cannot be proposed yet.',
    control: 'the status row Push, Create pull request, Open on GitHub',
    fixture: 'docs-proposing (one pass with the fake gh, one without)',
    steps: <String>[
      'uncommitted work: the row says so and both actions are unavailable',
      'unpublished commits: the row says how many and offers Push',
      'Push publishes and the row turns to Ready',
    ],
  );
  plannedScenario(
    'Presses the page actions of the pull request',
    group: 'Git',
    submenu: 'Pull request',
    describe:
        'Open on GitHub hands over an address holding branch, title and '
        'body; unavailable with no heading; Overview and back; the status '
        'row takes the action when the column shuts; Cmd-W leaves the page '
        'and keeps the draft.',
    survey: '4-24',
    rule:
        'git-workflow/pull-request/the-draft/doc.md — the page offers one '
        'action while there is no token.',
    control: 'Open on GitHub, Overview, Open on GitHub instead, Cmd-W',
    fixture: 'docs-proposing',
    steps: <String>[
      'Open on GitHub asks the browser for an address with branch and title',
      'with no heading the action is unavailable',
      'Overview and back',
      'the status row carries the action when the git column shuts',
      'Cmd-W leaves the page and the draft stays',
    ],
  );
  plannedScenario(
    'Says the pull request was not opened',
    group: 'Git',
    submenu: 'Pull request',
    describe:
        'A gh that refuses pr create: the row in removed, Show the command '
        'opens the panel on gh pr create, already exists shows the open one.',
    survey: '4-25',
    rule:
        'git-workflow/pull-request/opening-it/doc.md — a failed creation '
        'is named and the draft is kept.',
    control: 'Create pull request, Show the command',
    fixture: 'docs-proposing with a gh script that refuses pr create',
    steps: <String>[
      'Create pull request is refused by gh',
      'the row says it was not created',
      'Show the command opens the panel on the gh pr create row',
      'an already-open pull request shows its number',
    ],
  );
  plannedScenario(
    'Proposes onto the branch it came from, or another',
    group: 'Git',
    submenu: 'Pull request',
    describe:
        'The base starts at the branch the checked-out one came from; '
        'choosing another re-reads the proposal.',
    survey: '4-26',
    rule:
        'git-workflow/pull-request/the-draft/doc.md — the base is pickable '
        'for the pull request, automatic for the diff.',
    control: 'the PROPOSING ONTO select',
    fixture:
        'new: docs-proposing-from-develop (GitHub origin, develop, a '
        'branch off it)',
    steps: <String>[
      'the base starts at develop',
      'choosing main re-reads the commits and documents',
      'choosing develop again restores them',
    ],
  );
  plannedScenario(
    'Keeps the pull request row in its place',
    group: 'Git',
    submenu: 'Pull request',
    describe:
        'Not drawn while search has the column; highlighted while its page '
        'is up. Adds to Writes a pull request.',
    survey: '5-12',
    rule:
        'git-workflow/pull-request/opening-it/doc.md — the row is part of '
        'the tree column.',
    control: 'the Pull request row',
    fixture: 'docs-proposing',
    steps: <String>[
      'with search showing hits the row is not drawn',
      'with the page up the row is highlighted',
    ],
  );
}
