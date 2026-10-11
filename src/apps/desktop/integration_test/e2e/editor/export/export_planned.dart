/// Planned, not written: export. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedExport() {
  plannedScenario(
    'Exports a document with its images',
    group: 'Editor',
    submenu: 'Export',
    describe:
        'HTML is one file with styles and images inside; a missing image '
        'leaves its alt text.',
    survey: '4-43',
    rule: 'export/doc.md — an export is self-contained.',
    control: 'Export as HTML from the tab menu',
    fixture: 'docs-in-repo (reference/logo.svg and a missing image)',
    steps: <String>[
      'export a document with an image as HTML',
      'the file holds the image inside it',
      'a missing image leaves its alt text',
    ],
  );
  plannedScenario(
    'Says where the export went, and what the file holds',
    group: 'Editor',
    submenu: 'Export',
    describe:
        'The band names the folder and Reveal asks for it; it goes when the '
        'next thing happens; the HTML is one file; a tab not on screen '
        'exports its own unsaved edit.',
    survey: '4-52',
    rule: 'export/doc.md — the buffer is exported and the band says where.',
    control: 'Reveal in the export band, the tab menu of another tab',
    fixture: 'docs-in-repo',
    steps: <String>[
      'the band names the folder',
      'Reveal asks the file manager for it',
      'the band goes at the next action',
      'a tab not on screen exports its own unsaved edit',
    ],
  );
}
