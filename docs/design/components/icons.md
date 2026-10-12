# The icon set

Font Awesome Free 6 **Solid**, vendored as a font in `src/packages/ui/fonts/`
and reached only through `TomGlyphWidget`
([Decision 32](../../technical/decisions/032-the-icon-set-is-font-awesome.md)) —
except the formatting bar's seventeen, which are Material Symbols Outlined at
weight 300, drawn from `icons/toolbar/<name>.svg`.

| Glyph | Font Awesome | Where |
|---|---|---|
| `folder` · `folderOpen` · `file` | `folder` · `folder-open` · `file-lines` | the tree's rows, a tab, Home's `Choose folder…` |
| `branch` | `code-branch` | the branch pill, the status bar |
| `home` | `house` | before the breadcrumb: the way out of a space |
| `preferences` · `person` | `gear` · `user` | the gear, and the account button when nobody is named |
| `push` · `pull` · `fetch` | `arrow-up` · `arrow-down` · `arrows-rotate` | the column's foot, the status bar's drift |
| `discard` | `arrow-rotate-left` | the end of a changes row: putting one file back as git has it |
| `undo` … `alert` | Material Symbols Outlined 300, not Font Awesome | the formatting bar's seventeen |
| `more` | `ellipsis` | what the formatting bar's last group folds into |
| `chevronDown` · `chevronRight` | `chevron-down` · `chevron-right` | a folder, a select control |
| `close` · `clear` · `check` · `replace` | `xmark` · `circle-xmark` · `check` · `right-left` | dismissing, emptying a field, a tick, replacing |
| `menu` · `plus` · `search` · `link` | `ellipsis-vertical` · `plus` · `magnifying-glass` · `link` | a column's `⋮`, a new entry, the search box, a URL |
| `terminal` · `copy` · `external` | `terminal` · `copy` · `arrow-up-right-from-square` | the git menu, a row of the Commands panel, a page that opens outside the app |

- **The enum names what a glyph does here**, never what Font Awesome calls it, so swapping one is a line in `tom_glyph_widget.dart` and no screen changes.
- **The colour is the host control's**, available or not; nothing is recoloured per use.
- **The house and the gear are stroked, not filled** — the same Solid glyph drawn as an outline, at the same size and in the same ink, so the bar's two ends read as one set.
- **`discard` is not `undo`.** Both turn left, and they are two glyphs because one takes back an edit and the other puts a file back.
- **The Penpot `Icon` component draws the same glyphs**, from Font Awesome's own SVGs, so a board and the app never show two sets.
- **The formatting bar's SVGs are the source** — `icons/toolbar/<name>.svg`, one `<path>` and a `viewBox` each; `docs/design/tools/toolbar_outlines.py` writes the app's outlines from them, and replacing a glyph is replacing its file.- **`fetch` is not an arrow.** An arrow says something moved, and a fetch writes nothing to disk; `pull` is the one that carries the down arrow.
- **A symbol that is not a letter comes from this set, never from text** — IBM Plex carries `✓`, `↑` and `↓` in its regular cut only, so at any other weight they export as nothing.
- **No Material `Icons`.** A second set beside this one is how a hand-drawn set ended up next to Material's `close` and `check`.

---

*See also: [components/](README.md) · [controls.md](controls.md)*
