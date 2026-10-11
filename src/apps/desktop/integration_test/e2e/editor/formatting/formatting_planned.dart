/// Planned, not written: the formatting bar. Survey ids are the roadmap's.
library;

import '../../../support/planned.dart';

/// Declares the plans of this menu.
void plannedFormatting() {
  plannedScenario(
    'Writes every kind of markdown from the bar',
    group: 'Editor',
    submenu: 'Formatting',
    describe:
        'The twelve buttons never pressed; a wrap around a selection and '
        'off again; a prefix on every selected line; five groups, seventeen '
        'buttons; undo and redo dim with nothing to act on. The keys are '
        'GitHub and VS Code (decision 61), link on Cmd-Shift-K (65).',
    survey: '4-44',
    rule:
        'editor/formatting-shortcuts/doc.md — a button or a key writes the '
        'same text, and a second press takes it off.',
    control: 'each formatting button and its key',
    fixture: 'docs-in-repo',
    steps: <String>[
      'select a word and press bold, italic, strikethrough, code',
      'press each again: the wrap comes off',
      'select three lines and press each list, quote and alert',
      'insert a table, a rule, a link, an image, a footnote, a code fence',
      'every button has its key and the key writes the same text',
      'undo and redo are dim with nothing to act on',
    ],
  );
  plannedScenario(
    'Folds the last group of the bar when the row is short',
    group: 'Editor',
    submenu: 'Formatting',
    describe:
        'The ellipsis is present, its strip holds the group, a button in it '
        'writes, a click outside closes it.',
    survey: '4-45',
    rule:
        'editor/formatting-shortcuts/doc.md — the last group collapses '
        'into a strip.',
    control: 'the More formatting button',
    fixture: 'docs-in-repo (a window narrow enough)',
    steps: <String>[
      'a narrow window folds the last group',
      'the ellipsis opens the strip',
      'a button in the strip writes',
      'a click outside closes the strip',
    ],
  );
  plannedScenario(
    'Dims the whole bar in preview, and lands a list where asked',
    group: 'Editor',
    submenu: 'Formatting',
    describe:
        'All fifteen buttons read dim; the list on the marked line, and on '
        'the disk. Adds to Formats a document from the bar above it.',
    survey: '4-51',
    rule: 'editor/formatting-shortcuts/doc.md — the bar is for the source.',
    control: 'the formatting buttons in Preview',
    fixture: 'docs-in-repo',
    steps: <String>[
      'in Preview every button is dim',
      'a list lands on the marked line',
      'saved, the disk holds the list',
    ],
  );
}
