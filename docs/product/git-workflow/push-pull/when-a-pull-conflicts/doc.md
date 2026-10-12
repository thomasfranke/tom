# When a pull conflicts

A pull that started, stopped in the middle, and left the repository holding
both sides.

**Status:** Shipped · Milestone M3 — Planned: the `TO RESOLVE` section and the foot's `Merging …` line

## Rules

- **A pull that stops in the middle is a state with a name, not an error.** The band says the pull stopped, how many documents conflict, and that nothing committed has been lost — a merge rewrites no commit, which is why a pull merges ([what each one does](../what-each-does/doc.md)).
- **The state belongs to the repository, not to the pull.** It survives the window being closed and reopened, so it is read from git rather than remembered from the action that caused it.
- **Only a merge is recognised.** A rebase, a cherry-pick or a revert that stopped in the terminal shows its documents as `C` in the tree and the list, and raises no band — nothing here ends one.
- **While the merge is open the git column says so twice**: the conflicted documents head the list as `TO RESOLVE` ([the changes list](../../commit/the-changes-list/doc.md)), and the foot reads `Merging origin/main` where the branch's standing was — `Merging origin/main — ready to commit` once nothing is left to resolve.
- **The band's one action is `Abort the pull`**, and it goes through a confirmation that says what it undoes: the space returns to what it was before the pull, and what arrived from the remote stays fetched.
- **Resolving is editing the document**, which is [its own subject](../../../editor/conflicted-document/doc.md). Nothing in this band resolves anything.
- **Concluding the merge is a commit, not a fourth button.** The message box arrives filled with the message git already wrote for the merge, editable like any other.
- **A document still holding a marker cannot be staged**, and the refusal names the document, in `removed` above the message box: `roadmap.md still holds a conflict marker — resolve it, then stage.` Several are counted: `2 documents still hold a conflict marker — resolve them, then stage.` That is this product's rule, not git's: git will record a marker somebody staged, and a conflict marker committed into documentation is read by everyone who opens the file next.
- **One marker line left is enough to refuse** — `<<<<<<<`, `=======`, `>>>>>>>`, or the `|||||||` git writes above the base ([the conflicted document](../../../editor/conflicted-document/doc.md)); a half-resolved document is still a conflicted one. Nothing is staged when any of the documents asked for is refused.
- **A conflicted file beside the space is read and refused like one inside it** — the list is the repository's, and so is the commit the marker would go into.
- The rule is that narrow on purpose — only a path git reports as conflicted, only while the merge is in progress. Outside that, `<<<<<<<` is ordinary text, and this repository's own documentation contains it.
- **The tree and the changes list agree: a conflicted document is `C` in both** ([change marks](../../../navigation/file-tree/change-marks/doc.md)).
- **Nothing git already refuses is refused earlier.** Switching branches, pushing and pulling again stay git's own answer, reported rather than predicted.

## Mocks

- **pull conflicted** — the band and its one action, `C` in the tree and in the list, the commit button unavailable, and the merge message git wrote already in the box. [light](../../../../design/screens/desktop/git-pull/pull-conflicted-light.svg) · [dark](../../../../design/screens/desktop/git-pull/pull-conflicted-dark.svg).
- **aborting the pull** — the confirmation, and what it says it undoes. [light](../../../../design/screens/desktop/git-conflict/aborting-the-pull-the-question-states-light.svg) · [dark](../../../../design/screens/desktop/git-conflict/aborting-the-pull-the-question-states-dark.svg).
- **merge resolved** — the other end: no `C` anywhere, the merge message still in the box, and `Commit to <branch>` live under *2 of 3 staged*. [light](../../../../design/screens/desktop/git-conflict/merge-resolved-light.svg) · [dark](../../../../design/screens/desktop/git-conflict/merge-resolved-dark.svg).
- **staging a document that still holds a marker** — the refusal above the message box, the conflict still on screen. [light](../../../../design/screens/desktop/git-conflict/staging-a-document-that-still-holds-a-marker-states-light.svg) · [dark](../../../../design/screens/desktop/git-conflict/staging-a-document-that-still-holds-a-marker-states-dark.svg).
- The document itself is [conflicted-document](../../../editor/conflicted-document/doc.md)'s, on the same page.

---

*See also: [push-pull/](../README.md) · [when it fails](../when-it-fails/doc.md) · [the conflicted document](../../../editor/conflicted-document/doc.md)*
