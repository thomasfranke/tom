# The conflicted document

A document holding both sides of a merge, in source and in preview.

**Status:** Shipped · Milestone M3

## Rules

- **In source, the conflict is what git wrote.** `<<<<<<< HEAD`, `=======` and `>>>>>>>` stay on screen as real, selectable text; the two sides are tinted and nothing replaces them. Somebody who resolves conflicts in a terminal has to recognise what they are looking at.
- **The gutter carries the letter, as it does for a changed block.** `C` beside the line the region opens on, left of the line numbers, in the alphabet the tree and the changes list already use ([how a change is drawn](../../diff/rendered-diff/how-it-is-drawn/doc.md)).
- **In preview, the conflict is the two sides with the choice.** The region becomes two groups labelled `Current Change` and `Incoming Change`, rendered as markdown over the block containers the preview already draws, and no marker ever appears here.
- **The words are VS Code's, deliberately.** ~~`Yours` and `Theirs`~~ read as ownership, and in a merge neither side is anybody's property; more to the point, whoever resolves conflicts here has resolved them there, and a second vocabulary for the same four buttons is a second thing to learn.
- **Every mode stays open.** The preview is the easier way to read a conflict, not a mode the app switches anybody into, and not one it takes away.
- **The two sides are told apart by their labels, never by hue alone.** Both carry the same tint: `removed` would say your work is leaving and `added` would say theirs has arrived, and neither is true until somebody chooses.
- **Each region offers three: `Accept Current Change`, `Accept Incoming Change`, `Accept Both Changes`.** Three because that is what the situation has — the one who wrote first, the one who wrote after, and the two that turn out not to disagree.
- **A choice is an edit, not a save.** It rewrites the document in the buffer, removing the side that was refused and the three marker lines; the unsaved mark appears, undo puts it back, and the file on disk changes when somebody saves it.
- **The regions are read from the document's own text, and only ever offered while git reports that document conflicted.** Reading them asks git nothing, so a conflict somebody resolved in another editor simply stops having any; and a marker typed by hand into a document *about* merging stays text, because no merge is in progress ([when a pull conflicts](../../git-workflow/push-pull/when-a-pull-conflicts/doc.md)).

## Mocks

- **conflict in source** — the markers as git wrote them, both sides under one tint. [light](../../../design/screens/desktop/git-conflict/conflict-in-source-light.svg) · [dark](../../../design/screens/desktop/git-conflict/conflict-in-source-dark.svg).
- **conflict in preview** — the same region as `Current Change` and `Incoming Change`, with the three choices and no marker. [light](../../../design/screens/desktop/git-conflict/conflict-in-preview-light.svg) · [dark](../../../design/screens/desktop/git-conflict/conflict-in-preview-dark.svg).

---

*See also: [source mode](../source-mode/doc.md) · [markdown preview](../markdown-preview/doc.md) · [when a pull conflicts](../../git-workflow/push-pull/when-a-pull-conflicts/doc.md)*
