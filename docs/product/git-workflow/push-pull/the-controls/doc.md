# The controls

Three buttons, and where the numbers live.

**Status:** Shipped · Milestone M3

## Rules

- **The three buttons live at the foot of the git column, under the commit button**, in the order the work happens: stage, describe, commit, then publish. The top bar carries no git action, because a button that acts on the repository belongs beside what it acts on.
- **`Push` spans the column; `Fetch` and `Pull` share the row under it.** Publishing is the action the column was built for, so it gets the width; the two that only bring news are half as wide and equal to each other.
- **With the git column closed they are not drawn at all** — they belong to the column, not to the window, and a button floating where its column used to be is a button with nothing behind it. Closing the column is not a way to lose them: the gutter at the window's edge brings the column back ([columns](../../../workspace/columns/doc.md)).
- **The counts live inside the buttons that act on them**, each as a [count](../../../../design/components/controls.md) pill after the verb: `Push` with `2` is two commits to publish, `Pull` with `3` three waiting to arrive. The number is never set in parentheses.
- **The arrow is a glyph before the verb, not a character inside the label** — drawn as an icon it keeps the label a plain word. `Fetch` carries the same glyph vocabulary — up to publish, down to bring back, a circle to ask.
- **`Fetch` never carries a count.** It is the button somebody presses *to find out*, and a number on it would be the answer to the question it asks.
- **Until somebody fetches, only what is ahead is known** — what is behind is counted against the last fetch, never guessed.
- There is no separate drift indicator beside the buttons — a number beside a button that already owns it is the same fact twice. The [status bar](../../../workspace/status-bar/doc.md)'s `↑ ↓` is the one elsewhere.
- A button with nothing to count names only its action. `Push` with nothing to publish keeps its arrow, carries no number and is unavailable — a label that loses its icon changes shape under the pointer; `Fetch` with nothing waiting carries no number either.
- **The status bar draws the drift as glyphs and numbers, `↑ 2 ↓ 3`; the words live at the column's foot**, under `Fetch` and `Pull` — `2 behind origin/main` ([when the link is broken](../when-the-link-is-broken/doc.md)). One fact, one wording per surface.
- Push, pull and fetch are each a single, explicit action, never triggered automatically in the background. **There is no combined *Sync*** — one name for three different risks is how a tool stops being predictable.
- Only one of them runs at a time, and the screen says which ([feedback](../../../workspace/feedback/doc.md)).
- **`Pull` is a button of its own**, the second on the bottom row. Kept only inside the rejection, the one way to catch up would be to be refused first — a remedy dressed as a feature.
- **The rejection still offers `Pull` inline**, and that is not the same control twice: the band's is the answer to what just happened, the column's is the action available at any time ([when-it-fails](../when-it-fails/doc.md)).
- **`Push` on a branch the remote does not have yet publishes it**: the branch is created on `origin` and followed from then on, with no second control and no question.

## Mocks

- **nothing to push** — the three buttons naming only their action, `Push` dim. [light](../../../../design/screens/desktop/git-push/push-the-git-column-states-light.svg) · [dark](../../../../design/screens/desktop/git-push/push-the-git-column-states-dark.svg).
- **push — the git column** — commits to publish · nothing to push · pushing. [light](../../../../design/screens/desktop/git-push/push-the-git-column-states-light.svg) · [dark](../../../../design/screens/desktop/git-push/push-the-git-column-states-dark.svg).

---

*See also: [push-pull/](../README.md) · [components/controls.md](../../../../design/components/controls.md)*
