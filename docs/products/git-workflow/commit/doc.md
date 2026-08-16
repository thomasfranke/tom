# Commit

Record a snapshot of the changes made to the space, with a message.

**Status:** Planned · Milestone M1 (desktop) · Exploratory, Phase 3 post-1.0 (mobile)

## Rules — desktop

- Modified, new and deleted files show up as a visible list before anything is committed.
- Staging is simplified: everything at once, or one file at a time. There is no partial (hunk-level) staging.
- A commit requires a message. Committing with nothing staged is disabled.
- After a commit, the file list reflects that the working tree is clean again.

## Rules — mobile ("capture")

- Capture is a short note plus a commit message, not a full document editor — authoring a document on a phone is not a goal.
- The commit happens in one gesture; there is no separate staging step.
- Depends on git working without a system binary on iOS/Android, which is still an open technical question ([Decision 2](../../../decisions/002-git-via-system-binary.md) names `libgit2` via FFI as the trigger).

## Mocks

- Desktop: [committing](mocks/committing-desktop.excalidraw) — stage, describe, commit, push in one flow.
- Mobile: [capture](mocks/capture-mobile.excalidraw) — record a decision and commit it.

---

*See also: [product.md](../../../product/product.md) · [roadmap.md](../../../product/roadmap.md#phases)*
