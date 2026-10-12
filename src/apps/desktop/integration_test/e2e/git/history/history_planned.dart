/// Planned, not written: a document's history. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedGitHistory() {
  plannedScenario(
    'Reads what a history entry carries',
    group: 'Git',
    submenu: 'History',
    describe:
        'Newest first with author and date, a file git never saw, the sha in '
        'the reading row, no marks while reading, the mode that comes back.',
    survey: '4-19',
    rule:
        'git-workflow/file-history/doc.md — history lists, and reading a '
        'version restores the mode afterwards.',
    control: 'a history row, Back to now',
    fixture: 'docs-with-history',
    steps: <String>[
      'entries are newest first with author and date',
      'a file git never saw lists nothing',
      'the reading row names the sha',
      'no diff marks while reading a version',
      'Back to now restores the mode being worked in',
    ],
  );
  plannedScenario(
    'Reads a past version beside the working copy',
    group: 'Git',
    submenu: 'History',
    describe:
        'Decision 81: the past version is read in Split, beside the working '
        'copy, with Split staying selected.',
    survey: '4-19b',
    rule:
        'git-workflow/file-history/doc.md — a version can be read beside '
        'the working copy.',
    control: 'the Split mode while a version is read',
    fixture: 'docs-with-history',
    steps: <String>[
      'open a past version',
      'Split is offered and chosen',
      'both the version and the working copy are on screen',
    ],
  );
}
