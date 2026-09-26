# Conventions

What a board is named, where it lives, and what it may carry. The boards
themselves are [`README.md`](README.md).

## Naming and layout

- One screen is two files, always both, named in kebab-case with no platform suffix — the folder already says `desktop`.
- A product group is one Penpot page and one folder; git is one page per feature, because that group alone carries more than a dozen screens.
- A page is split once it passes about four screens — past that it scrolls beyond reading and stops working as a card.
- `<page>.pdf` is the whole page as one sheet: the title, both themes, and what each screen is for.

## What a board may carry

- **The card is not the screen.** Read the PDF to understand a set, the SVG to check the app against one screen.
- Nothing is annotated onto a board; what a screen is for is said in the card around it — a picture crowded with explanation stops being a design and starts being a diagram nobody updates.
- A board carries no milestone chip. A note to the team dressed as part of the product is the one thing a visual design must not do; the [roadmap](../../roadmap.md) is where a milestone lives.
- The chrome does not move between screens: the columns are the same width everywhere they appear, and screens that disagree are wrong about it, not the app.

## Exporting

- A PR that changes what a screen looks like re-exports it in the same commit — an export is a photograph, correct on the day it was taken and silent about the day after.
- Every export runs through [`tools/embed_fonts.py`](../tools/embed_fonts.py). Penpot points its `@font-face` rules at its own font proxy, so without it the text falls back to whatever font is at hand and the file looks finished while being wrong.
- The record lives here rather than in Penpot because the free plan keeps seven days of version history, and the repository is the copy that survives.

---

*See also: [screens/](README.md) · the [`tom-design`](../../../.ai/skills/tom-design/SKILL.md) skill*
