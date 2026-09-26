# The icon set

Glyphs drawn on a 16 grid with a 2px stroke and no fill, one SVG each in
[`icons/`](icons/).

| | | |
|---|---|---|
| [`folder.svg`](icons/folder.svg) | [`link.svg`](icons/link.svg) | [`search.svg`](icons/search.svg) |
| [`chevron.svg`](icons/chevron.svg) | [`check.svg`](icons/check.svg) | [`close.svg`](icons/close.svg) |
| [`plus.svg`](icons/plus.svg) | [`upload.svg`](icons/upload.svg) | [`download.svg`](icons/download.svg) |

- Each is `viewBox="0 0 16 16"`, rendered at 24 with `stroke="currentColor"` — the colour is the host control's and nothing is recoloured per use.
- **These files are the source**, and the Penpot `Icon` component draws the same paths. When the two disagree these are right: a glyph is geometry, and geometry belongs in a file the build can read.
- The set grows **one glyph at a time**, never by importing a library — an icon set is a visual decision this project has not made, and importing one makes it by accident.
- The chevron is VS Code's codicon path, filled, and is aligned by its ink rather than its box — the two states carry different amounts of it, so matching the boxes makes them look unaligned.
- Rendering these needs `flutter_svg`, so it is a licence check under [rule 1](../../../AGENTS.md). The alternative is each `d` attribute in a `CustomPainter`, which costs nothing.

---

*See also: [components/](README.md) · [controls.md](controls.md)*
