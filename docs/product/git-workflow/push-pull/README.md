# Push / pull

Keep the local space in sync with the remote, with the state of that sync always
visible.

**Status:** Planned · Milestone M1

| | |
|---|---|
| [`the-controls/`](the-controls/doc.md) | The three buttons, the counts inside them, and what the status bar says instead |
| [`what-each-does/`](what-each-does/doc.md) | Fetch against pull, and why a pull merges |
| [`when-it-works/`](when-it-works/doc.md) | What a pull says when the commits arrived |
| [`when-it-fails/`](when-it-fails/doc.md) | The rejection, the unreachable remote, and where both are said |
| [`when-a-pull-conflicts/`](when-a-pull-conflicts/doc.md) | A pull that stopped in the middle, and how the merge ends |
| [`while-a-request-runs/`](while-a-request-runs/doc.md) | The bar across the top of the column, and what it takes away while it runs |
| [`when-the-link-is-broken/`](when-the-link-is-broken/doc.md) | The line at the foot of the column: no network, credentials, no remote, no answer |

## Mocks

- **nothing to push** — the three buttons naming only their action, `Push` dim, and the status bar saying the space is level with the remote. [light](../../../design/screens/desktop/git-remote/nothing-to-push-light.svg) · [dark](../../../design/screens/desktop/git-remote/nothing-to-push-dark.svg).
- **pushing** — `Pushing…` on the button that was pressed, the other two unavailable, the bar across the column's head. [light](../../../design/screens/desktop/git-remote/pushing-light.svg) · [dark](../../../design/screens/desktop/git-remote/pushing-dark.svg).
- **pulling** — the same three states with `Pulling…`, and **no band**: while a request runs the column reports it, not the band ([while a request runs](while-a-request-runs/doc.md)). [light](../../../design/screens/desktop/git-remote/pulling-light.svg) · [dark](../../../design/screens/desktop/git-remote/pulling-dark.svg).
- **push rejected** — the remote moved first, said in the band with `Pull` as its one action. [light](../../../design/screens/desktop/git-remote/push-rejected-light.svg) · [dark](../../../design/screens/desktop/git-remote/push-rejected-dark.svg).
- **push failed** — the remote could not be reached: the same band, `Try again`, nothing published. [light](../../../design/screens/desktop/git-remote/push-failed-light.svg) · [dark](../../../design/screens/desktop/git-remote/push-failed-dark.svg).
- **pull conflicted** — the pull stopped mid-merge: the band with `Abort the pull`, `C` in the tree and the list, and the merge message already in the box. [light](../../../design/screens/desktop/git-remote/pull-conflicted-light.svg) · [dark](../../../design/screens/desktop/git-remote/pull-conflicted-dark.svg).

---

*See also: [product/](../../README.md) · [commit](../commit/README.md) · [pull request](../pull-request/README.md) · [roadmap.md](../../../roadmap.md)*
