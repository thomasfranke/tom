# The icon

A 512 tile with a 22% corner radius — the macOS icon grid, which every other
platform tolerates.

| | Tile | Page | Where |
|---|---|---|---|
| **cream** — `tom-icon.svg` | `surface_raised` `#F6F5F1` | `accent` `#178F71` | The app icon: dock, launcher, installer. The default. |
| **sage** — `tom-icon-sage.svg` | `accent` `#178F71` | `surface_raised` `#F6F5F1` | Where the tile has to carry the colour: a favicon, a social avatar. |
| **dark** — `tom-icon-dark.svg` | dark `surface_raised` `#1E1F22` | dark `accent` `#4FD1B0` | The dark-mode icon: a dock or a launcher in dark mode, and the mark in the dark lockup. |

The page follows the app's accent, so the 1b teal reached the icon with
nothing redrawn; the tile is `surface_raised` since the warm palette took
`surface` to a grey no icon should sit on.

- The page is **solid**, because an outlined page is a box at small sizes.
- The fold is the corner cut on the diagonal plus an L-shaped crease in the tile colour, so it degrades to a plain document at 16px rather than to a broken corner.
- Everything drawn on the page is cut out in the tile colour, so the icon is two colours wherever it goes.
- **The icon follows the system's appearance, never the app's own theme switch** — cream in light and dark in dark, the way macOS 26 asks an icon to. A *mark* placed on a surface inside the app uses whichever colourway contrasts with that surface.

- **Linux** (draft, for the maintainer's gate): the cream colourway at 16, 24, 32, 48, 64, 128, 256 and 512, as `hicolor/<n>x<n>/apps/tom.png` under `src/apps/desktop/linux/icons/` — [files.md](files.md) has the path.

---

*See also: [brand/](README.md) · [the-shape.md](the-shape.md) · [rules.md](rules.md)*
