/// Planned, not written: the Commands panel. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedCommands() {
  plannedScenario(
    'Reads a command row in every state',
    group: 'Workspace',
    submenu: 'Commands',
    describe:
        'The count, a second press closes, an answered exit draws no mark, '
        'the cross and exit N, Printed nothing, the panel stays shut after '
        'a failure, its gutter limits.',
    survey: '4-39',
    rule:
        'workspace/commands/doc.md — every command is written down, an '
        'answered exit is not a failure.',
    control: 'a command row, the panel toggle and gutter',
    fixture: 'docs-in-repo, docs-unreachable-remote',
    steps: <String>[
      'the count matches what ran',
      'a second press of the toggle closes the panel',
      'an answered non-zero exit draws no mark',
      'a failed command draws the cross and exit N',
      'a command with no output says Printed nothing',
      'a failure does not open the panel by itself',
      'the panel gutter stops at its limits',
    ],
  );
  plannedScenario(
    'Copies a command to the clipboard',
    group: 'Workspace',
    submenu: 'Commands',
    describe:
        'The copy glyph of a command row writes the line to the '
        'clipboard through a recording seam (decision T11).',
    survey: '5-20',
    rule: 'workspace/commands/doc.md — a command can be copied.',
    control: 'the copy glyph on a command row',
    fixture: 'docs-in-repo',
    steps: <String>[
      'press the copy glyph of a row',
      'the recorded clipboard holds the command line',
    ],
  );
}
