# Files

What is generated, what is committed, and what each runner needs.

```
docs/design/
├── brand/
│   ├── README.md              ← the index
│   ├── brand.svg              ← generated: the sheet
│   ├── brand.pdf              ← the card, as every page has one
│   ├── tom-icon.svg           ← cream tile — the app icon
│   ├── tom-icon-sage.svg         sage tile
│   ├── tom-wordmark-light.svg
│   ├── tom-wordmark-dark.svg
│   ├── tom-lockup-light.svg
│   └── tom-lockup-dark.svg
└── tools/brand.py             ← the decision, as code
```

## The rasters are not documentation

PNG sets, `.icns` and `.ico` are build outputs, produced on demand with
`--rasters` and **not committed here**. What *is* committed is the copy each
runner needs to build:

| Runner | Path | Note |
|---|---|---|
| macOS | `src/apps/desktop/macos/Runner/Assets.xcassets/AppIcon.appiconset/` | Cream PNGs at 16–1024; Xcode compiles them into the bundle's `.icns` |
| Windows | `src/apps/desktop/windows/runner/resources/app_icon.ico` | `tom-icon.ico` |
| Linux | — | No icon of its own; GTK takes it from the desktop entry the packaging step writes (M3) |

Changing the shape means running `--rasters` into a scratch folder and copying
those files over again.

**The marks are drawn once and traced everywhere.** The generated SVGs are the
masters, the Penpot boards hold the same paths, and `tom_ui` paints them by cap
height rather than by a bounding box. A mark redrawn by hand in any of those
three places has already drifted from the other two.

## Where it came from

Chosen from three wordmark concepts and some twenty icon prototypes drawn in
Penpot: the `#` of a markdown heading (reads as a hashtag), a bare node (reads
as a magnifier or a power symbol), a page with a git-branch glyph inside (the
shape that meant something, refined into one commit), and an outlined page (a
box at 16px). The decision was made at 16, 32 and 128 pixels on light and dark
bars beside a window title, which is where an icon actually lives.

---

*See also: [brand/](README.md) · [rules.md](rules.md)*
