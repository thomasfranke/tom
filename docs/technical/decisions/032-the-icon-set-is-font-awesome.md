# Decision 32 — The icon set is Font Awesome Free Solid

**Status:** accepted, on the maintainer's call after comparing four sets side by side. It revokes the rule in [`icons.md`](../../design/components/icons.md) that the set "grows one glyph at a time, never by importing a library".

## Context

The app drew its own set: glyphs traced on a 16 grid, stroked, painted from each SVG's `d` in a `CustomPainter`. Two things went wrong with it.

- **The stroke scaled with the shape.** The grid's 2 was painted at 3 points in a 24 cell, which is what made the toolbar look heavy and blurred. Fixing it brought the app in line with the boards — and the boards were then judged the problem too.
- **The drawing itself did not hold up.** Next to Lucide, Phosphor and Font Awesome, at the toolbar's own size and colours, the hand-drawn set read as the weakest of the four. A set nobody on the project draws for a living keeps losing that comparison as it grows.

## Decision

**Every glyph in the interface is a character of Font Awesome Free 6 Solid**, vendored as a font in `src/packages/ui/fonts/` and reached only through `TomGlyphWidget` and `TomGlyphEnum`.

- **Vendored, not a package.** The face sits beside the three IBM Plex faces and is declared in `tom_ui`'s pubspec, so the set costs no dependency and nothing is fetched at runtime — the same reasons `google_fonts` is excluded ([fonts](../stack/fonts.md)).
- **Solid, not regular.** Font Awesome Free has no regular cut for most of the formatting glyphs, and a set that mixes the two is two sets.

  > **Revised (2026-10-08).** An outline is the same Solid glyph with its edge stroked (1.25, no fill), not a regular cut — Font Awesome Free has no regular house or gear. The top bar's house and gear are drawn that way on the approved boards; `TomGlyphWidget(outline: true)` is the one way to ask for it.
- **One enum, named for what a glyph does here** (`push`, `fetch`, `footnote`), never for what Font Awesome calls it, so swapping a glyph is one line and no screen changes.
- **`bold` and `italic` are glyphs again**, not letterforms in the serif: they come from the same set as their neighbours.
- **No Material `Icons`** anywhere in the app: a second set is how the hand-drawn one ended up beside Material's `close` and `check`.

**Revised (2026-10-11):** the formatting bar's seventeen glyphs are **Material Symbols Outlined at weight 300**, because Font Awesome Solid read as bold at the bar's size; everything else stays Font Awesome Solid.

- **Drawn, not a font**: each is a hand-written SVG path in `docs/design/components/icons/toolbar/<name>.svg`, turned into `tom_toolbar_outlines.dart` by `docs/design/tools/toolbar_outlines.py` and painted by one painter (`TomOutline`) — no font file, no dependency.
- **Still one door**: `TomGlyphWidget` and `TomGlyphEnum` answer for them too, so no screen knows which set a glyph is from.
- **Replacing one is a file**: drop a new SVG over the old and run the script.
- **Licence**: Material Symbols is Apache-2.0 ([fonts](../stack/fonts.md)).

## Licence

Font Awesome Free's **icons are CC BY 4.0**, its **font files SIL OFL 1.1** and its code MIT — none of them copyleft, all compatible with the project's MIT ([Decision 1](001-license-is-mit.md)). CC BY asks for attribution: `FontAwesome-LICENSE.txt` travels beside the font, and [fonts](../stack/fonts.md) names it.

## Consequences

- The `Icon` component in Penpot is redrawn from the same glyphs and every board re-exported, so the app and the boards keep one set between them ([rule 13](../../../AGENTS.md)).
- `docs/design/components/icons/*.svg` stop being the source; the face is.
- The panel toggles and the theme toggle stay drawn: they are controls with a state, not glyphs, and Font Awesome has nothing that says *this column is open*.
