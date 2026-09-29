# While a request runs

What the right column shows between the press and the answer.

**Status:** Planned · Milestone M3

## Rules

- **A request in flight is a bar across the top of the git column**, not a spinner on a control — it spans the panel that owns every request, so the signal belongs to the column rather than to one button.
- **The bar means the network**, which is what a verb alone does not say: data is coming from somebody else's machine.
- **While it runs, `Push`, `Fetch` and `Pull` are unavailable.** You already asked, and a second press would queue a second request against a remote still answering the first.
- **The pressed control still names itself.** Unavailable is not silent — the button that started it reads `Pushing…`, so nothing has to guess which of the three is in flight.
- **Committing is not touched.** Staging, writing a message and committing reach no remote, so nothing about them is taken away — which is also what teaches that the bar is about the network and not about the app being busy.
- **One bar, whichever was pressed.** Git serialises the three per space, so the column is never doing two things at once and never has to say two things at once.
- **It goes when the request does**, rather than filling to the end and sitting there. Finishing is said where it was asked: a band for what arrived, the button returning to its verb ([feedback](../../../workspace/feedback/doc.md)).

## Mocks

- **talking to the remote** — the bar at the top of the column, the three controls unavailable, the pressed one naming itself. [light](../../../../design/screens/desktop/git-connection/talking-to-the-remote-light.svg) · [dark](../../../../design/screens/desktop/git-connection/talking-to-the-remote-dark.svg).
- **pushing** — the same state on the remote page: `Pushing…` on the 248-wide button, `Fetch` and `Pull` dim under it. [light](../../../../design/screens/desktop/git-remote/pushing-light.svg) · [dark](../../../../design/screens/desktop/git-remote/pushing-dark.svg).
- **pulling** — `Pulling…` on the button that was pressed, and **nothing in the band**: the column reports the request, the band reports what came of it. [light](../../../../design/screens/desktop/git-remote/pulling-light.svg) · [dark](../../../../design/screens/desktop/git-remote/pulling-dark.svg).

---

*See also: [push-pull/](../README.md) · [when the link is broken](../when-the-link-is-broken/doc.md) · [feedback](../../../workspace/feedback/doc.md)*
