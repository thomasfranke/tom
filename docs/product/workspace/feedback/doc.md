# Feedback

What the app says while it is working, and when it has finished. Transversal:
every surface obeys it.

**Status:** Shipped · Milestone M0

## Rules

- **Anything that takes time says it is taking time, on the control that was pressed.** The control carries the verb in progress, and what the action is about to change is dimmed. Going quiet and disabled is not feedback: it reads the same as a click that never landed.
- **Anything that waits on the network says so for the whole column**, with a bar across the top of the panel that owns the request — a spinner on one control would say one action is slow, and not that the wait is somebody else's machine ([while a request runs](../../git-workflow/push-pull/while-a-request-runs/doc.md)).
- **Anything that finished says it finished.** A surface returning to its resting state is not a confirmation, because that state also means nothing happened.
- **News from git is a band above the document, never a panel.** It says what was done and what is now owed, spans the document area, and is overlaid by the side columns.
- **A band wears the colour of what it reports**: `added` for what worked, `modified` for a refusal, `removed` for a failure, and the accent on `accent_soft` for work still running.
- **A band for work still running carries no action** — `Exporting roadmap.pdf…` ([export](../../export/doc.md)). A git request in flight raises no band at all: its column says it.
- The band carries one action inline at the right and nothing else. A band with two actions is a dialog that forgot to be one — bar two: `Keep mine` beside `Reload`, and **`Show the command`** before the remedy of a git failure, which opens the [commands panel](../commands/doc.md) and changes nothing.
- A failure is said where it was asked for, without the surface that asked going away — what was refused has to still be on screen.
- **A refusal that found the screen out of date reads git again before it speaks** — a merge that started elsewhere, a file committed since its row was drawn — so the sentence is said over a list that is already true.
- **The state of a connection is not the outcome of an action, and it is not said in a band.** It is a line at the foot of the column that owns those controls, saying what is wrong when the link is broken and where the branch stands when it is not ([when the link is broken](../../git-workflow/push-pull/when-the-link-is-broken/doc.md)).

## Mocks

Each surface draws its own: [commit succeeded](../../git-workflow/commit/confirming/doc.md),
[pushing](../../git-workflow/push-pull/README.md),
[reading a version](../../git-workflow/file-history/doc.md).

---

*See also: [workspace/](../README.md) · [components/controls.md](../../../design/components/controls.md)*
