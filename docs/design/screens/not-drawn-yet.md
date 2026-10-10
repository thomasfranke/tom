# Not drawn yet

What has no board, and why. Saying so is honest; a board that no longer matches
what shipped is not.

| | Why |
|---|---|
| **Mobile** | A `mobile/` folder appears when Phase 3 does. Drawn from the job, not from the desktop layout — [Decision 8](../../technical/decisions/008-monorepo-with-pure-dart-core.md) says *panels do not become screens* — and waiting on the two questions the [roadmap](../../roadmap.md#phases) names |
| **"YOUR COMMITS" under a rejection** | Phase 2; it needs `history()` |
| ~~**A pull that succeeded**~~ | Closed: `git-pull/pull-worked` and `already-up-to-date`, drawn and built |
| ~~**The diff turned off**~~ | Closed by deletion. Every screen that is not about the diff already draws the chip off, so a board of its own said nothing the other seventy-six do not ([turning it off](../../product/diff/rendered-diff/turning-it-off/doc.md)) |
| **Resolving a whole list of documents at once** · section blame | Post-MVP; neither constrains the M0 layout |
| ~~**A wikilink** · resolved, missing and ambiguous~~ | Closed: `editor-links-export/wikilinks` and `editor-links-export/linking-a-document` draw the three states and the `[[` list, and both are built |
| ~~**An export, and where it is asked for**~~ | Drawn: the tab's menu and the band that says where the file went, on `09 · Editor - Links & Export` ([export](../../product/export/doc.md)). Exported at the end of the work, with everything else waiting in the [Penpot backlog](../penpot-backlog.md) |
| ~~**The formatting bar's `⋯`, and the strip it opens**~~ | Drawn on 2026-10-08: `editor/formatting-overflow`, the `⋯` lit and the strip open under it, and `Icon[more]` in the library. The modes left that row for the top bar, so no board draws the bar over them any more. Exported at the end of the work ([formatting shortcuts](../../product/editor/formatting-shortcuts/doc.md)) |
| **The site in light** | Only the dark board exists — the site does not follow the reader's system setting ([site/](../site/README.md)) |
| ~~**`preferences.json` open in the editor**~~ | Drawn on 2026-10-08: `preferences/preferences-file-open`, a tab from outside the tree, source only, no `Diff`. Exported at the end of the work ([where it is stored](../../product/preferences/where-it-is-stored/doc.md)) |
| ~~**A theme toggle on Home**~~ | Closed. Home carries the [preferences](../../product/preferences/the-popover/doc.md) button, and the theme is inside it — the language is chosen before a space is open, so the bar needs it there |

## Drawn by the 1b restyle, with nothing behind them yet

The 2026-10-07 restyle (prototype 1b on `New Tmp`, JetBrains Islands with the
teal accent) put controls on every screen that no product doc asks for. Each
is a debt: a screen to design and a doc to write before the control can act,
or a control to remove if the answer is no.

| Control | Where | What it would need |
|---|---|---|
| ~~**`⋮` on the git panel**~~ | drawn: `git-commit/git-menu` — `Reload`, `Open in terminal`, `Open repository in Finder`, and `Discard all changes` apart | Built. Its confirmation (`Discard all changes?`) is the library's `Dialog` with no board of its own ([git menu](../../product/git-workflow/git-menu/doc.md)) |
| ~~**`+` and `⋮` on the explorer**~~ | drawn: `workspace-tree/new-document` (a field row inside the open folder) and `workspace-tree/explorer-menu` — `New folder`, `Collapse all`, `Reload`, `Reveal in Finder` | Both built, and `New folder`'s field drawn: `workspace-tree/new-folder` ([new document](../../product/navigation/file-tree/new-document/doc.md), [explorer menu](../../product/navigation/file-tree/explorer-menu/doc.md)) |
| ~~**`⌘K` in the search box**~~ | the explorer's field | Built as the shortcut focusing the box, opening the explorer first when it is shut; the keycap shows while the box is idle. A command palette is still a question |
| ~~**`new` badge on `Pull request`**~~ | ~~the explorer's navigation row~~ | ~~What makes a pull request *new*, and when the badge clears~~ (removed 2026-10-08: the badge does not exist) |
| ~~**`STAGED · n` / `CHANGES · n` sections, `Unstage all`**~~ | built, with `Stage all` on the other section | Still a doc revision of [staging](../../product/git-workflow/commit/README.md): sections instead of one list, and the two bulk actions |
| ~~**`Description (optional)` under the summary**~~ | the commit message box | Built: the body follows the summary after a blank line ([the message](../../product/git-workflow/commit/the-message/doc.md)) |
| ~~**`Up to date with origin/main`**~~ | built under `Fetch` / `Pull`, in the broken line's slot | ~~**Contradicts its own doc**~~ — no longer: the boards are right, the healthy line is built and [when the link is broken](../../product/git-workflow/push-pull/when-the-link-is-broken/doc.md) was revised (revised 2026-10-08) |
| ~~**The status bar's segments**~~ | built: branch, `↑ ↓`, the change count, `Ln, Col`, `UTF-8`, `Markdown`, `Saved`/`Unsaved` | Still a status-bar doc; the path and the file's name left it for the breadcrumb and the tab |
| **Icons on tabs and tree rows** | built on the tree: an open or closed folder, a document | A rule for a non-markdown file. ~~The tab's own glyph when tabs are built~~ — built: a tab carries the document glyph (revised 2026-10-08) |
| ~~**`Git · History` as tabs with a count**~~ | built, the count included | It counts what the status bar counts — every change git reports — and is not drawn at zero. Still a doc line for [regions](../../product/workspace/regions/doc.md) |

---

*See also: [screens/](README.md) · [roadmap.md](../../roadmap.md)*
