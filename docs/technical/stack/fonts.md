# Fonts

The faces the interface is drawn in, the one its icons are, and why
they are files in the repository rather than a package.

| Family | Cuts | Drawn in |
|---|---|---|
| IBM Plex Sans | 400, 500, 600, 700 | every label, panel and control |
| IBM Plex Mono | 400, 600 | the source pane, fences, inline code |
| Public Sans | 400, 400 italic, 600, 700 | the rendered document's prose, headings and footnotes ([Decision 39](../decisions/039-the-preview-is-read-in-public-sans.md)) |
| Font Awesome Free Solid | 900 | every icon but the formatting bar's ([Decision 32](../decisions/032-the-icon-set-is-font-awesome.md)) |

- **Vendored, not fetched.** They live in `src/packages/ui/fonts/` and are declared in that package's pubspec, so both applications get them from the one package that owns the look ([Decision 26](../decisions/026-the-look-is-a-package.md)).
- **`google_fonts` is excluded**: it downloads the face on first use and caches it in the user's application-support directory. A desktop Git client works offline, and no request leaves the machine ([Decision 11](../decisions/011-telemetry-is-opt-in.md)).
- **Only the cuts the boards use are here.** A family ships nine weights; ten files answer every board.
- **Icons are a face too**: Font Awesome's solid font, reached through `TomGlyphWidget` by code point, never through Material's `Icons`.
- **The formatting bar's seventeen are not a face**: Material Symbols Outlined at weight 300, drawn from SVG paths by one painter — no font file, no dependency.
- **The terminal has no face of ours**: it draws in the platform's own monospace ([Decision 37](../decisions/037-the-terminal-is-the-persons-own-shell-in-a-pty.md)).
- **The family name carries its package** — `packages/tom_ui/IBMPlexSans`, which is what `TomFonts` holds. A style that drops the prefix falls back to the platform's own face without saying so.

## Licence

SIL Open Font License 1.1, in `src/packages/ui/fonts/OFL.txt` (Public Sans: `PublicSans-OFL.txt`) — permissive,
compatible with the project's MIT ([Decision 1](../decisions/001-license-is-mit.md)).
It asks that the files not be sold on their own and that the licence travel
with them; both hold for a font inside an application.

Font Awesome Free: icons **CC BY 4.0**, font **SIL OFL 1.1**, code MIT, in
`src/packages/ui/fonts/FontAwesome-LICENSE.txt`. CC BY asks for attribution,
which that file and [Decision 32](../decisions/032-the-icon-set-is-font-awesome.md) carry.

Material Symbols (the formatting bar's paths): **Apache-2.0**, from
`github.com/google/material-design-icons` — permissive, compatible with MIT.

## Where they came from

The static instances Google Fonts serves for each weight, which are the same
outlines as the IBM release; Public Sans's four cuts are static instances cut
with `fonttools` from Google Fonts' variable files; Font Awesome's `fa-solid-900.ttf` from the
`@fortawesome/fontawesome-free` 6.7.2 release. Replacing one is a download into `fonts/` under
the same name — nothing generates them.

---

*See also: [stack/](README.md) · [foundations](../../design/foundations/README.md)*
