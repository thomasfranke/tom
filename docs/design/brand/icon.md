# The icon

A 512 tile with a 22% corner radius — the macOS icon grid, which every other
platform tolerates.

| | Tile | Page | Where |
|---|---|---|---|
| **cream** — `tom-icon.svg` | `surface` `#FAF9F6` | `accent` `#4C7D6E` | The app icon: dock, launcher, installer. The default. |
| **sage** — `tom-icon-sage.svg` | `accent` `#4C7D6E` | `surface` `#FAF9F6` | Where the tile has to carry the colour: a dark surface, a favicon, a social avatar. |

- The page is **solid**, because an outlined page is a box at small sizes.
- The fold is the corner cut on the diagonal plus an L-shaped crease in the tile colour, so it degrades to a plain document at 16px rather than to a broken corner.
- Everything drawn on the page is cut out in the tile colour, so the icon is two colours wherever it goes.
- **The icon does not change with the app's theme** — a dock icon is a fixed object. A *mark* placed on a surface inside the app uses whichever colourway contrasts with that surface.

---

*See also: [brand/](README.md) · [the-shape.md](the-shape.md) · [rules.md](rules.md)*
