# Design

What the product looks like, and the rules that decide it.

**Normative.** Nothing the user can see is written before it is approved in
the Penpot file, and nothing merges before its board is exported here
([AGENTS.md](../../AGENTS.md) rule 13).

| | |
|---|---|
| [`visual-language/`](visual-language/README.md) | The colour system: eighteen roles, light and dark, and why they are roles rather than shades |
| [`brand/`](brand/README.md) | The identity — icon, wordmark, lockup — and the generated SVG masters |
| [`components/`](components/README.md) | The control set with the exact numbers, and the library every screen places instances from |
| [`foundations/`](foundations/README.md) | The library page as drawn: the palette and the type scale |
| [`screens/`](screens/README.md) | Every screen the app has, both themes, one folder per Penpot page — whole windows, and one component alone in each of its states |
| [`site/`](site/README.md) | The landing page |
| [`tools/`](tools/README.md) | The palette, the marks, the script that makes an SVG export self-contained, and the four that measure a board against the app without opening Penpot (`render.py`, `pixels.py`, `bbox.py`, `compare.py`) |
| [`penpot-backlog.md`](penpot-backlog.md) | The Penpot file page by page: which folder each page is exported to, and what the file still owes |
| `TOM.penpot` | The editable file as a local backup — kept out of git, because an opaque binary of that size would be a new blob in history at every save |

- The Penpot file is the source; the export in this folder is the record, and it is never edited by hand.
- **A screen is approved in Penpot before its code is written, and exported before the change merges.** The export happens only when the maintainer asks for it, so a board can be approved and built while its SVG is still owed — the [backlog](penpot-backlog.md) says which.
- When this chapter and the theme disagree, the theme is right — the canonical form of a rule is the dartdoc of the code that implements it.
- How a screen is designed, exported and checked against the running app is the [`tom-design`](../../.ai/skills/tom-design/SKILL.md) skill, not this chapter.

---

*See also: [product/](../product/README.md) · [technical/](../technical/README.md) · [roadmap.md](../roadmap.md)*
