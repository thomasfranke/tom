/// Planned, not written: the git column and the changes list. Survey ids are
/// the roadmap's (`test-roadmap.md`, phase 4/5).
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedGitLocal() {
  plannedScenario(
    'Says everything the changes list should say',
    group: 'Git',
    submenu: 'Local',
    describe:
        'Adds to the two commit scenarios: sections, counts, letters, the '
        'folder under a name, unticking and Unstage all asked of git, a '
        'description read back from the log, tabs surviving a commit.',
    survey: '4-01',
    rule:
        'git-workflow/commit/the-changes-list/doc.md — each row names its '
        'file, folder and state letter; the counts say how much is staged.',
    control: 'the row checkbox, Unstage all, Stage all, the description box',
    fixture: 'docs-in-repo',
    steps: <String>[
      'the sections and their counts are STAGED and CHANGES',
      '1 of 2 staged and Commit to main say the same thing',
      'unticking a row unstages it, and git agrees',
      'Unstage all empties the staged section, and git agrees',
      'a description is read back from git log',
      'the open tabs survive the commit',
    ],
  );
  plannedScenario(
    'Puts back the two other shapes of a row',
    group: 'Git',
    submenu: 'Local',
    describe:
        'Adds to Puts one file back from the changes list: a staged new file '
        'is deleted rather than reset, and a deleted file closes its tab.',
    survey: '4-02',
    rule:
        'git-workflow/commit/the-changes-list/doc.md — what the arrow on a '
        'row puts back depends on what the row is.',
    control: 'the arrow at the end of a staged-new row and of a deleted row',
    fixture: 'docs-in-repo (a file added and staged; a tracked file deleted)',
    steps: <String>[
      'a staged new file is deleted by its arrow, after asking',
      'a deleted file is restored, and its open tab closes',
    ],
  );
  plannedScenario(
    'Says it is committing while the commit runs',
    group: 'Git',
    submenu: 'Local',
    describe:
        'A pre-commit hook that sleeps holds the commit in flight: the button '
        'says Committing, the staged rows are dimmed and inert, no bar is '
        'drawn; a hook that refuses is named.',
    survey: '4-03',
    rule:
        'git-workflow/commit/confirming/doc.md — a commit in flight says '
        'so on its own button, and touches nothing else.',
    control: 'Commit to <branch> while it runs',
    fixture: 'new: docs-with-slow-hook (a sleeping pre-commit hook)',
    steps: <String>[
      'stage a document and describe the commit',
      'press Commit: the button says Committing and the staged rows dim',
      'the dimmed rows take no press',
      'the commit lands once the hook ends',
      'a hook that refuses is named in the git column',
    ],
  );
  plannedScenario(
    'Opens a deleted file that is not a document',
    group: 'Git',
    submenu: 'Local',
    describe:
        'A deleted YAML or text file opens its last committed version, '
        'read-only, every line removed, its tab struck through.',
    survey: '4-04',
    rule:
        'git-workflow/commit/opening-a-change/doc.md — a file gone from '
        'disk is read at HEAD, read-only.',
    control: 'the name of a deleted non-markdown row in the changes list',
    fixture: 'docs-changed-beside (the step deletes mkdocs.yml)',
    steps: <String>[
      'delete the file outside the app and open its row',
      'the tab says (deleted) and the buffer is read-only',
      'every line is marked removed',
      'undo, redo and formatting are unavailable',
    ],
  );
  plannedScenario(
    'Edits a text tab, and calls a file that is not UTF-8 binary',
    group: 'Git',
    submenu: 'Local',
    describe:
        'Adds to Opens a change from beside the space: the YAML tab is edited '
        'and saved with its toolbar dim, Source and Split on a deleted '
        'document, a Latin-1 file opens as binary.',
    survey: '4-05',
    rule:
        'git-workflow/commit/opening-a-change/doc.md — any file opens; one '
        'that is not UTF-8 is binary.',
    control: 'the source pane of a text tab; the mode control',
    fixture: 'docs-changed-beside',
    steps: <String>[
      'edit the YAML tab and save it, the toolbar stays dim',
      'Source and Split on a deleted document',
      'a Latin-1 file opens as a binary file',
    ],
  );
  plannedScenario(
    'Sees what changed outside after Reload',
    group: 'Git',
    submenu: 'Local',
    describe:
        'A file changed by another program appears in the changes list after '
        'the git menu Reload, and not before.',
    survey: '4-06',
    rule: 'git-workflow/git-menu/doc.md — Reload reads the repository again.',
    control: 'Reload in the git menu',
    fixture: 'docs-in-repo',
    steps: <String>[
      'change a tracked file outside the app: the list does not move',
      'Reload: the row appears with its letter',
    ],
  );
  plannedScenario(
    'Asks for the right folder from every way out to the desktop',
    group: 'Git',
    submenu: 'Local',
    describe:
        'Open in terminal and Open repository in Finder ask for the '
        'repository root, a binary tab for its file; the menu closes on '
        'Escape.',
    survey: '4-07',
    rule: 'git-workflow/git-menu/doc.md — three ways out to the desktop.',
    control: 'Open in terminal, Open repository in Finder, Reveal on a binary',
    fixture: 'docs-changed-beside (a space below the repository root)',
    steps: <String>[
      'Open in terminal asks for the repository root, not the space',
      'Open repository in Finder asks for the repository root',
      'Escape closes the menu with nothing asked',
    ],
  );
  plannedScenario(
    'Refuses a commit in words',
    group: 'Git',
    submenu: 'Local',
    describe:
        'Every way a commit refuses is a sentence: no identity, unmerged '
        'paths, a hook (git client integration 1-07 is the layer below).',
    survey: '1-07/4-03',
    rule:
        'git-workflow/commit/the-message/doc.md — a commit that cannot '
        'happen says why where it was asked.',
    control: 'Commit to <branch>',
    fixture: 'docs-in-repo with no user.name in its config',
    steps: <String>[
      'with no identity set the commit says so and nothing is made',
      'a staged merge conflict refuses the commit in words',
    ],
  );
}
