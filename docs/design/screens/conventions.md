# Conventions

What a board is named, where it lives, and what it may carry. The boards
themselves are [`README.md`](README.md).

## Naming and layout

- A whole window is two files, always both — `<screen>-light.svg` and `<screen>-dark.svg` — named in kebab-case with no platform suffix; the folder already says `desktop`.
- A states board is two files as well, `<component>-states-light.svg` and `<component>-states-dark.svg`; a doc that links one names the state inside it.
- **A page is one flow, read in order, and one folder.** It is split when two flows start sharing it, or when it passes eight screens — a card that scrolls is no longer read at once.
- **The first row of a page is a whole window; after it, a row that varies one component draws that component alone, in every state**, both themes — the rest of the window would be identical, and twelve identical windows are twelve to sweep when the shell changes.
- **A states board records where its piece sits in the window** — `x, y · w × h`, in its notes under *Where it sits* — which is the rectangle the app's frame is cropped to when a state is measured.
- A page is cited by its name, never by its number — the number is its place in the file and moves when a page is added.
- Splitting is the one page operation with a real cost: the plugin cannot move a shape between pages, and duplicating a page that holds main instances duplicates the components. Count `library.local.components` before and after.

## What a board may carry

- **The card is not the screen.** The card around a page's boards — title, both themes, the notes saying why each screen exists — is read in the Penpot file and is not exported; the SVG is the board alone, to check the app against.
- Nothing is annotated onto a board; what a screen is for is said in the card around it — a picture crowded with explanation stops being a design and starts being a diagram nobody updates.
- A board carries no milestone chip. A note to the team dressed as part of the product is the one thing a visual design must not do; the [roadmap](../../roadmap.md) is where a milestone lives.
- **What a board is drawn to is [`measurements.md`](measurements.md)** — the shell, the column's foot, the row above the document, and the two numbers the reader controls.

## Exporting

- **A screen is approved in Penpot before its code is written, and exported before the change merges.** An export is a photograph, correct on the day it was taken and silent about the day after.
- **The export happens only when the maintainer asks for it** — it is slow and locks the file, so it is never a step of building a feature. What waits for it is the [Penpot backlog](../penpot-backlog.md).
- The `Prototypes` page is never exported: the repository holds what the product is, not the road to it.
- Every export runs through [`tools/embed_fonts.py`](../tools/embed_fonts.py). Penpot points its `@font-face` rules at its own font proxy, so without it the text falls back to whatever font is at hand and the file looks finished while being wrong.
- The record lives here rather than in Penpot because the free plan keeps seven days of version history, and the repository is the copy that survives.

---

*See also: [screens/](README.md) · the [`tom-design`](../../../.ai/skills/tom-design/SKILL.md) skill*
