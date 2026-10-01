# Decision 3 — The editor is source + preview; no WYSIWYG

**Status:** accepted

## Decision
Plain-text editing with syntax highlighting, preview alongside (split view).

## Rationale
Removes Flutter's largest technical risk (rich-text editors); a developer audience does not require WYSIWYG; keeps the project free of AGPL packages.

## What this permits
Buttons and keyboard shortcuts that **insert** syntax (`Cmd+B` wrapping a selection in `**`, a list button, a link dialog) are conveniences rather than WYSIWYG, and they are welcome — GitHub and Obsidian both offer them while showing the source. The line is visibility: the moment the `**` disappears from the screen and the text merely *looks* bold, this decision has been broken.

## Revisit when
The semi-technical persona proves essential to the business.
