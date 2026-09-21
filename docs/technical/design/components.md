# Components

The control set, with the exact numbers. The drawing lives in Penpot
(`Foundations` and `Components` boards, light and dark); this file is what the
Flutter implementation reads, because a colour picked off a screenshot is a
colour that drifts.

**Anatomy is Material 3, palette is TOM's, and the button is the product's
own.** Material because the app is Flutter and every control here is a widget
that already exists — a 48px button with an 8px radius is a `ButtonStyle` set
once in the theme, not an override at every call site. The palette is not
Material's, because the palette is the brand ([visual-language.md](visual-language.md)).
The button keeps the geometry the screens were already drawn to.

The rule that outranks everything below: **[the canonical form of a rule is the
dartdoc of the code that implements it](../../../AGENTS.md)**. When this file and
the theme disagree, the theme is right and this file is the bug.

## Palette

Sixteen roles, each with a light and a dark value. A role added in one mode
without its counterpart is a bug — dark is not a separate palette, it is the
same roles at different values.

| Role | Light | Dark | Used for |
|---|---|---|---|
| `surface` | `#FAF9F6` | `#1A1917` | The page |
| `surface_raised` | `#FFFFFF` | `#232220` | Panels, menus, cards |
| `surface_sunken` | `#F0EEE9` | `#131211` | Inputs, code blocks, the inactive pane |
| `border` | `#E2DFD8` | `#34322D` | Dividers between regions |
| `border_strong` | `#C9C5BB` | `#4C4942` | A control's own outline |
| `text_primary` | `#26251F` | `#ECEAE4` | Body and headings |
| `text_secondary` | `#57544C` | `#ADA9A0` | Supporting text, glyphs |
| `text_muted` | `#8B877D` | `#807C74` | Captions, disabled, secondary labels |
| `accent` | `#4C7D6E` | `#84B5A5` | The way forward, selection, links |
| `accent_soft` | `#E4EEEA` | `#1E2C28` | The accent as a surface |
| `added` | `#3D7A52` | `#86BC98` | A added in a diff |
| `added_soft` | `#E6F0E8` | `#1B2820` | ...as a surface |
| `removed` | `#A24F46` | `#DA9A92` | D removed in a diff |
| `removed_soft` | `#F6E8E6` | `#2C1E1C` | ...as a surface |
| `modified` | `#8F6F2E` | `#D2B274` | M modified in a diff |
| `modified_soft` | `#F4EDDF` | `#2A2418` | ...as a surface |

### As a Flutter `ColorScheme`

The left column is what a widget's default reads, so a `ColorScheme` built
from this table gives every Material widget the right colour without a single
per-widget override.

| `ColorScheme` | TOM role |
|---|---|
| `primary` | `accent` |
| `onPrimary` | `surface_raised` |
| `primaryContainer` · `secondaryContainer` | `accent_soft` |
| `onPrimaryContainer` · `onSecondaryContainer` | `text_primary` |
| `surface` | `surface` |
| `surfaceContainerLow` | `surface_raised` |
| `surfaceContainerHigh` | `surface_sunken` |
| `onSurface` | `text_primary` |
| `onSurfaceVariant` | `text_secondary` |
| `outline` | `border_strong` |
| `outlineVariant` | `border` |
| `inverseSurface` | `text_primary` |
| `onInverseSurface` | `surface` |
| `error` | `removed` |

## Radius

**Two steps and a shape.** It was nine different numbers at one point — 2, 3,
4, 8, 10, 12, 16, 20, 28 — because Material's radii were laid over the ones the
product already had, and a set where every control rounds differently reads as
nine products. Four steps was still three more than nineteen components can
justify.

| Step | Value | Applied to |
|---|---|---|
| `sm` | **4** | Checkbox, diff mark, tab indicator |
| `md` | **8** | Everything else — button, chip, segmented, text field, search bar, branch control, card, menu, dialog, snackbar, FAB |
| — | *circular* | Switch track, radio, badge, slider track and thumb |

Circular is not a step, it is a shape: those controls are round by definition,
and their radius is half their height. A value forced by geometry is not a
choice, so it does not belong in the scale.

The filled text field is the one exception to a uniform radius — `md` on the
top two corners, `0` on the bottom two, because the underline needs a straight
edge to sit on. That is Material's shape and Flutter draws it by default.

## Type

IBM Plex — Sans for the interface, Serif for rendered prose, Mono for code and
for anything that is a literal value. Sizes are in logical pixels.

| Style | Face | Size / line height | Weight | Used for |
|---|---|---|---|---|
| `heading-lg` | Sans | 24 / 1.3 | 600 | A document's h1 in the preview |
| `heading` | Sans | 17 / 1.35 | 600 | In-document h3, the space name |
| `body-read` | Serif | 16 / 1.7 | 400 | Rendered prose, reading mode |
| `body-split` | Serif | 15 / 1.7 | 400 | Rendered prose, split view |
| `ui` | Sans | 13 / 1.4 | 400 | Tree rows, controls |
| `ui-strong` | Sans | 13 / 1.4 | 600 | The selected row |
| `code` | Mono | 12.5 / 1.6 | 400 | The source pane |
| `caption` | Sans | 12 / 1.4 | 400 | Tab labels, placeholders, secondary rows |
| `label` | Sans | 10 / 1.4 | 600 | Panel captions — uppercase, 1.2 letter-spacing |
| `status` | Sans | 11 / 1.4 | 400 | The status bar |

Controls use Material's own text scale rather than the one above, because that
is what the widgets ship with:

| Material style | Size | Weight | Letter-spacing |
|---|---|---|---|
| `titleLarge` | 22 | 400 | 0 |
| `bodyLarge` | 16 | 400 | 0.5 |
| `bodyMedium` | 14 | 400 | 0.25 |
| `labelLarge` | 14 | 500 | 0.1 |
| `labelSmall` | 11 | 500 | 0.5 |

The button is the exception again: **15 / 600** on the filled one and
**15 / 500** on the outlined one, which is what Home already used.

## Elevation

**One level**, and it is for what floats over the content. Material ships five;
the product has exactly three surfaces that leave the page. The shadow colour
is `text_primary` at a low opacity, never black.

| | Value | Used by |
|---|---|---|
| `overlay` | `0 4 12`, `text_primary` at 14% | Menu, dialog, snackbar, FAB |
| `hairline` | 1px `border` | Card, panels, dividers |

`hairline` is not an elevation — it is what everything else uses instead. **A
card sits in the page, it does not hover above it**, which is how Home already
drew it before the component existed. Reaching for a shadow to separate two
things that are both on the page is how a flat interface turns soft.

## The controls

Nineteen masters. Every screen places an instance; no screen draws a control.

| Component | Flutter widget | Size | Radius | Notes |
|---|---|---|---|---|
| **Icon** | `Icon` | 24 | — | 16-unit grid, 2px stroke, no fill; **16** inside a button. Colour is the host control's. |
| **Button** | `FilledButton` · `OutlinedButton` · `TextButton` | h **48** | `md` | Glyph and label centred together, 10 gap. Filled: `accent` / white 15·600. Outlined: `border_strong` outline / `text_muted` 15·500. Text: `accent` 15·500. |
| **Fab** | `FloatingActionButton` | 56 × 56 | `md` | `accent_soft`, `overlay` shadow, 24 glyph. |
| **Text field** | `TextField` | h **56** | `md` | Filled (default): `surface_sunken`, 1px underline `text_secondary`, 2px `accent` on focus, top corners only. Outlined: 1px `border_strong`, 2px `accent` on focus. Label floats to `labelSmall` on focus. |
| **Search bar** | `SearchBar` | h 56 | `md` | Leading 24 glyph at 16, hint in `bodyLarge` `text_secondary`. |
| **Checkbox** | `Checkbox` | 18 box, 48 target | `sm` | Off: 2px `text_secondary` outline. On: `accent` fill, white tick. |
| **Radio** | `Radio` | 20 | circular | 2px outline; 10 dot in `accent` when on. |
| **Switch** | `Switch` | 52 × 32 | circular | Off: `surface_sunken` track, 2px `border_strong` outline, 16 thumb. On: `accent` track, 24 white thumb. The thumb's size **is** the state. |
| **Slider** | `Slider` | 4 track, 20 thumb | circular | Active `accent`, inactive `border`. |
| **Chip** | `FilterChip` · `AssistChip` | h 32 | `md` | Rest: 1px `border_strong`, `labelLarge` `text_secondary`. Selected: `accent_soft`, leading check. |
| **Segmented** | `SegmentedButton` | h 40, 116 per segment | `md` | 1px `border_strong` outline and dividers; selected segment on `accent_soft` with a leading check — the state is never colour alone. |
| **Tabs** | `TabBar` | h 48 | indicator `sm` | 3px `accent` indicator, 1px `border` divider under the row. |
| **Branch control** | `OutlinedButton` + `MenuAnchor` | 200 × 40 | `md` | Trailing 16 chevron. Open: `accent_soft` fill, `accent` outline. |
| **Diff mark** | `Container` | 20 × 20 | `sm` | `<role>_soft` fill, letter in `<role>`. **A letter as well as a colour** — roughly one in twelve men cannot separate the red from the green. |
| **Badge** | `Badge` | 6 | circular | `accent`. The unsaved / unread mark. |
| **Card** | `Card` | — | `md` | `surface_raised` with a 1px `border` hairline. No shadow: it sits in the page. |
| **Menu** | `MenuAnchor` · `PopupMenuButton` | 48 rows, 8 vertical padding | `md` | `surface_raised`, `overlay` shadow; selected row on `accent_soft` with a trailing check. This is what a popover is in Flutter; there is no other one. |
| **Dialog** | `AlertDialog` | 24 padding | `md` | `surface_raised`, `overlay` shadow, title in `titleLarge`, actions right as text buttons. |
| **Snackbar** | `SnackBar` | h 48 | `md` | `text_primary` fill, `surface` text, action in `accent_soft`. |

### The icon set

Nine glyphs, drawn on a 16 grid with a 2px stroke and no fill, in
[`icons/`](icons/) — one file each, `viewBox="0 0 16 16"` rendered at 24 with
`stroke="currentColor"`, so the colour is the host control's and nothing has to
be recoloured per use.

| | | |
|---|---|---|
| [`folder.svg`](icons/folder.svg) | [`link.svg`](icons/link.svg) | [`search.svg`](icons/search.svg) |
| [`chevron.svg`](icons/chevron.svg) | [`check.svg`](icons/check.svg) | [`close.svg`](icons/close.svg) |
| [`plus.svg`](icons/plus.svg) | [`upload.svg`](icons/upload.svg) | [`download.svg`](icons/download.svg) |

These files are the source; the Penpot `Icon` component draws the same paths.
When the two disagree, these are right — a glyph is geometry, and geometry
belongs in a file the build can read.

It grows **one glyph at a time**, and never by importing a library — an icon
set is a visual decision this project has not made, and importing one makes it
by accident.

A note for the implementation: rendering these needs `flutter_svg`, which is a
dependency and therefore a licence check under [rule 1](../../../AGENTS.md).
The alternative is pasting each `d` attribute into a `CustomPainter`, which
costs nothing and is what nine glyphs probably deserve.

## What has no screen yet

`Fab`, `Radio` and `Slider` are in the set but no screen asks for them, and
`Switch` is wanted only by Settings in M3. They are drawn so the set is
complete and so nobody invents a fourth kind of toggle later; they are **not**
a commitment that the product will use them.

## Where this is drawn

Penpot, file **TOM**, page **Foundations** — four boards side by side:
`Foundations` and `Foundations · Dark` (palette, type, the masters), then
`Components` and `Components · Dark` (one row per control, with the Flutter
widget named on each row). The components are a real Penpot library under the
`TOM/` path, with variants, so a screen places an instance rather than a copy.

The Penpot file is the drawing and this file is the specification. Penpot's
free plan keeps seven days of history, so **a number that matters belongs
here**, not only there.
