# Type

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

## Controls use Material's scale

Not the one above — that is what the widgets ship with.

| Material style | Size | Weight | Letter-spacing |
|---|---|---|---|
| `titleLarge` | 22 | 400 | 0 |
| `bodyLarge` | 16 | 400 | 0.5 |
| `bodyMedium` | 14 | 400 | 0.25 |
| `labelLarge` | 14 | 500 | 0.1 |
| `labelSmall` | 11 | 500 | 0.5 |

- The button is the exception: **15 / 600** filled, **15 / 500** outlined, which is what Home already used.
- **IBM Plex Sans has no `↑`/`↓` outside its `regular` cut.** An arrow at weight 500 renders as nothing at all, silently, so the arrow is its own run at `regular` or it is drawn as a glyph.

---

*See also: [components/](README.md) · [controls.md](controls.md)*
