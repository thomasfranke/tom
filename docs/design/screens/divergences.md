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
| The tree's top level | the space's children | the space itself as the first row, everything nested under it |
| A conflict in the source pane | offers nothing | `Accept Current Change · Accept Incoming Change · Accept Both Changes` above the `<<<<<<<` line, where VS Code puts them ([conflict-in-source](desktop/git-conflict/conflict-in-source-dark.svg)) |
| ~~The formatting bar with the git column open~~ | closed: the last group collapses into a `⋯` at the 5th group's own slot, so the thirteen that stay keep the boards' x | all seventeen, the last ending at 852 — *over* a mode control that starts at 835. **The boards are the ones to correct**, and the `⋯` has none yet ([not drawn yet](not-drawn-yet.md)) |
| The right column's gutter | a line, no grip | the grip, because the width is the reader's — the app fixes that column at 280 |

## The board is stale

| Where | The app | The boards |
|---|---|---|
| A conflict's tint band | starts 44 from the pane's edge | `git-conflict/` draws 80, `git-diff/` 44 — and 44 is the maintainer's answer |
| The source pane's gutter | `C` beside the line a conflict opens on | no mark; the gutter was built after the page was drawn, and [conflicted-document](../../product/editor/conflicted-document/doc.md) asks for it |
| `Clone from URL` on Home | carries an `M3` chip | no chip; a control the app ships is a control the board draws |
| `Open preferences.json` | `text_muted` and unavailable | `text_secondary`; what it opens is a tab from outside the tree and there is no tab strip yet ([not-drawn-yet](not-drawn-yet.md)) |
| The language row | carries a `›` | no affordance at all, on a row that opens a menu |

## The boards disagree with each other

Everything the reader cannot drag is the same on every board, so these are
one board being stale rather than a choice ([`measurements.md`](measurements.md)).

- **The search field to the `This file · Whole space` switch** is 8 on `git-commit/committing` and 12 on all three `search/` boards. The app draws 12.
- **The status bar's segments** are ~38 apart on `editor/merged-rows` and ~55 on `git-commit/committing`. The app draws 32.
- **The left gutter's grip sits at y=481** on every board where the explorer is open, and the right one at 453, which is where half the container band is. The app centres both.

## Not a divergence

- **A column's width, and whether it is open.** Both are the reader's, so boards differ on them deliberately ([`measurements.md`](measurements.md)).
- **The tabs row, and the `Pull request` row in the tree.** Neither is built ([`not-drawn-yet.md`](not-drawn-yet.md)).
- **What a fixture happens to hold** — file names, commit messages, the document on screen.

---

*See also: [screens/](README.md) · [measurements.md](measurements.md) · [not-drawn-yet.md](not-drawn-yet.md)*
