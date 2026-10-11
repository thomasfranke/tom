/// Planned, not written: links and wikilinks. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedLinks() {
  plannedScenario(
    'Follows the links a document carries',
    group: 'Editor',
    submenu: 'Links',
    describe:
        'A relative link opens its document; one climbing out and one in '
        'another scheme do nothing; https and mailto reach the browser; a '
        'broken one; an image.',
    survey: '4-42',
    rule: 'editor/markdown-preview/doc.md — links in the preview.',
    control: 'links of every kind in the preview',
    fixture: 'new: docs-with-plain-links',
    steps: <String>[
      'a relative link opens its document',
      'a link climbing out of the space does nothing',
      'a link in another scheme does nothing',
      'https and mailto are handed to the browser',
      'a broken relative link says so',
      'an image is drawn',
    ],
  );
  plannedScenario(
    'Finishes the rest of a wikilink',
    group: 'Editor',
    submenu: 'Links',
    describe:
        'No offer inside code; arrows, Escape and a click in the offer; a '
        'shared name written by its path; anchors that name nothing; a '
        'repeated heading; a missing link clicked.',
    survey: '4-53',
    rule: 'wikilinks/doc.md — the offer and the three states.',
    control: 'the [[ offer and the links in the preview',
    fixture: 'docs-with-wikilinks (more lines added)',
    steps: <String>[
      'no offer inside a code span',
      'the arrows move and Enter accepts',
      'Escape closes the offer',
      'a click accepts a row',
      'a shared name is written with its folder',
      'an anchor that names nothing opens the document at the top',
      'a repeated heading goes to the first one',
      'a missing link pressed offers to create it',
    ],
  );
}
