# Fonts

The three faces the interface is drawn in, and why they are files in the
repository rather than a package.

| Family | Cuts | Drawn in |
|---|---|---|
| IBM Plex Sans | 400, 500, 600, 700 | every label, panel and control |
| IBM Plex Mono | 400, 600 | the source pane, fences, inline code |
| IBM Plex Serif | 400, 600 | the rendered document's prose |

- **Vendored, not fetched.** They live in `src/packages/ui/fonts/` and are declared in that package's pubspec, so both applications get them from the one package that owns the look ([Decision 26](../decisions/026-the-look-is-a-package.md)).
- **`google_fonts` is excluded**: it downloads the face on first use and caches it in the user's application-support directory. A desktop Git client works offline, and no request leaves the machine ([Decision 11](../decisions/011-telemetry-is-opt-in.md)).
- **Only the cuts the boards use are here.** A family ships nine weights; eight files answer every board.
- **The family name carries its package** — `packages/tom_ui/IBMPlexSans`, which is what `TomFonts` holds. A style that drops the prefix falls back to the platform's own face without saying so.

## Licence

SIL Open Font License 1.1, in `src/packages/ui/fonts/OFL.txt` — permissive,
compatible with the project's MIT ([Decision 1](../decisions/001-license-is-mit.md)).
It asks that the files not be sold on their own and that the licence travel
with them; both hold for a font inside an application.

## Where they came from

The static instances Google Fonts serves for each weight, which are the same
outlines as the IBM release. Replacing one is a download into `fonts/` under
the same name — nothing generates them.

---

*See also: [stack/](README.md) · [foundations](../../design/foundations/README.md)*
