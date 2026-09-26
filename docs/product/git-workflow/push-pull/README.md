# Push / pull

Keep the local space in sync with the remote, with the state of that sync always
visible.

**Status:** Planned · Milestone M1

| | |
|---|---|
| [`the-controls/`](the-controls/doc.md) | The two buttons, the counts inside them, and what the status bar says instead |
| [`what-each-does/`](what-each-does/doc.md) | Fetch against pull, and why a pull merges |
| [`when-it-fails/`](when-it-fails/doc.md) | The rejection, the unreachable remote, and where both are said |

## Mocks

- **nothing to push** — both buttons naming only their action, and the status bar saying the space is level with the remote. [light](../../../design/screens/desktop/git-remote/nothing-to-push-light.svg) · [dark](../../../design/screens/desktop/git-remote/nothing-to-push-dark.svg).
- **pushing** — the verb in progress and a spinner on the button that was pressed. [light](../../../design/screens/desktop/git-remote/pushing-light.svg) · [dark](../../../design/screens/desktop/git-remote/pushing-dark.svg).
- **push rejected** — the remote moved first, said in the band with `Pull` as its one action. [light](../../../design/screens/desktop/git-remote/push-rejected-light.svg) · [dark](../../../design/screens/desktop/git-remote/push-rejected-dark.svg).
- **push failed** — the remote could not be reached: the same band, `Try again`, nothing published. [light](../../../design/screens/desktop/git-remote/push-failed-light.svg) · [dark](../../../design/screens/desktop/git-remote/push-failed-dark.svg).

---

*See also: [product/](../../README.md) · [commit](../commit/README.md) · [roadmap.md](../../../roadmap.md)*
