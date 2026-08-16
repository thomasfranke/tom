# Push / pull

Keep the local space in sync with the remote, with the state of that sync always visible.

**Status:** Planned · Milestone M1

## Rules

- The UI always shows how many commits the branch is ahead of and behind the remote.
- Push, pull and fetch are each a single, explicit action — never triggered automatically in the background.
- A push the remote rejects (someone else pushed first) is shown as a clear, named failure, not a silent no-op.
- Fetch alone never changes a file on disk; only a pull (or an explicit merge) does.

## Mocks

- [push-rejected](mocks/push-rejected.excalidraw) — the remote moved first.

---

*See also: [product.md](../../../product/product.md) · [roadmap.md](../../../product/roadmap.md)*
