# The icon set

Font Awesome Free 6 **Solid**, vendored as a font in `src/packages/ui/fonts/`
and reached only through `TomGlyphWidget`
([Decision 32](../../technical/decisions/032-the-icon-set-is-font-awesome.md)).

| Glyph | Font Awesome | Where |
|---|---|---|
| `folder` · `folderOpen` · `file` | `folder` · `folder-open` · `file-lines` | the tree's rows, Home's `Choose folder…` |
| `branch` | `code-branch` | the branch pill, the status bar |
| `home` | `house` | before the breadcrumb: the way out of a space |
| `push` · `pull` · `fetch` | `arrow-up` · `arrow-down` · `arrows-rotate` | the column's foot, the status bar's drift |
| `undo` … `alert` | `rotate-left` … `triangle-exclamation` | the formatting bar's seventeen |
| `chevronDown` · `chevronRight` | `chevron-down` · `chevron-right` | a folder, a select control |
| `close` · `clear` · `check` · `replace` | `xmark` · `circle-xmark` · `check` · `right-left` | dismissing, emptying a field, a tick, replacing |
| `preferences` · `more` · `menu` · `plus` · `search` · `link` | `gear` · `ellipsis` · `ellipsis-vertical` · `plus` · `magnifying-glass` · `link` | the bar's last control, the collapsed group, and the rest |

- **The enum names what a glyph does here**, never what Font Awesome calls it, so swapping one is a line in `tom_glyph_widget.dart` and no screen changes.
- **The colour is the host control's**, available or not; nothing is recoloured per use.
- **The Penpot `Icon` component draws the same glyphs**, from Font Awesome's own SVGs, so a board and the app never show two sets.
- **`fetch` is not an arrow.** An arrow says something moved, and a fetch writes nothing to disk; `pull` is the one that carries the down arrow.
- **No Material `Icons`.** A second set beside this one is how the hand-drawn set ended up next to Material's `close` and `check`.
- ~~The set grows one glyph at a time, never by importing a library~~ — revoked by Decision 32, and the hand-drawn SVGs that were its source were deleted with it.

---

*See also: [components/](README.md) · [controls.md](controls.md)*
