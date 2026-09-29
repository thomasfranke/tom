# The icon set

Glyphs drawn on a 16 grid with a 2px stroke and no fill, one SVG each in
[`icons/`](icons/).

| | | |
|---|---|---|
| [`folder.svg`](icons/folder.svg) | [`link.svg`](icons/link.svg) | [`search.svg`](icons/search.svg) |
| [`chevron.svg`](icons/chevron.svg) | [`check.svg`](icons/check.svg) | [`close.svg`](icons/close.svg) |
| [`plus.svg`](icons/plus.svg) | [`upload.svg`](icons/upload.svg) | [`download.svg`](icons/download.svg) |
| [`commit.svg`](icons/commit.svg) | [`push.svg`](icons/push.svg) | [`pull.svg`](icons/pull.svg) |
| [`fetch.svg`](icons/fetch.svg) | [`no-git.svg`](icons/no-git.svg) | [`preferences.svg`](icons/preferences.svg) |
| [`undo.svg`](icons/undo.svg) | [`redo.svg`](icons/redo.svg) | [`heading.svg`](icons/heading.svg) |
| [`strikethrough.svg`](icons/strikethrough.svg) | [`list.svg`](icons/list.svg) | [`ordered-list.svg`](icons/ordered-list.svg) |
| [`task-list.svg`](icons/task-list.svg) | [`quote.svg`](icons/quote.svg) | [`code.svg`](icons/code.svg) |
| [`table.svg`](icons/table.svg) | [`rule.svg`](icons/rule.svg) | [`image.svg`](icons/image.svg) |
| [`footnote.svg`](icons/footnote.svg) | [`alert.svg`](icons/alert.svg) | |

- Each is `viewBox="0 0 16 16"`, rendered at 24 with `stroke="currentColor"` — the colour is the host control's and nothing is recoloured per use.
- **These files are the source**, and the Penpot `Icon` component draws the same paths. When the two disagree these are right: a glyph is geometry, and geometry belongs in a file the build can read.
- The set grows **one glyph at a time**, never by importing a library — an icon set is a visual decision this project has not made, and importing one makes it by accident.
- The chevron is VS Code's codicon path, filled, and is aligned by its ink rather than its box — the two states carry different amounts of it, so matching the boxes makes them look unaligned.
- **`commit` is the wordmark's `O`**: a ring on the trunk, which is what a commit is ([brand](../brand/README.md)). The trunk breaks at the ring rather than crossing it — continuous, at 16, it reads as a circle struck through.
- **`undo` and `redo` are an arrow that turns back**, not the closed circle `fetch` draws: one says *the last thing you did*, the other says *ask the remote*, and at 16 points a reader has one glance to tell them apart.
- **`bold` and `italic` are not in this folder.** They are letterforms — a `B` and an `I` in the interface face — because a `B` traced on the 16 grid is worse than the letter, and the shape of the letter *is* the mark. They live in the `Icon` component as text rather than as a path.
- **Two pairs were redrawn because they looked alike**, which is this set's one hard rule: `strikethrough` was three stacked lines and read as `rule` and as `list`, so it became the `S` with the line through it; `footnote` was a number over three lines and read as `ordered-list`, so it became the raised mark over the note. Both were caught by rendering the set at 48 and looking, not by reading the `d`.
- **`fetch` is not an arrow.** An arrow says something moved, and a fetch writes nothing to disk; `pull` is the one that carries the down arrow, and the two must not look alike.
- **`preferences` is a gear, and that is the whole argument** — a toggle-and-sliders mark was tried four times and read as a list, as a rule and as a control panel. The gear is the one symbol in this set nobody has to learn, so it is the one place a convention beats an invention.
- Rendering these needs `flutter_svg`, so it is a licence check under [rule 1](../../../AGENTS.md). The alternative is each `d` attribute in a `CustomPainter`, which costs nothing.

---

*See also: [components/](README.md) · [controls.md](controls.md)*
