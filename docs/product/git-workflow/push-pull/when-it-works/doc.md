# When it works

What a pull says when the commits arrived, and what a push says when they went.

**Status:** Shipped · Milestone M3

## Rules

- **A pull that arrived says so, and says how many.** A column going quiet is not a confirmation: it looks exactly like a pull that found nothing ([feedback](../../../workspace/feedback/doc.md)).
- **The band's one action is `Push`, and only when there is something to publish.** It closes the chain a refusal opens — refused, pull, push — one gesture per step, with no combined *Sync* anywhere in it.
- **What is still to publish counts the merge the pull made**: `2 of yours are still to publish.` includes the merge commit, because it is a commit the remote does not have.
- **A pull that found nothing still answers.** It says the space is already level with the remote, and offers nothing, because there is nothing to offer.
- **A push that landed says so**: `Published 2 commits to origin/<branch>.`, in `added`, with no action — a button returning to `Push` looks exactly like a push that never left.
- **A pull in flight says so on the button that was pressed**, under a bar across the column's head, and not in the band: the control is what reports ([while a request runs](../while-a-request-runs/doc.md)).
- **The news goes when the next thing happens**, not on a timer. A band that vanishes on its own is a sentence somebody was still reading.

## Mocks

- **pulling** — the pull in flight: `Pulling…` on the button, the bar above the column, and nothing in the band yet. [light](../../../../design/screens/desktop/git-pull/pulling-light.svg) · [dark](../../../../design/screens/desktop/git-pull/pulling-dark.svg).
- **pull worked** — the band in `added`, the count, and `Push` while something of yours is still to publish. [light](../../../../design/screens/desktop/git-pull/after-a-pull-or-a-fetch-the-band-states-light.svg) · [dark](../../../../design/screens/desktop/git-pull/after-a-pull-or-a-fetch-the-band-states-dark.svg).
- **already up to date** — the same band, saying nothing arrived, offering nothing. [light](../../../../design/screens/desktop/git-pull/after-a-pull-or-a-fetch-the-band-states-light.svg) · [dark](../../../../design/screens/desktop/git-pull/after-a-pull-or-a-fetch-the-band-states-dark.svg).
- **after a push — the band** — its first state, `It worked`. [light](../../../../design/screens/desktop/git-push/after-a-push-the-band-states-light.svg) · [dark](../../../../design/screens/desktop/git-push/after-a-push-the-band-states-dark.svg).

---

*See also: [push-pull/](../README.md) · [when it fails](../when-it-fails/doc.md) · [feedback](../../../workspace/feedback/doc.md)*
