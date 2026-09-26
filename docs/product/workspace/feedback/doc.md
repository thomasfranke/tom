# Feedback

What the app says while it is working, and when it has finished. Transversal:
every surface obeys it.

**Status:** Planned · Milestone M0

## Rules

- **Anything that takes time says it is taking time, on the control that was pressed.** The control carries the verb in progress and a spinner, and what the action is about to change is dimmed. Going quiet and disabled is not feedback: it reads the same as a click that never landed.
- **Anything that finished says it finished.** A surface returning to its resting state is not a confirmation, because that state also means nothing happened.
- **News from git is a band above the document, never a panel.** It says what was done and what is now owed, spans the document area, and is overlaid by the side columns.
- The band carries one action inline at the right and nothing else. A band with two actions is a dialog that forgot to be one.
- A failure is said where it was asked for, without the surface that asked going away — what was refused has to still be on screen.

## Mocks

Each surface draws its own: [commit succeeded](../../git-workflow/commit/confirming/doc.md),
[pushing](../../git-workflow/push-pull/README.md),
[reading a version](../../git-workflow/file-history/doc.md).

---

*See also: [workspace/](../README.md) · [components/controls.md](../../../design/components/controls.md)*
