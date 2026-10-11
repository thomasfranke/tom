/// Planned, not written: the tab strip. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedTabs() {
  plannedScenario(
    'Presses the other controls of the tab strip',
    group: 'Editor',
    submenu: 'Tabs',
    describe:
        'A double click and a save each keep a tab; the close closes a '
        'clean one and the last leaves the empty area; the menu rows; the '
        'bar acts on the chosen tab; a text tab menu is Close tab alone.',
    survey: '4-50',
    rule: 'editor/tabs/doc.md — preview tabs, kept tabs, the menu.',
    control: 'the tab, its close, its right-click menu',
    fixture: 'docs-in-repo, docs-changed-beside',
    steps: <String>[
      'a double click keeps the tab',
      'a save keeps the tab',
      'the close closes a clean tab',
      'closing the last leaves Choose a document in the explorer',
      'the menu rows export and close',
      'the formatting bar acts on the chosen tab',
      'a text tab offers Close tab alone',
    ],
  );
  plannedScenario(
    'Keeps every tab its width when more are open than fit',
    group: 'Editor',
    submenu: 'Tabs',
    describe: 'The strip scrolls and no tab shrinks.',
    survey: '5-23',
    rule: 'editor/tabs/doc.md — a tab never shrinks.',
    control: 'the tab strip',
    fixture: 'docs-in-repo (many documents)',
    steps: <String>[
      'open more documents than the strip holds',
      'the strip scrolls',
      'every tab keeps its width',
    ],
  );
}
