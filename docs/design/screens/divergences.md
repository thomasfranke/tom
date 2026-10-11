# Divergences

Where the app draws something other than what the Penpot file draws.

**Normative: the board is right and the app is the bug.** A row here is work,
not a note. Where the maintainer chose the app instead, the board was redrawn
and the row left this file.

- A divergence is measured, not eyed: `tom e2e <name> --board` runs the real app at the board's own 1440×900, so a whole window crops to the same rectangle — scaling either side makes every number taken off the comparison a lie.
- A states board is held to the pixel twice: the app's frame cropped to the rectangle the board records (`x, y · w × h`), and the widget rendered alone at that size.
- **The exports on disk are the record of the boards named below** — a measurement is taken off them, never off the Penpot file's tab ([Penpot backlog](../penpot-backlog.md)).

## The app is the bug

| Where | The app | The boards |
|---|---|---|
| A commit that worked, on a branch with no upstream | the band quotes the message and offers no `Push` (the column's `Push` publishes) | the band offers `Push` there too — the press publishes, `--set-upstream origin` (`Git - Commit`, `Commit succeeded`) |
| The conflicted documents while a merge is open | among the other changes, counted as `N documents to resolve` under the commit button | a section of their own at the head of the list, `TO RESOLVE` with its count (`Git - Conflict`) |
| The foot of the git column while a merge is open | the branch's standing, as at any other time | `Merging origin/main`, and `Merging origin/main — ready to commit` once nothing is left to resolve (`Git - Conflict`) |

## DRAFT — measured at stage 8.6, awaiting the maintainer

Measured on the dark exports against `tom e2e <scenario> --board` frames, at 1440×900, mid-heights only. Every row is a finding, not a decision: the last column says which side is probably right. A face that differs on purpose (the terminal's shell font, Public Sans in the page's copy) is not listed. Light was not measured.

### About and the update check (`about-updates/`)

| Where | The app | The boards |
|---|---|---|
| The dialog's mark | a teal tile with a `T`, 56 square | the brand icon — white tile, document with the node (`About TOM`, the update states). The app is the bug |
| The facts (`Version`, `Platform`, `License`) | values right-aligned to the card's content edge (x 895) | values left-aligned in a column that starts at x 640, 120 in from the card's edge. The app is the bug |
| The dialog's vertical rhythm | 426 tall; facts rows 2 lower, divider 4 lower, the `Check for updates` button 40 tall, 59 between the two buttons' tops | 432 tall; buttons 48 tall plus the stroke, 56 between tops. The app is the bug |
| The dialog's inset | content starts 25 in from the outer edge | 24 in from the outer edge, stroke included. The app is the bug |
| The `UPDATES` caption | none — the section opens on the sentence | an uppercase 9 px caption in `text_tertiary` (`#6E737C`) above the sentence, in every state. The app is the bug |
| `Check for updates` when the build is up to date | the filled accent button | the secondary (outlined) button; the filled one is `Update and restart`. The app is the bug |
| `Close` | `#DFE1E5`, bold, 41 wide | `#A8ADB6` (`text_secondary`), regular, 38 wide. The app is the bug |
| The settings popover — its size | 532 tall, top at y 48, content inset 16 left and 17 right, right edge at x 1392 | 485 tall, top at y 38, inset 13 and 14, right edge at x 1394. The app is the bug |
| The popover's controls | the language select and both `Open …json` buttons 40 tall; the two checkboxes 30 apart | 32 and 34 tall; 26 apart. The app is the bug |
| The popover's glyphs | no document glyph before `Open git-approvals.json` / `Open preferences.json`; the language select ends in a right-pointing chevron | the document glyph before both; a down chevron on the select. The app is the bug |
| The gear while the popover is open | no ring | a ring around the gear (its selected face), with the update dot at its corner |
| The gear's dot | centre about 3 px left of the board's, x 1386.5 against 1390 | x 1390. The app is the bug (one reading; the dot and the ring move together) |
| The status bar's notice | the sentence alone | a 6 px accent dot, then the sentence, 12 px apart. The app is the bug |

### The account (`account/`)

| Where | The app | The boards |
|---|---|---|
| The popover's height | 352 | 332, on both the page's board and the states board — they agree. The app is the bug |
| A hint's line height | 16 (`TOM uses what git and gh already have…`, the repository's note) | 14, in all three hints. The app is the bug |
| The rights block | link to column heads 24, heads to dashes 31, dashes to note 24 | 28, 24 and 20. The app is the bug |
| The head of the popover | `COMMITS AS` 1 lower, the name 2 lower than the board | the name at 23 below the caption, 1 less than the app. The app is the bug (rounds to the same cause as the line above) |

### The Commands panel and the terminal (`commands-terminal/`)

| Where | The app | The boards |
|---|---|---|
| A panel's stroke, app-wide | `#2B2D31` (the three columns, the bottom panel, the popovers) | **Closed — a measurement artefact, not a divergence** (stage 12.5, read off `committing-dark.svg`): every board authors the stroke as `rgb(43,45,49)`, which is `#2B2D31`, the app's colour; it is a 1 px stroke centred on the island's edge, the frame clips half of it, and the surviving half renders at 50 % over `#1E1F22`, which reads `#242529`. Nothing to change |
| The tabs of the bottom panel | 19 between `Commands` and `Terminal`, the label 67 wide, its text 1 px higher | 14, 65 wide. The app is the bug |
| The count / the shell's name | `N this session` starts 148 after `Terminal`; `zsh · path` starts 33 after it | 33 and 13 — both start right after the tabs. The app is the bug |
| The close mark | 8 × 9, centred 24 from the panel's right edge | 10 × 10, centred 18. The app is the bug |
| The terminal's line pitch | 12 at a 7.2 advance | 14.4 at the same advance. The face is the shell's own (Menlo against Plex Mono) and not a finding; the line height is. The app is probably the bug |

### Git approvals (`git-approvals/`, `git-approvals-the-setting/`)

| Where | The app | The boards |
|---|---|---|
| The popover's `GIT COMMANDS` section | the three-way switch, its note and `Open git-approvals.json` as the popover rows above, with the same sizes and spacing differences | the same section on `git-commands-automatic`; the switch itself (three segments, 28 tall, the selected one filled) matches. Only the rows above apply |
| The waiting row | no tint | a 24-tall `#15302A` band across the row. The app is the bug |
| The row's `Run` / `Always allow` / `Deny` | right edge 54 in from the panel's edge (the duration column's) | 14 in; and the `waits for the one above` text sits there too. The app is the bug |
| A plan's head to its first row | 21 | 24. The app is the bug |
| The waiting row at the foot of the list | cut by the panel's bottom edge | never cut — the list scrolls the waiting row into view. The app is the bug |
| The git column while the read waits | `Asking git…` at the top of the column | `Waiting for your approval to read the repository.` 60 below the column's head. The app is the bug |
| The column's `Git` tab | `History` starts 45 after `Git` | 62 after: the `Git` tab keeps room for its count badge even when there is none. Two readings; the board is probably stale |
| The column's foot after a denied read | a warning glyph, `Reload` in white, bold | no glyph, `Reload` in the accent. Read by eye on the cropped image, not by pixels: confirm before acting |

### The explorer's menus (`workspace-tree/`)

| Where | The app | The boards |
|---|---|---|
| The `⋮` menu's place and rhythm | 2–3 lower; the first row's text 3 lower, the dividers 2 lower; glyph and label 1–2 right, each row's ink 2–3 wider | the numbers of `explorer-menu`: first text at 85, dividers at 110 and 179. The app is the bug (the board's own overhang is the stale one in the section below) |
| The name field | 24 tall, the invalid stroke `#EF7B76`, right edge 8 in from the column | **Closed for the stroke and the height — the same artefact** (stage 12.5, `naming-a-new-entry-states-dark.svg`): the board authors `rgb(239,123,118)` on a 24-tall rectangle with a centred 1 px stroke, which splits into two half-intensity pixels (`#864C4C`, `#844A49`) and measures 26. The app's `removed` colour and 24 already match; the right edge's 8 against 7 is the same half-pixel |

## DRAFT — measured at stage 12.6 (light)

The five pieces of 8.6 measured in the **light** exports against `tom e2e <scenario> --board` frames (`TOM_E2E_THEME=light`, 1440×900), plus a dark re-measure of the constants stage 12.1/12.2 tuned after their e2e. A stroke is judged by the SVG's authored colour, never by the rendered pixel (a 1 px stroke centred on an edge renders at half intensity). Rows that equal the dark result are not repeated; every text, caption, link, check and tint colour measured in light matches its role (`text_primary` `#1F2328`, `text_secondary` `#4E5561`, `text_tertiary` `#7E7A72`, accent `#178F71`, button stroke `#C4C0B8`, card/divider `#DAD7D1`, waiting row `#D4EDE2`).

### Colour roles (light)

| Where | The app | The boards |
|---|---|---|
| The terminal's surface | `#FFFFFF` with `#000000` text (the pty's own light palette) | `#1E1E1E` with `#CCCCCC` text, in the light export too (`the-bottom-panel-states-light`, Terminal cards). The app is the bug |
| The language select in the settings popover | the popover's own fill `#F6F5F1` with a `#C4C0B8` stroke | filled `#ECEAE5` (the field fill, the same as the theme track) and no authored stroke (`preferences-light`, rect at x 1128, y 130). The app is the bug. **Closed (12.7)**: the board does author a stroke after all — `border` (`#DAD7D1` light, `#2B2D31` dark) on a `surface_sunken` fill, the theme track's own; the select wears both roles in both themes |
| `Reload` at the foot of the git column after a denied read | `#1F2328` (primary text), bold, after a warning glyph; the sentence starts at x 1184 | `#178F71` (accent), no glyph; the sentence starts at x 1166 (`manual-a-read-denied-light`). Confirmed by pixels now (the 8.6 row was read by eye). The app is the bug. **Closed (12.7)**: dark says the same (`#4FD1B0`, weight 500, no glyph); the sentence starts at x 1166, `Reload` is accent at 500, and the words sit at y 840 as the board's (they were 2 low) |

### Geometry (light; the dark twin noted where it was seen)

| Where | The app | The boards |
|---|---|---|
| The settings popover's dividers | span the content, x 1127..1380 (254) | span the panel, x 1126..1391 (266), seen in dark and light. The app is the bug. **Closed (12.7)**: the SVG authors 278 (x 1115..1392, stroke to stroke, in both themes and on every board that draws the popover), not 266; the app's two rules now run 1115..1392 |
| `Open git-approvals.json` / `Open preferences.json` | glyph plus label 150 × 12, starting 5 in from the board's start (x 1179) | 153 × 13, starting x 1174; the glyph or the gap is 2 to 3 smaller in the app (measured in dark; the app tuned these after its e2e). **Closed (12.7)**: the two rows read the other way round from the text — the board is the wider one. Now 153 × 13 (first button) and 145 × 13 against 146 × 13 (second); the label is 11.8 and the gap 7. The first button's start (x 1178 against 1174) is the board's own off-centre drawing: its second button is centred, and so is the app's |
| A divider drawn by the app (About, popover, explorer menu) | lands on a half pixel: two rows (`#EEECE7` and `#E2E0DB` in light; `y 219..220` in dark) | one row, `#DAD7D1` (the authored colour), `y 220`. The app is the bug (a snapped offset). **Closed (12.7)**: `TomRulePainter` rounds a rule's edges to whole device pixels; About (y 454), the popover (y 380 and 446) and the explorer menu (y 110 and 179) are each one row of `#DAD7D1` |
| The About buttons' labels | the label's ink 1 to 2 lower: `Check for updates` top 323, baseline 336 | top 321, baseline 335 (dark and light alike). The app is probably the bug. **Closed (12.7)** in light: `Close` ink top 611 and `Check for updates` 555, both the board's; 4 of room under the label. Dark not re-run |
| The account popover, first block | divider 2 lower (y 124 against 122), the name 1 lower, the whole popover 1 taller (bottom edge 370 against 369); the later blocks are equal | the board draws the state `Not set`, so the identity block may differ by a line style: confirm against a board that shows a name and an email before acting |
| The Commands panel's first row | text top 652, 12 under the header's rule | 655, 15 under it; the 24 pitch after that is equal. The app is the bug. **Open (12.7), not changed**: the list is anchored at its end (`reverse: true`), so a frame with many rows shows whatever phase the scroll stopped at, and a frame with few hangs the rows from the panel's foot — the "first row" of either is no measure of `listTop`. A change was tried, found unprovable and reverted. The real divergence is the anchoring: the board hangs 7 rows from the top |
| A plan's head to its first row | 14 top to top (824 to 838) | 16 (656 to 672). The app is the bug. **Closed (12.7)**: head ink top 822 to the tint at 838, 16, as the board; the head box is 28 with 4 under its words |
| The explorer menu's glyphs and shadow | the glyph 14 wide, the label 1 to the right; the shadow's first rows `#E3E1DC` | 12 wide; `#DCDAD6`. The shadow is lighter in the app (alpha), the glyph size is the app's to move. **Closed (12.7) for the shadow**: the markup says 18 % but the render under the menu is `#BBBAB7` at 2 px, and the app now reaches `#BBBAB7` at the same row with 36 % (light only; dark untouched, not measured). **The glyph is not a finding in this frame**: the app's inks are 11 × 11, 10 × 7, 10 × 11, 11 × 11 against the board's 11 × 12, 11 × 7, 11 × 12, 12 × 12 — within 1, none 14 wide, so the size stays 12 |

### Measured and equal (light and dark)

The About dialog (mark, facts, links, `UPDATES` caption, sentences, both buttons at 48, status of the stroke), the status-bar notice (6 px accent dot, 7 to the sentence) and the gear's dot and ring, the account popover's rights block and every colour, the Commands panel's tabs (1 px), the output card (fill `#ECEAE5`, stroke `#DAD7D1`, text `#4E5561`), the waiting row (`#D4EDE2`, 24 tall, `Run` / `Always allow` / `Deny` at the board's x, no longer cut by the panel's edge), the explorer menu's colours and dividers, the invalid name field (`#CF222E` authored, `#ECEAE5` fill, 24 tall plus the stroke). Dark re-measure of the tuned constants: the button label is 14 (124 and 38 wide, as the board), the caption and sentence rows sit at the board's rows, the status-bar dot is 6 wide at the board's offset with `#4FD1B0`.

### Not measured

The selected row's tint in the Commands panel (no frame of the scenario selects one), the `Update and restart` state (not built), the approvals' dark twin of the rows above (only light was run), `Always allow asked in Manual` and the other question boards (no scenario draws them).

## Drawn and not built

Not a divergence yet — nothing is on screen to disagree — but each is a board
the app owes.

| What | Where it is drawn |
|---|---|
| Git approvals: the popover's `GIT COMMANDS` section, the plan, the waiting row, the dialog, the column's `Out of date` foot | `Git - Approvals` · `Git - Approvals, the setting` |
| The Commands panel on Home | `Home`, `Home — a command waiting` |
| `Open git-approvals.json`, unavailable on Home | `Home`, `Preferences on Home` |
| About, and the update check | `About & Updates` |

## The boards disagree with each other

Everything the reader cannot drag is the same on every board, so these are
one board being stale rather than a choice ([`measurements.md`](measurements.md)).

- **A menu's overhang past its `⋮`**: 5 in the explorer, 6.5 in the git column. Each side follows its own board.
- **The open menus on `Workspace - Tree`** were drawn before the `⋮` moved to 15.5 and have not been checked against it ([Penpot backlog](../penpot-backlog.md)).

## Not a divergence

- **A column's width, and whether it is open.** Both are the reader's, so boards differ on them deliberately ([`measurements.md`](measurements.md)).
- **Syntax colour in the source pane.** The app highlights the source; the boards set every line in `text_secondary`. The boards are a mock that did not colour, not a decision that source is plain.
- **The conflict choices on the `<<<<<<<` line** rather than on a line of their own above it — the editor draws one height per line, and the board was redrawn to the app.
- **The toolbar's buttons as overrides.** On the screens they are children of the `Document` master wearing a colour override, not instances of `Toolbar button`; the two carry the same inks.
- **A pull request's status row with no glyph** sets its sentence 16 in, where a notice band's sits 19 — a status row is not a band.
- **The account button is a 24 disc**, as `controls.md` says; the board's 22 inside a ring went with the ring. Awaiting the maintainer's confirmation.
- **What a fixture happens to hold** — file names, commit messages, the document on screen.

---

*See also: [screens/](README.md) · [measurements.md](measurements.md) · [not-drawn-yet.md](not-drawn-yet.md)*
