/// Planned, not written: a folder with no repository. Survey ids are the
/// roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedWithoutARepository() {
  plannedScenario(
    'Draws nothing of git in a folder with no repository',
    group: 'Workspace',
    submenu: 'Without a repository',
    describe:
        'Search finds, no tree mark, the status bar and breadcrumb drop the '
        'branch, Git Push Summary Commit absent, the Pull request row opens '
        'nothing, no .git appeared.',
    survey: '4-40',
    rule:
        'workspace/without-a-repository/doc.md — a control that cannot '
        'work is not drawn.',
    control: 'the whole shell of a folder with no repository',
    fixture: 'not-a-repository',
    steps: <String>[
      'search finds a document',
      'no tree row carries a mark',
      'the status bar and breadcrumb name no branch',
      'Git, Push, Summary and Commit are absent',
      'the Pull request row opens nothing',
      'no .git folder appeared',
    ],
  );
}
