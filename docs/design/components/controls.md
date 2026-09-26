# The controls

One row per master. Sizes are in logical pixels; a blank radius means the
control has none of its own.

| Component | Flutter widget | Size | Radius | Notes |
|---|---|---|---|---|
| **Icon** | `Icon` | 24 | — | 16-unit grid, 2px stroke, no fill; **16** inside a button. Colour is the host control's. |
| **Button** | `FilledButton` · `OutlinedButton` · `TextButton` | h **48** | `md` | Glyph and label centred together, 10 gap. Filled: `accent` / white 15·600. Outlined: `border_strong` outline / `text_muted` 15·500. Text: `accent` 15·500. |
| **Fab** | `FloatingActionButton` | 56 × 56 | `md` | `accent_soft`, `overlay` shadow, 24 glyph. |
| **Text field** | `TextField` | h **56** | `md` | Filled (default): `surface_sunken`, 1px underline `text_secondary`, 2px `accent` on focus, top corners only. Outlined: 1px `border_strong`, 2px `accent` on focus. Label floats to `labelSmall` on focus. |
| **Field clear** | `IconButton` | 16 | circular | The close glyph at the field's trailing edge, `text_muted`. Present only while the field has something in it. |
| **Search bar** | `SearchBar` | h 56 | `md` | Leading 24 glyph at 16, hint in `bodyLarge` `text_secondary`. |
| **Checkbox** | `Checkbox` | 18 box, 48 target | `sm` | Off: 2px `text_secondary` outline. On: `accent` fill, white tick. |
| **Radio** | `Radio` | 20 | circular | 2px outline; 10 dot in `accent` when on. |
| **Switch** | `Switch` | 52 × 32 | circular | Off: `surface_sunken` track, 2px `border_strong` outline, 16 thumb. On: `accent` track, 24 white thumb. The thumb's size **is** the state. |
| **Slider** | `Slider` | 4 track, 20 thumb | circular | Active `accent`, inactive `border`. |
| **Chip** | `FilterChip` · `AssistChip` | h 32 | `md` | Rest: 1px `border_strong`, `labelLarge` `text_secondary`. Selected: `accent_soft`, leading check. |
| **Segmented · 2** · **Segmented · 3** | `SegmentedButton` | h 40, 116 per segment | `md` | 1px `border_strong` outline and dividers; selected segment on `accent_soft` with a leading check — the state is never colour alone. |
| **Tabs** | `TabBar` | h 48 | indicator `sm` | 3px `accent` indicator, 1px `border` divider under the row. |
| **Panel toggle** | `IconButton` | 28 × 22 | `sm` | 1px `border_strong` outline and one divider, both **always drawn**; the strip fills when that panel is open. Six variants: left, right and bottom, open and closed. |
| **Theme toggle** | `IconButton` | 28 × 22 | `sm` | The panel toggle's grammar with one half filled, so the three read as one set. |
| **Select control** | `OutlinedButton` + `MenuAnchor` | 200 × 40 | `md` | Trailing 16 chevron. Open: `accent_soft` fill, `accent` outline. |
| **Status mark** | `Container` | 20 × 20 | `sm` | `<role>_soft` fill, letter in `<role>`. **A letter as well as a colour** — roughly one in twelve men cannot separate the red from the green. |
| **Notice band** | `MaterialBanner` | h 48, full width of the document area | — | `<role>_soft` fill, 1px `<role>` top and bottom rule, sentence at the left and one action at the right. |
| **Badge** | `Badge` | 6 | circular | `accent`. The unsaved / unread mark. |
| **Card** | `Card` | — | `md` | `surface_raised` with a 1px `border` hairline. No shadow: it sits in the page. |
| **Menu** | `MenuAnchor` · `PopupMenuButton` | 48 rows, 8 vertical padding | `md` | `surface_raised`, `overlay` shadow; selected row on `accent_soft` with a trailing check. This is what a popover is in Flutter; there is no other one. |
| **Dialog** | `AlertDialog` | 24 padding | `md` | `surface_raised`, `overlay` shadow, title in `titleLarge`, actions right as text buttons. |
| **Snackbar** | `SnackBar` | h 48 | `md` | `text_primary` fill, `surface` text, action in `accent_soft`. |

- **A two-way choice is a `Segmented · 2`, not a `Switch`.** The `Switch` is the on/off track-and-thumb control and nothing else, so `Source · Split · Preview` and `Changes · History` are one component at two widths.
- A popover anchored at the *right* of a bar hangs from its right edge, or it lands off the window.
- Which of these no screen asks for yet: [`unused.md`](unused.md).

---

*See also: [components/](README.md) · [radius.md](radius.md) · [type.md](type.md) · [elevation.md](elevation.md)*
