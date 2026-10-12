/// Planned, not written: Home. Survey ids are the roadmap's.
library;

import '../../support/planned.dart';

/// Declares the plans of this menu.
void plannedHome() {
  plannedScenario(
    'Refuses a folder that is gone, and offers another',
    group: 'Home',
    describe:
        'A recent space whose folder was removed: the row draws no branch, '
        'the refusal names the path, Choose another folder recovers; from '
        'the breadcrumb the window does not move.',
    survey: '4-27',
    rule:
        'home/README.md — Home refuses a folder that is gone, in three '
        'faces (decision 15).',
    control: 'a recent row, Choose another folder, the breadcrumb menu',
    fixture: 'new: space-to-lose (throwaway folder removed in a step)',
    steps: <String>[
      'open the space, relaunch, remove its folder',
      'the recent row draws no branch',
      'pressing it names the path in the refusal',
      'Choose another folder recovers',
      'from the breadcrumb a moved space says so and the window stays',
    ],
  );
  plannedScenario(
    'Says which branch a recent space is on now',
    group: 'Home',
    describe:
        'A branch changed outside is the one named; detached names none and '
        'still forgets; the folder line; two rows newest first.',
    survey: '4-28',
    rule:
        'home/recent-spaces/doc.md — each row names its branch as it is '
        'now.',
    control: 'a recent row',
    fixture: 'docs-in-repo and docs-with-branches',
    steps: <String>[
      'switch the branch outside the app and relaunch',
      'the row names the new branch',
      'detached: no branch is named and Forget still works',
      'two rows are listed newest first',
    ],
  );
  plannedScenario(
    'Tries a clone again after no network',
    group: 'Home',
    describe:
        'An address under .invalid says no network; the address is kept and '
        'Clone tries again.',
    survey: '4-41',
    rule: 'home/cloning/doc.md — a failed clone keeps the address.',
    control: 'the Clone button',
    fixture: 'docs-to-clone (an address under .invalid)',
    steps: <String>[
      'clone an address that does not resolve',
      'the sentence says no network',
      'the address is still in the field',
      'Clone tries again',
    ],
  );
  plannedScenario(
    'Says git is not installed',
    group: 'Home',
    describe: 'Home second refusal and the clone sentence, with no git.',
    survey: '5-16',
    rule:
        'home/README.md — Home refuses a machine without git (decision 10 '
        'of the git executable seam).',
    control: 'Choose folder and Clone with a missing executable',
    fixture: 'none (gitExecutable pointing at nothing)',
    steps: <String>[
      'choosing a folder says git is not installed',
      'a clone says the same',
    ],
  );
  plannedScenario(
    'Leaves the clone field every way',
    group: 'Home',
    describe:
        'Escape puts the button back; a blank address; one that names no '
        'folder; a cancelled folder dialog.',
    survey: '5-18',
    rule: 'home/cloning/doc.md — the field has ways out.',
    control: 'the clone field, Clone, Escape',
    fixture: 'docs-to-clone',
    steps: <String>[
      'Escape puts the button back',
      'a blank address does nothing',
      'an address that names no folder is refused',
      'a cancelled folder dialog leaves Home as it was',
    ],
  );
  plannedScenario(
    'Leaves Home undisturbed',
    group: 'Home',
    describe:
        'A cancelled folder dialog leaves Home; the wordmark and the trunk '
        'are on Home and nowhere else.',
    survey: '5-19',
    rule: 'home/README.md — Home is the opening screen only.',
    control: 'Choose folder',
    fixture: 'docs-in-repo',
    steps: <String>[
      'cancel the folder dialog',
      'the wordmark and trunk are drawn',
      'in a space they are not',
    ],
  );
}
