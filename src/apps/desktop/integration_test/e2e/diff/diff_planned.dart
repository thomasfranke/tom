/// Planned, not written: the rendered diff. Survey ids are the roadmap's.
library;

import '../../support/planned.dart';

/// Declares the plans of this menu.
void plannedDiff() {
  plannedScenario(
    'Marks the diff in every pane',
    group: 'Diff',
    describe:
        'A new file is every block added; the gutter in Split and the seam; '
        'a removed block with the chip off; the chip state itself.',
    survey: '4-20',
    rule:
        'diff/rendered-diff/how-it-is-drawn/doc.md — the marks in both '
        'panes.',
    control: 'the Diff chip, the Split mode',
    fixture: 'docs-in-repo',
    steps: <String>[
      'a new file is every block added',
      'the gutter letters in Split',
      'a removed block is a seam between the lines',
      'the chip off hides the marks',
    ],
  );
  plannedScenario(
    'Compares without moving anything',
    group: 'Diff',
    describe:
        'No branch moves, the base is in git config and survives a restart, '
        'a switch made outside is picked up by Reload.',
    survey: '4-21',
    rule: 'diff/branch-diff/doc.md — the base is the branch it came from.',
    control: 'the Diff chip, Reload',
    fixture: 'docs-branched',
    steps: <String>[
      'read the base after a branch is made in the app',
      'git config holds branch.<name>.tomBase',
      'restart: the base is the same',
      'switch outside the app, Reload picks it up',
    ],
  );
}
