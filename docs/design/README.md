# Design

What the product looks like, and the rules that decide it.

**Normative.** Nothing the user can see is written before it exists here
([AGENTS.md](../../AGENTS.md) rule 13).

| | |
|---|---|
| [`visual-language/`](visual-language/README.md) | The colour system: sixteen roles, light and dark, and why they are roles rather than shades |
| [`brand/`](brand/README.md) | The identity — icon, wordmark, lockup — and the generated SVG masters |
| [`components/`](components/README.md) | The control set with the exact numbers, and the library every screen places instances from |
| [`foundations/`](foundations/README.md) | The library page as drawn: the palette and the type scale |
| [`screens/`](screens/README.md) | Every screen the app has, both themes, one folder per Penpot page |
| [`site/`](site/README.md) | The landing page |
| [`tools/`](tools/) | The palette, the marks, and the script that makes an SVG export self-contained |
| `TOM.penpot` | The editable file as a backup — opaque binary, committed when a set of screens settles |

- The Penpot file is the source; the export in this folder is the record. A board nobody exported does not count as designed.
- When this chapter and the theme disagree, the theme is right — the canonical form of a rule is the dartdoc of the code that implements it.
- How a screen is designed, exported and checked against the running app is the [`tom-design`](../../.ai/skills/tom-design/SKILL.md) skill, not this chapter.

---

*See also: [product/](../product/README.md) · [technical/](../technical/README.md) · [roadmap.md](../roadmap.md)*
