/// Planned, not written: fetch, push, pull and the foot of the git column.
/// Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedGitRemote() {
  plannedScenario(
    'Holds a request in flight',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'A remote whose upload-pack and receive-pack sleep holds a push in '
        'flight: the bar, Pushing on the pressed button, the other two '
        'unavailable, committing untouched, the bar gone afterwards.',
    survey: '4-09',
    rule:
        'git-workflow/push-pull/while-a-request-runs/doc.md — in flight is '
        'said on the button and by the bar, nothing in a band.',
    control: 'Push, Fetch, Pull while one of them runs',
    fixture: 'new: docs-with-slow-remote (a bare whose hooks sleep)',
    steps: <String>[
      'press Push: the button reads Pushing and the bar crosses the column',
      'Fetch and Pull are unavailable meanwhile',
      'committing still works while the request runs',
      'the bar is gone when the request ends',
    ],
  );
  plannedScenario(
    'Says where the branch stands, in every place it is said',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'The foot of the column at each stage, the status bar arrows, no '
        'badge on Fetch, Push unavailable once level. Adds to Fetches and '
        'Refuses a push.',
    survey: '4-10',
    rule:
        'git-workflow/push-pull/the-controls/doc.md — one fact, said in '
        'the foot, the status bar and the button counts.',
    control: 'the foot line, the status bar, Fetch, Push',
    fixture: 'docs-behind-remote',
    steps: <String>[
      'before fetching the foot says it is ahead only',
      'after fetching it says ahead and behind origin/main',
      'Fetch never carries a number',
      'level with the remote, Push is unavailable',
    ],
  );
  plannedScenario(
    'Publishes a branch the remote has never seen',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'A branch with no upstream: the foot says nothing, Push publishes, '
        'the bare repository has the branch and it tracks.',
    survey: '4-11',
    rule:
        'git-workflow/push-pull/when-it-works/doc.md — publishing a new '
        'branch sets its upstream.',
    control: 'Push on a branch with no upstream',
    fixture: 'docs-behind-remote (a branch made in a step)',
    steps: <String>[
      'a branch with no upstream says nothing about ahead or behind',
      'Push publishes it',
      'the bare repository lists the branch and the branch tracks it',
    ],
  );
  plannedScenario(
    'Says git refused the credentials, and the remote never answered',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'An upload-pack that prints an authentication failure and one that '
        'never answers: the two foot lines, nothing offering to try again '
        'for credentials, the buttons live after a timeout.',
    survey: '4-16',
    rule:
        'git-workflow/push-pull/the-link/doc.md — the link says what it is '
        'at the foot of the column.',
    control: 'Fetch against a refusing remote and against a silent one',
    fixture: 'new: docs-refusing-remote (hooks that refuse or sleep)',
    steps: <String>[
      'fetch: the foot says git refused the credentials',
      'nothing offers to try the same credentials again',
      'fetch against a remote that never answers: the foot says so',
      'the three buttons stay live after the timeout',
    ],
  );
  plannedScenario(
    'Retries a failed fetch from the band',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'Adds to Says the link is down: the band sentence, Try again fetches '
        'once more, a failed push says nothing was published.',
    survey: '4-17',
    rule:
        'git-workflow/push-pull/when-it-fails/doc.md — a failure keeps one '
        'remedy and says nothing was lost.',
    control: 'Try again in the failure band',
    fixture: 'docs-unreachable-remote',
    steps: <String>[
      'the failed fetch band says what happened',
      'Try again fetches once more',
      'a failed push says nothing was published',
    ],
  );
  plannedScenario(
    'Marks a conflict everywhere it is the state',
    group: 'Git',
    submenu: 'Remote',
    describe:
        'Adds to A pull that conflicts: C in the list and in the tree and no '
        'arrow on that row; a restart finds it; after the abort what arrived '
        'is still fetched.',
    survey: '4-18',
    rule:
        'git-workflow/push-pull/when-a-pull-conflicts/doc.md — the '
        'conflict is the repository state.',
    control: 'the changes row and the tree row of a conflicted file',
    fixture: 'docs-conflicting-remote',
    steps: <String>[
      'the list and the tree both carry C',
      'the conflicted row has no discard arrow',
      'aborting leaves what arrived fetched',
    ],
  );
}
