# Tools

The scripts that generate what this chapter holds and measure a board against the running app. Each needs only Python 3 — the measuring ones also Chrome — and is run from the repository root; its docstring is its manual.

| Script | Does |
|---|---|
| [`palette.py`](palette.py) | Holds the colour roles for both modes, writes [`visual-language/palette.svg`](../visual-language/README.md) and checks every text pairing against WCAG AA |
| [`brand.py`](brand.py) | Draws the icon, the wordmark and the lockup from the palette's roles into [`brand/`](../brand/README.md); `--rasters` adds the PNGs, the `.icns` and the `.ico` |
| [`decode_exports.py`](decode_exports.py) | Writes the boards a Penpot export call returned, from the file the answer was spilled into |
| [`embed_fonts.py`](embed_fonts.py) | Makes a Penpot SVG export self-contained by putting its fonts inside the file |
| [`render.py`](render.py) | Renders an exported board, or any SVG, to a PNG with headless Chrome at the boards' own 1440 × 900 |
| [`pixels.py`](pixels.py) | Prints the colour runs along one row or column of a PNG |
| [`bbox.py`](bbox.py) | Prints where the ink is inside a rectangle of a PNG |
| [`compare.py`](compare.py) | Puts the board, the app and their difference side by side in one PNG |
| [`pngio.py`](pngio.py) | Reads and writes a PNG without Pillow; the three measuring scripts import it |
| `generated/` | The font cache `embed_fonts.py` fills — ignored by git |

- A file one of these writes is regenerated, never edited by hand.
- `embed_fonts.py` runs over every export before it is committed — a board straight from Penpot points its fonts at Penpot's own proxy.
- How the measuring four are used against a board is the [`tom-design`](../../../.ai/skills/tom-design/SKILL.md) skill.

---

*See also: [design/](../README.md) · [screens/](../screens/README.md) · [conventions/testing.md](../../technical/conventions/testing.md)*
