/// Planned, not written: the terminal. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedTerminal() {
  plannedScenario(
    'Ends the terminal shell with the space',
    group: 'Workspace',
    submenu: 'Terminal',
    describe:
        'Another space gets a fresh terminal named for it; a folder with no '
        'repository opens at the folder.',
    survey: '4-35',
    rule: 'workspace/terminal/doc.md — one shell per space, ended with it.',
    control: 'the Terminal tab',
    fixture: 'docs-in-repo, repo-itself, not-a-repository',
    steps: <String>[
      'open the terminal in one space and run a command',
      'go to another space: a fresh terminal named for it',
      'a folder with no repository opens its terminal at the folder',
    ],
  );
  plannedScenario(
    'Keeps the terminal in its place and gives the window its keys',
    group: 'Workspace',
    submenu: 'Terminal',
    describe:
        'cd leaves the head alone, Cmd-J from inside closes the panel and '
        'the shell still answers, exit and the next key, Ctrl-C, Cmd-K.',
    survey: '4-36',
    rule: 'workspace/terminal/doc.md — the window keeps its Cmd keys.',
    control: 'the terminal view and Cmd-J, Cmd-K',
    fixture: 'docs-in-repo',
    steps: <String>[
      'cd elsewhere: the panel head keeps the repository name',
      'Cmd-J from inside closes the panel and the shell still answers',
      'exit, then the next key starts a shell again',
      'Ctrl-C interrupts a running command',
      'Cmd-K still focuses search',
    ],
  );
  plannedScenario(
    'Says the shell would not start',
    group: 'Workspace',
    submenu: 'Terminal',
    describe: 'A terminal repository whose shell does not exist.',
    survey: '5-15',
    rule: 'workspace/terminal/doc.md — a shell that cannot start is said.',
    control: 'the Terminal tab',
    fixture: 'docs-in-repo with terminalRepositoryProvider overridden',
    steps: <String>[
      'open the Terminal tab',
      'it says The shell would not start',
    ],
  );
}
