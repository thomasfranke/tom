# Penpot backlog

What is waiting in the Penpot file, written down while the plugin could not
reach it (2026-10-08). Work it top to bottom; strike a line through when its
export is on disk.

**Before any write:** `penpot.currentFile.name` is `TOM` — the plugin has
connected to another file before — and `penpot.currentPage.name` is the page
meant. Never write and `openPage` in the same call.

## The file itself

| | |
|---|---|
| ~~**Page numbers**~~ | Done, and redone on 2026-10-08 for 25 pages: `00 · Cover`, `01 · Why TOM`, `02 · Brand` … `25 · Prototypes`, every card's marker `Section · NN / 25` and the cover's contents in two columns, thirteen and twelve. The plugin cannot reorder pages, so the maintainer drags the new pages into place — `05 · Components - Shell` sits at the end of the list |
| ~~**Why TOM**~~ | Done: `01 · Why TOM`, from `about.md` — the four options and their trade-off, the bet, the six principles, the cost it accepts |
| ~~**Pages over ten screens**~~ | Split on 2026-10-08 from the maintainer's duplicates, each re-id'd by cloning its card: `08 · Editor` / `09 · Editor - Links & Export`, `18 · Git - Push` / `19 · Git - Pull`, `22 · Workspace - Shell` / `23 · Workspace - Tree`. Export folders `editor-links-export`, `git-push`, `git-pull`, `workspace-shell`, `workspace-tree` |
| ~~**Components - Master**~~ | Reorganised on 2026-10-08, nothing deleted (41 components before and after): one card `Components · master`, the masters section kept and its strays brought inside, and `Shell · 1b` stacked — bars under one another, explorer beside the git panel, the document's four variants 2 × 2 — so the card is 2666 wide. Then split in two, the same day: the 7502-tall card was too long, so `Shell · 1b` moved to `05 · Components - Shell` by **cut and paste in the Penpot app** — the only move that keeps a master's identity; duplicating the page doubled every component instead. 41 components, the six shell masters on their original ids |
| ~~**Brand: the dark icon**~~ | Done: a `dark` row at 16/32/64/128 beside cream and teal, and the dark lockup wears it (`tom-icon-dark.svg`, `brand.py`) |
| **Cards** | ~~The marker~~ done — every card says `Section · NN / 25`. Still to do: the title as `TOM · Name · Section` with the section muted, and a footer `Team-Oriented Markdown · TOM` · `NN/20`. `Site` carries no number |
| ~~**Cover**~~ | Done: no stripe, the light and dark icons over the wordmark, a vector drawing of the app, the contents moved up |
| ~~**Brand in teal**~~ | Done: `#178F71` on light, `#4FD1B0` on dark, the wordmark ink `#1F2328` |
| ~~**Leftover pages**~~ | Gone: the two `(copy)` pages are no longer in the file |

## Boards the app is waiting on

| | Why |
|---|---|
| **Pull request status row** | ~~*commits not pushed*~~ and ~~*no title*~~ drawn and exported. Left: *nothing to propose over the base*, and *one already open*, which waits on the token |
| ~~**Pull request actions**~~ | Done: every board carries the one action, `Open on GitHub`, filled |
| **Conflict actions in source** | The maintainer's call (2026-10-08): the app is right. **Redrawn**: `Conflict in source` (both themes) carries the three actions on the `<<<<<<<` line, 16 right of the marker, and the lines below closed up to the 22 pitch. Not exported |
| **An ambiguous wikilink's candidates** | Drawn on `09 · Editor - Links & Export` as `Ambiguous link`, both themes: a 240-wide menu under the link, a row per document — name, then its folder in `text_muted`. Not exported |
| ~~**Wikilinks**~~ | Done: `wikilinks` and `linking-a-document` on `09 · Editor - Links & Export`, exported |
| **Export** | Drawn on `09 · Editor - Links & Export`: `Exporting from the tab` (the tab's menu) and `Exported` (the band with `Reveal`), both themes, with notes. **Not exported** — the maintainer moved every export to the end of the work. The band is `pull-worked`'s: the 3-point bar, the sentence in `added` at 12.5/500, a pill as wide as its label plus 14 each side, 13 from the edge — **the boards are the reference for every band** (the maintainer's call, 2026-10-08), so the app's `NoticeBandWidget` follows them |
| **Pull request row — states** | Drawn on `17 · Screens: Git - Pull request`, both themes: available, open, and the three unavailable states with their reason. Not exported |
| **The search field on `21 · Screens: Search`** | Its six boards still draw the old field — a chevron left of the box and no `⌘K` — where the `Explorer` master has the keycap and no chevron. Decided 2026-10-08: **no chevron**, replace opens with `⌥⌘F` (`Ctrl+H`). **Swept**: chevron removed and both fields at x 14, 240 wide, on all six. Not exported |
| ~~**Clone by URL**~~ | Done: `clone-from-url`, `cloning`, `clone-failed` on `07 · Screens: Home`, exported |
| ~~**A pull that succeeded**~~ | Done: `pull-worked`, `already-up-to-date` on `19 · Git - Pull`, exported |
| **Comparing — the automatic base** | Redrawn on `14 · Git - Diff`, both themes: the branch is `phase-two`, `Compared to main` sits 12 before the `Diff` chip in `accent` 13/600 (the app's `CompareControlWidget`), and the four notes say what the base is now — the branch it came from, read at the fork point, the chip only toggling. No popover. Not exported |
| **Preferences — three languages** | Redrawn on `20 · Preferences`, both themes: the select reads `System` on all six boards, and `Choosing a language` lists `System` (ticked) · `English` · `Português`; the notes say a three-way theme and name Decision 34. Not exported |
| **Account** | New page `21 · Screens: Account`, both themes, notes: `Account — signed out`, `Account — signed in`, `Choosing an account`, `Account — through SSH`. The account button (initials, never a photo) is in the `Top bar` master at 1402 with the gear at 1368; the house and the gear are outlines at the same size and colour; Home carries both. Not exported — folder `account/` |
| **Commands & Terminal** | New page `22 · Screens: Commands & Terminal`, both themes, notes: `Command log` (with a neutral row), `Command log — output`, `Command log — a failure`, `Terminal`, `Terminal — the shell ended`, `Terminal — would not start`. The bottom-panel toggle is in the `Top bar` master now, between the two column toggles (closed by default; a screen with the panel open shows its `fill`), and the right group runs mode 1046 · left 1278 · bottom 1308 · right 1338 · gear 1368 · account 1402 on every board. Not exported — folder `commands-and-terminal/` |
| **Pull request through gh** | On `17 · Pull request`, both themes, with notes: `Creating it through gh` (`Create pull request` filled over `Open on GitHub instead`), `Already open` (`View #123 on GitHub`), `Nothing to propose` (the action dim). The draft's sample line now says opening goes through gh. Not exported |
| **Gaps closed on 2026-10-08, late** | `18 · Push`: `Push rejected` and `Push failed` gained `Show the command` 8 before their action. `22`: the rejected push's band is `modified`, as the app draws a refusal. `07 · Home`: `Home — the account` (the popover with no repository section). `17`: `Could not open` (the red row with `Show the command`, both ways to open kept). Not exported |
| **Transient states** | `17`: `Creating it — in flight` (`Creating…`, both actions waiting). `21`: `Account — reading` (the git name known, `Asking git and gh who you are…`, five dashes, `Known once the answer is in.`). `22`: `Command log — did not run` (`gh` not installed, a red row reading `did not run`). Not exported |
| **Discarding a file, and the tree** | The `Git panel` master draws a ↶ on every file row, always visible. `11 · Commit`: `Discarding a change`, `Discarding a staged file`, `Deleting a new file` (the dialog, both themes, notes). The `Explorer` master lost the space's root row. Not exported |
| **The site's picture of the app** | The site stays dark only (the maintainer's call), but its drawing of the app predates 1b and the account button — redraw it from today's shell |
| **The preferences band with two actions** | `preferences.json changed on disk…` with `Keep mine` and `Reload` was built without a board — draw it on `20 · Preferences` |
| **The formatting bar's `⋯`** | Drawn on `08 · Editor` as `Formatting overflow`, both themes: the git column open, the last group folded, the `⋯` in `accent` and the strip under it (4 in, 24 buttons 4 apart, `border` outline, radius 6). `Icon` gained a `more` variant. `Merged rows`' note about scrolling was corrected. Not exported — and the card's own render timed out twice on the server, so check it before the export |
| **`preferences.json` in the editor** | Drawn on `20 · Preferences` as `Preferences file open`, both themes: the tab, `Source` chosen with `Split` and `Preview` unavailable, the formatting buttons dim, no `Diff`, no open row in the tree, `JSON` in the status bar. Not exported |
| **The site in light** | Only the dark board exists |
| **Built on 2026-10-09 without a board** | **Drawn**, all four, both themes. Not exported. `07 · Home`: the recent rows carry their branch (`main`, `feat/onboarding`; none on the notes row). `19 · Pull`: a new row, `Pull refused`, the `modified` band with `Show the command` and `Try again`. `11 · Commit`: `Commit in progress` dims only the staged rows (name `text_muted`, folder at 60%) and drops their ↶ — the app now drops it too. `24 · Shell`: `Closing the space — unsaved work` asks in the breadcrumb's popover, counting documents, the dialog and scrim hidden; both themes checked in the render (2026-10-09) — the account disc is empty there, where every other board reads `AS` |
| **`No repository` on `16`** | **Drawn**: the breadcrumb is the folder alone (`docs`), the title centred, the branch glyph's width. Not exported |
| **A band wraps** (2026-10-09) | The maintainer's call: a sentence too long for the row wraps and the band grows, the pills on its first line. `Pull refused` (`19`) draws it at 52. Not exported |
| **Every screen says why it exists** (2026-10-09) | Every shot on pages 07–25 opens its notes with `Why this screen`; `Git menu`, `Explorer menu`, `New document` and `New folder` gained their notes. Notes that contradicted the app were corrected on `08`, `11`, `12`, `20`, `23`, `24`, and `23`'s two stale duplicate groups were removed. Not exported |
| **Notes audited 2026-10-09** | Every shot on `07`–`25` and `28` has its notes and opens with `Why this screen`. **Cut text fixed**: 67 note bodies on `07`, `11`, `17`, `18`, `20`, `21`, `22` sat in a one-line box while their text ran to two, so the second line was clipped; each box was grown and its group moved down. `Preferences` on `20` gained `Git commands`. Three groups are named differently from their shot (`Reading`, `with replace`, `Shell`) — harmless, but a sweep by name skips them. Not exported |
| **Swept 2026-10-09** | 150 branch texts at a stale width (29 → 105 in the pill, 26 → 92 in the status bar) on `10`, `12`, `13`, `15`, `17`, `18`, `19`, `23`; the ↶ hidden on 16 conflicted rows (`13`, `19`); stray ↶ on `16`, `17` and `Commit succeeded`; `16` boards' foot now `N ahead of origin/<branch>` where Push shows N. Not exported |
| **Opening a change** | [opening-a-change](../product/git-workflow/commit/opening-a-change/doc.md): a file that is not markdown opens in a text tab with the diff by line, a deleted one its last version read-only, a binary one a sentence; a deleted `.md` rendered with every block removed and no `Back to now` (the maintainer's call, 2026-10-09). **Drawn** on `11`, both themes, with notes: `A change that is not a document` (`mkdocs.yml`, line marks), `A deleted file` (`docs.yml (deleted)`, all under `removed`, `R` on the first line, `Read-only`), `A deleted document` (preview, every block struck through, no `Diff` chip), `A binary file` (the sentence and `Reveal in Finder`, `Binary · Read-only`). Built to them. Not exported |
| **`Stage all` in the `Git panel` master** | **Done** (2026-10-09): both `Git` variants (`Dark`, `Light`) carry it at the head of `CHANGES`, right-aligned with `Unstage all`; the copies swept on every screen page, hidden on `11`'s `Commit succeeded`, `16` and the twenty boards of `17`, where `CHANGES` is not drawn. Not exported |
| **Git approvals** | New page `28 · Screens: Git - Approvals` (2026-10-09), made from a duplicate of `22` re-id'd by cloning its card; both themes, notes, approved by the maintainer: the popover in its three modes (`Git commands — Automatic / Semi-automatic / Manual`), `Manual — a plan waiting`, `Semi-automatic — always allow`, `Manual — opening a space`, `git-approvals.json`, `Manual — always allow asks first`, `Manual — a read denied` (the column's foot says `Out of date: a read was denied.` with `Reload`), `Approval row — states` ([approvals](../product/git-workflow/approvals/doc.md)). **Two masters** on `04` (the library is 43): `Row action` (`Kind`: `Confirm` · `Always` · `Refuse`, a flex pill 20 tall with its `Icon`) in `ACTIONS`, and `Spinner` in `CHROME`; every waiting row on `28` is instances of them. The six popover boards on `20` carry the `GIT COMMANDS` section (`Automatic` chosen) with `Open git-approvals.json` inside it. Every card says `/ 28` and the cover lists the page. The popovers on `28` and on `20` draw the same two `Open …json` buttons, file glyph included; `controls.md` carries the two masters' rows. Not exported — folder `git-approvals/`. Being built |
| **About, and updates** | Drawn on `20 · Screens: Preferences` (2026-10-09), both themes, notes: the popover gained `Check for updates when TOM opens` (off) and a last row `About TOM` with the version — on its six boards on `20` and the six on `28`; eight new rows — `About TOM` (`No release yet.`, the state that ships first), `Checking for updates`, `Up to date`, `Update available`, `Downloading the update`, `Ready to restart`, `Could not check`, `An update is waiting` (a dot on the gear, the row reading `Update available`, and `Update available: 0.2.0` in the status bar) ([about](../product/about/doc.md)). The dialog is drawn by hand with the brand icon at 56; `20` now holds thirteen rows and wants splitting into a page of its own. Not exported, not built |

## Boards that disagree with the app

| | |
|---|---|
| **Conflict tint** | `git-conflict/` draws it from 80; the app starts it at 44, the maintainer's number, and puts `C` in the gutter |
| **The `⋮`** | Decided 2026-10-08: **15.5** from the island's edge in both columns, the git column's number. **Master done**: the explorer's `⋮` and `+` moved 5 to the right in both variants of `TOM / Shell / Explorer`. Left: the menus drawn open on `explorer-menu` and `new-document` move 5 with it, and a copy that overrides the position needs checking |
| **`Diff` chip** | Decided 2026-10-08: **on** is `accent_soft` fill with `accent` outline and label, a chosen control; **off** is `border_strong` and `text_secondary`, Rest. **Swept**: 118 off labels across the screen pages from Home to Git - Pull (the master already matched). The explorer's `⋮` and `+` were swept too, on every copy — the copies did not follow the master. Not exported |
| ~~**`Up to date with origin/main`**~~ | Decided 2026-10-08: the boards are right, and the app draws it now; the doc was revised |

## After every change

Export both themes of every board touched, run `embed_fonts.py`, then
`grep -L "data:font"` over the folder and re-export whatever it lists.

---

*See also: [screens/not-drawn-yet.md](screens/not-drawn-yet.md) · [screens/divergences.md](screens/divergences.md) · [tom-design](../../.ai/skills/tom-design/SKILL.md)*
