# Push / pull

Keep the local space in sync with the remote, with the state of that sync always visible.

**Status:** Planned · Milestone M1

## Rules

- The UI always shows how many commits the branch is ahead of and behind the remote — and shows *nothing* where there is nothing to count, because a zero beside a zero is chrome that has to be read twice to be ignored.
- Push, pull and fetch are each a single, explicit action — never triggered automatically in the background. There is no combined *Sync*: one name for three different risks is how a tool stops being predictable.
- Only one of them runs at a time, and the screen says which. Push is unavailable when there is nothing to publish, rather than reporting it afterwards.
- **Pull is not a fourth button in the chrome.** It appears as the remedy inside the rejection, where somebody has just been told they need it.
- A push the remote rejects (someone else pushed first) is shown as a clear, named failure, not a silent no-op. The wording says who got there first, what to do about it, and — the part that actually worries people — that **nothing they committed has been lost**.
- Fetch alone never changes a file on disk; only a pull (or an explicit merge) does — and after a pull the file tree shows what arrived, because the app knows it wrote.
- A pull **merges**, and never rebases. The app decides this rather than inheriting whatever the machine happens to be configured with: merge keeps every local commit exactly where it is, which is what "nothing you committed has been lost" means, while a rebase rewrites them and can stop halfway somewhere a reader of documentation has no way out of.

## Mocks

- [push-rejected](mocks/push-rejected.excalidraw) — the remote moved first. Visual design: [light](mocks/push-rejected-light.svg) · [dark](mocks/push-rejected-dark.svg).

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
