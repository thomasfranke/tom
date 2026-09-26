# Change marks

What the tree says about a file git has something to say about.

**Status:** Planned · Milestone M0

## Rules

- **A changed file carries its letter at the right of its row**, in the same alphabet the changes column uses: `M` modified, `A` added, `R` removed, `N` untracked.
- The tree and the [changes list](../../../git-workflow/commit/the-changes-list/doc.md) never disagree about what happened to a file.
- **The letter is the signal, not the colour.** A row's name keeps its own colour, so the mark never competes with the open document's highlight and two kinds of change are never told apart by hue alone.
- **A folder carries a dot when something inside it changed**, whatever the change is. A folder cannot show letters for files it is not showing, and opening it is what says which.

Colour alone cannot tell added from untracked, and cannot survive the open row's
highlight — which is why the letter, out of six treatments prototyped.

---

*See also: [file-tree/](../README.md) · [how a diff is drawn](../../../diff/rendered-diff/how-it-is-drawn/doc.md) · [components/controls.md](../../../../design/components/controls.md)*
