# The controls

Two buttons, and where the numbers live.

**Status:** Planned · Milestone M1

## Rules

- **The counts live inside the buttons that act on them**: `Push ↑ (2)` is two commits to publish, `Fetch ↓ (3)` three that arrived. The arrow sits between the verb and the count, outside the parentheses, so the parentheses hold nothing but the number.
- There is no separate drift indicator in the chrome — a number beside a button that already owns it is the same fact twice.
- A button with nothing to count names only its action. `Push` with nothing to publish carries no arrow and no number and is unavailable; `Fetch` with nothing waiting carries neither either.
- The status bar says the same thing in words, `2 ahead, 3 behind`, and that is the only place the words appear. One fact, one wording per surface.
- Push, pull and fetch are each a single, explicit action, never triggered automatically in the background. **There is no combined *Sync*** — one name for three different risks is how a tool stops being predictable.
- Only one of them runs at a time, and the screen says which ([feedback](../../../workspace/feedback/doc.md)).
- **Pull is not a fourth button.** It appears as the remedy inside the rejection, where somebody has just been told they need it ([when-it-fails](../when-it-fails/doc.md)).

A bare `↑ 2 ↓ 0` in the chrome was the earlier arrangement, and it taught a
convention that only git explains.

---

*See also: [push-pull/](../README.md) · [components/controls.md](../../../../design/components/controls.md)*
