# Divergences

Where the app still draws something other than what the board draws,
measured board against render at 1440×900.

**Normative: the board is right and the app is the bug**, except the rows
marked *the board is stale* — those were settled against the board afterwards
and the Penpot file has not caught up. A row here is work, not a note.

Measured with `tom e2e <name> --board`, which runs the real app at the board's
own 1440×900 so the two crop to the same rectangle — scaling either side makes
every number taken off the comparison a lie.

## The app is the bug

| Where | The app | The boards |
|---|---|---|
| ~~The tree's top level~~ | moved to *the board is stale* — the maintainer chose the app (revised 2026-10-08) | — |
| ~~A conflict in the source pane~~ — closed: the maintainer's call is the app, and `Conflict in source` was redrawn to it ([Penpot backlog](../penpot-backlog.md)) (revised 2026-10-08) | the three choices **on** the `<<<<<<<` line, 15 after the marker — `re_editor` 0.10 forces one height per line and has no view zones, so a line of its own is not drawable without a fork | `Accept Current Change · Accept Incoming Change · Accept Both Changes` on a line of their own above it, where VS Code puts them ([conflict-in-source](desktop/git-conflict/conflict-in-source-dark.svg)). The maintainer's call: the board, or the editor |
| ~~The pull request's actions~~ | closed: the boards now carry the one action the app does | — |
| The pull request's status row | five states: ready, uncommitted, not pushed (with `Push`), no title and *nothing to propose* | four drawn; *nothing to propose* has no board ([Penpot backlog](../penpot-backlog.md)) |
| ~~The formatting bar with the git column open~~ | closed: the last group collapses into a `⋯` at the 5th group's own slot, so the thirteen that stay keep the boards' x | all seventeen, the last ending at 852 — *over* a mode control that starts at 835. **The boards are the ones to correct**, and the `⋯` has none yet ([not drawn yet](not-drawn-yet.md)) |
| ~~The right column's gutter~~ | closed: the column is dragged from its gutter like the left one | the gutter, because the width is the reader's |
| ~~`Up to date with origin/main`, the `new` badge~~ | closed: the column's foot says where a healthy branch stands, `Up to date with origin/main` among them (revised 2026-10-08); ~~the `new` badge~~ (removed 2026-10-08: the badge does not exist) | — |
| ~~The open document's name~~ | closed: the tab strip names it | the tab |
| `Unsaved` in the row above the document | still drawn, beside the tab's dot | only the tab's dot. Kept because it is also where a refused save says `Not saved`, which a dot cannot |
| ~~`Stage all`~~ — closed 2026-10-09: both `Git` variants of the `Git panel` master carry it, the copies swept (hidden where `CHANGES` is not drawn); waits on the export | at the head of `CHANGES` | no action there — only `Unstage all` on `STAGED`. Without it the one way to stage everything at once would be gone, since the `All` box went with the single list |

## The board is stale

**All closed in Penpot on 2026-10-08** — every row below was checked against the model and the boards now draw what the app does. They wait only for the final export; the rows stay until it lands, struck through.

| Where | The app | The boards |
|---|---|---|
| ~~A conflict's tint band~~ — the boards draw 44 | starts 44 from the pane's edge | `git-conflict/` draws 80, `git-diff/` 44 — and 44 is the maintainer's answer |
| ~~The source pane's gutter~~ — `C` drawn | `C` beside the line a conflict opens on | no mark; the gutter was built after the page was drawn, and [conflicted-document](../../product/editor/conflicted-document/doc.md) asks for it |
| ~~`Clone from URL` on Home~~ — no chip on either side | carries an `M3` chip | no chip; a control the app ships is a control the board draws |
| ~~`Open preferences.json`~~ — the app opens it now, and the board's `text_secondary` is right | `text_muted` and unavailable | `text_secondary`; what it opens is a tab from outside the tree and there is no tab strip yet ([not-drawn-yet](not-drawn-yet.md)) |
| ~~The language row~~ — the boards draw it as a select with its chevron | carries a `›` | no affordance at all, on a row that opens a menu |
| ~~The search field's chevron~~ — swept | none: the field runs 8 in from both edges of the column, the replace box under it on the same edges, and `⌥⌘F` (`Ctrl+H` off macOS) opens it — the maintainer's call, 2026-10-08 ([replacing](../../product/search/replacing/doc.md)) | `searching-replace` draws a chevron and both boxes from x 34, 220 wide |
| ~~The `Diff` chip~~ — swept | on: `accent_soft` fill, `accent` outline and label — a chosen control; off: no fill, `border_strong` outline, `text_secondary` label — a control at rest. The maintainer's call, 2026-10-08 | on, as the app; off, a `border_strong` outline and a `text_muted` label, which is Disabled's ink on a chip that can always be pressed (`committing`, against `comparing` for on) |
| ~~The tree's top level~~ — redrawn in the `Explorer` master (the root row removed, every row one level out; the six copies on `17` that had moved their tree for the reason line were set by hand) | the space's children at the top level, no root row — the maintainer's call, 2026-10-08 | the space itself as the first row, everything nested under it |
| The account button on `Closing the space — unsaved work` | the person's initials | an empty disc in both themes, where every other board reads `AS` |
| ~~The explorer's `⋮`~~ — the master and the open menus moved | 15.5 from the island's edge, the `+` 26 before it — the git column's number, the maintainer's call, 2026-10-08 | `explorer-menu` and `new-document` draw it at 20.5 and the `+` at 46.5 |

## The boards disagree with each other

Everything the reader cannot drag is the same on every board, so these are
one board being stale rather than a choice ([`measurements.md`](measurements.md)).

- ~~The search field to the switch, the status bar's segments, the grips' y~~ — closed by the 1b restyle: every board now places the three from the same masters, 6 between field and switch, 16 between segments, and no grip drawn at all.
- ~~**A column's `⋮`**: the explorer's centre is 20.5 from its island's edge, the git column's 15.5~~ — closed 2026-10-08: the maintainer chose 15.5 for both, so the explorer's boards are the stale ones (above). Each menu still runs past its `⋮` by its own board's number, 5 and 6.5.

## Not a divergence

- **A column's width, and whether it is open.** Both are the reader's, so boards differ on them deliberately ([`measurements.md`](measurements.md)).
- ~~**The `Pull request` row in the tree.** Not built ([`not-drawn-yet.md`](not-drawn-yet.md)); the tabs row is.~~ Built, always drawn in a repository, unavailable with its reason (revised 2026-10-08).
- **What a fixture happens to hold** — file names, commit messages, the document on screen.

---

*See also: [screens/](README.md) · [measurements.md](measurements.md) · [not-drawn-yet.md](not-drawn-yet.md)*
