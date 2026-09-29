# The controls

Three buttons, and where the numbers live.

**Status:** Planned · Milestone M1

## Rules

- **The three buttons live at the foot of the git column, under the commit button**, in the order the work happens: stage, describe, commit, then publish. The top bar carries no git action, because a button that acts on the repository belongs beside what it acts on.
- **`Push` spans the column; `Fetch` and `Pull` share the row under it.** Publishing is the action the column was built for, so it gets the width; the two that only bring news are half as wide and equal to each other.
- **With the git column closed they are not drawn at all** — they belong to the column, not to the window, and a button floating where its column used to be is a button with nothing behind it. Closing the column is not a way to lose them: the [grip](../../../workspace/columns/doc.md) at the window's edge brings the column back.
- **The counts live inside the buttons that act on them**: `Push (2)` is two commits to publish, `Pull (3)` three waiting to arrive. The verb and the number, with nothing between them.
- **The arrow is a glyph before the verb, not a character inside the label.** ~~`Push ↑ (2)`~~ put it between the two; drawing it as an icon keeps the label a plain sentence and leaves the parentheses holding nothing but the number. `Fetch` carries the same glyph vocabulary — up to publish, down to bring back, a circle to ask.
- **`Fetch` never carries a count.** It is the button somebody presses *to find out*, and a number on it would be the answer to the question it asks.
- There is no separate drift indicator in the chrome — a number beside a button that already owns it is the same fact twice.
- A button with nothing to count names only its action. `Push` with nothing to publish carries no arrow and no number and is unavailable; `Fetch` with nothing waiting carries neither either.
- The status bar says the same thing in words, `2 ahead, 3 behind`, and that is the only place the words appear. One fact, one wording per surface.
- Push, pull and fetch are each a single, explicit action, never triggered automatically in the background. **There is no combined *Sync*** — one name for three different risks is how a tool stops being predictable.
- Only one of them runs at a time, and the screen says which ([feedback](../../../workspace/feedback/doc.md)).
- ~~**Pull is not a button of its own**~~ — it is the second one on the bottom row. Keeping it only inside the rejection meant the one way to catch up was to be refused first, which is a remedy dressed as a feature.
- **The rejection still offers `Pull` inline**, and that is not the same control twice: the band's is the answer to what just happened, the column's is the action available at any time ([when-it-fails](../when-it-fails/doc.md)).

A bare `↑ 2 ↓ 0` in the chrome was the earlier arrangement, and it taught a
convention that only git explains.

---

*See also: [push-pull/](../README.md) · [components/controls.md](../../../../design/components/controls.md)*
