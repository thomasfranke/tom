# The controls

One row per master. Sizes are in logical pixels; a blank radius means the
control has none of its own.

| Component | Flutter widget | Size | Radius | Notes |
|---|---|---|---|---|
| **Icon** | `Icon` | 24 | — | 16-unit grid, 2px stroke, no fill; **16** inside a button. Colour is the host control's. |
| **Button** | `FilledButton` · `OutlinedButton` | h **48** | `md` | Three kinds, each with or without a leading glyph, 10 gap, glyph and label centred together. **Primary**: `accent` fill, white 15·600 — the one action a surface is for. **Secondary**: `border_strong` outline, no fill, `text_secondary` 15·500. **Disabled**: `surface_sunken` fill, no outline, `text_muted`. |
| **Fab** | `FloatingActionButton` | 56 × 56 | `md` | `accent_soft`, `overlay` shadow, 24 glyph. |
| **Text field** | `TextField` | h **56** | `md` | The field a surface is about: outlined and nothing else, 1px `border_strong`, no fill, 2px `accent` on focus. Used by the commit message and a branch's name. **The filled variant is gone** — Flutter's default underline is a second kind of field for no reason. The board draws the label floating to 11 in `accent` on focus; **the app passes `hintText` and has never built that**, so the two fields differ today by size and fill alone — a divergence, not a second design. |
| **Column field** | `TomFieldBoxWidget` | h **28** | `sm` | The small field a side column holds — search, replace. `surface_sunken` fill, 1px `border`, 12 text at 12 in from the left, and a 1px `accent` hairline on focus rather than the 56-point field's two. **The box is drawn, not decorated**: a Material decoration sizes itself from its content, so an empty one came out seven points shorter. |
| **Field clear** | `IconButton` | 16 | circular | A `text_muted` disc at the field's trailing edge with the close glyph knocked out of it in the field's own fill — a bare glyph reads as a character somebody typed. Present only while the field has something in it. |
| **Search bar** | `SearchBar` | h 56 | `md` | Leading 24 glyph at 16, hint in `bodyLarge` `text_secondary`. The full-height search box, for a bar or a page — **a column gets the 28-tall `Column field` instead**, and the two differ by where they go, not by what they do. |
| **Checkbox** | `TomCheckWidget` | **15** box, 20 target | `sm` | Off: `surface_raised` fill behind a 1px `border_strong` hairline. On: `accent` fill, the tick knocked out in `surface_raised` — **not white**, which on this accent glares. |
| **Radio** | `Radio` | 20 | circular | 2px outline; 10 dot in `accent` when on. |
| **Switch** | `Switch` | 52 × 32 | circular | Off: `surface_sunken` track, 2px `border_strong` outline, 16 thumb. On: `accent` track, 24 white thumb. The thumb's size **is** the state. |
| **Slider** | `Slider` | 4 track, 20 thumb | circular | Active `accent`, inactive `border`. |
| **Chip** | `FilterChip` · `AssistChip` | h **26** | `md` | Three states, each with or without a leading check. **Rest**: 1px `border_strong`, no fill, `text_secondary`. **Selected**: `accent_soft` fill, 1px `accent`, `accent` label. **Disabled**: `surface_sunken`, no outline, `text_muted`. The `Diff` chip in the mode bar is one. |
| **Segmented · 2** · **Segmented · 3** | `SegmentedButton` | h 40, 116 per segment | `md` | 1px `border_strong` outline and dividers; selected segment on `accent_soft` with a leading check — the state is never colour alone. |
| **Tabs** | `TabBar` | h 48 | indicator `sm` | 3px `accent` indicator, 1px `border` divider under the row. |
| **Panel toggle** | `TomPanelToggleWidget` | **20 × 16** | 3 | 1.5px `text_secondary` outline and one divider 7 in from its own edge, both **always drawn**; the strip between them fills when that column is open. Left and right, open and closed. |
| **Theme toggle** | `TomThemeToggleWidget` | **16** circle | circular | The panel toggle's grammar — same ink, same weight — with one half filled. ~~Third in the bar's group of three~~: the theme moved into the [preferences](../../product/preferences/the-popover/doc.md) popover, so no screen instances this any more ([unused](unused.md)). |
| **Progress bar** | `LinearProgressIndicator` | **280 × 3**, the column's width | — | A track in `accent_soft` and a 96-wide segment in `accent`, at the very top of the panel that owns the request — and **drawn only while one is in flight** ([while a request runs](../../product/git-workflow/push-pull/while-a-request-runs/doc.md)). It is the column's signal, so nothing local (staging, committing) ever raises it. |
| **Preferences button** | `IconButton` | **20 × 20** | — | The bar's last control, after the two column toggles. An `Icon` instance of the `preferences` gear at 20 with a 1.5px `text_secondary` stroke — the toggles' weight, so the three still read as one set. It is on every screen, Home included. |
| **Select control** | `OutlinedButton` + `MenuAnchor` | 200 × 40 | `md` | Trailing 16 chevron. Open: `accent_soft` fill, `accent` outline. |
| **Status mark** | `Container` | 20 × 20 | `sm` | Six kinds — `M`odified, `A`dded, `D`eleted, `R`enamed, `N`ew, `C`onflicted — each a `<role>_soft` fill with its letter in `<role>`. **A letter as well as a colour** — roughly one in twelve men cannot separate the red from the green, which is also why `C` may share `D`'s red: the palette has no conflict role, and the letter is the signal. |
| **Notice band** | `ColoredBox` | h **36**, full width of the document area | — | `<role>_soft` fill and no rule of its own: the hairline above it is the mode bar's divider, and the height is the mode bar's so the two stack as one piece of chrome. Sentence at the left, `ui` in `<role>`, 28 in. One action at the right, 24 in: a **96 × 24 pill**, `md` radius, `surface_raised` fill, 1px `<role>` outline, label `ui-strong` in `<role>`. |
| **Badge** | `Badge` | 6 | circular | `accent`. The unsaved / unread mark. |
| **Column grip** | `MouseRegion` + `GestureDetector` | 2 × 14 | — | Three 2px dots, 6 apart, in `border_strong`, centred at half the window's height. It is the only thing that says a width can be dragged. In a gutter it sits on the edge between two containers; when that column is closed it sits at the window's edge instead, because the way to bring a column back must not close with the column. |
| **Card** | `Card` | — | `md` | `surface_raised` with a 1px `border` hairline. No shadow: it sits in the page. |
| **Popover** | `OverlayPortal` | — | `md` | The card that floats: same `surface_raised` and 1px `border`, plus the `overlay` shadow. The shadow **is** the difference — a surface that leaves the page says so, and one that does not must not borrow it. The branch switcher is the first. |
| **Menu** | `MenuAnchor` · `PopupMenuButton` | 48 rows, 8 vertical padding | `md` | `surface_raised`, `overlay` shadow; selected row on `accent_soft` with a trailing check. This is what a popover is in Flutter; there is no other one. |
| **Dialog** | `AlertDialog` | w **400**, 24 padding | `md` | Two variants, `Actions: Two` and `Actions: Three`. `surface_raised`, 1px `border`, `overlay` shadow. Title 22, body 14 in `text_secondary` over a 352 measure, height from the content. **The actions are stacked full width**, 352 × 48 with an 8 gap, the safe one first as a `Primary` button and the rest `Secondary` — ~~they used to be a pair at the right padding~~, which cannot hold the three that leaving a space and switching a branch both need. **Each is named by what it does** — `Abort the pull`, never `OK` — and the destructive one takes `removed`, which is the second signal beside its words. |
| **Scrim** | `ModalBarrier` | resized to the window | — | `#000000` at 55%. A dim is not part of the card, so it is its own master: every modal dims by the same amount instead of each screen inventing one. |
| **Toolbar button** | `IconButton` | 28 × 28 | `md` | `surface_raised`, and a 1px `border` in light where the raised fill alone does not separate it from the strip. The glyph is an `Icon` instance at 24, centred. Seventeen of them are the [formatting bar](../../product/editor/formatting-shortcuts/doc.md); nothing else repeats a control this many times, which is why the cell is a master rather than a rectangle. |
| **Snackbar** | `SnackBar` | h 48 | `md` | `text_primary` fill, `surface` text, action in `accent_soft`. |

- **A two-way choice is a `Segmented · 2`, not a `Switch`.** The `Switch` is the on/off track-and-thumb control and nothing else, so `Source · Split · Preview` and `Changes · History` are one component at two widths.
- A popover anchored at the *right* of a bar hangs from its right edge, or it lands off the window.
- Which of these no screen asks for yet: [`unused.md`](unused.md).

## Unavailable

One answer, for every control and both kinds: `surface_sunken` fill, no
outline, `text_muted` label and glyph. Three were invented before this was
written, and one of them put a light screen's label in the dark theme's ink.

- **Unavailable is a kind, not a state.** A button is `Primary`, `Secondary` or `Disabled`, and a disabled one does not keep the outline of the kind it would have been — a control that is off must not still look like one that is on.
- **An unavailable control keeps its size and its words**; only its colours change, so nothing on the screen moves when it becomes available.
- **The glyph takes the label's colour**, available or not — it is the host control's, never its own.
- Other controls borrow the same three colours when they go unavailable; the `Diff` chip and the panel toggles already do.
- **The mode bar's `Diff` chip is drawn as none of the three, and that is open.** Seventy-six boards give it no fill, a 1px `border` outline and a `text_muted` label — Rest's shape wearing Disabled's ink, with a lighter outline than either. The chip is clickable there, so by this table it is `Rest`: `border_strong` and `text_secondary`. Closing it changes how the chip reads on every board, so it is the maintainer's, not a sweep's.
- **`Chip` is the one master that carries a product word.** Its label is `Diff` rather than `One`, because a Penpot copy freezes the master's text at the moment it is made: editing the master afterwards does not reach the copies, and neither does writing to the copy's own label. Only a *fresh* instance picks the word up. The rule the rest of the library follows is still the rule — this is the platform, not a choice, and it is written down so nobody 'fixes' it back.

---

*See also: [components/](README.md) · [radius.md](radius.md) · [type.md](type.md) · [elevation.md](elevation.md)*
