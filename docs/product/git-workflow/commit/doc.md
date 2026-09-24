# Commit

Record a snapshot of the changes made to the space, with a message.

**Status:** Planned · Milestone M1 (desktop) · Exploratory, Phase 3 post-1.0 (mobile)

## Rules — desktop

- Modified, new and deleted files show up as a visible list before anything is committed.
- **The list is the repository's, not the space's.** A commit records the index, so a file staged outside the space would go in whether or not it were drawn — and a list that hid it would be worse than a long one. Each row says what happened with a letter as well as a colour.
- Staging is simplified: everything at once, or one file at a time. There is no partial (hunk-level) staging.
- A commit requires a message. Committing with nothing staged is disabled.
- After a commit, the file list reflects that the working tree is clean again.
- An operation git refused says so where it was asked for, without the list going away — what was refused has to still be on screen.
- The message box is never taken away. Git working on something else is not a reason to interrupt a sentence, and a message typed while it was working is not lost when the answer comes back.

## Rules — mobile ("capture")

- Capture is a short note plus a commit message, not a full document editor — authoring a document on a phone is not a goal.
- The commit happens in one gesture; there is no separate staging step.
- Depends on git working without a system binary on iOS/Android, which is still an open technical question ([Decision 2](../../../technical/decisions/002-git-via-system-binary.md) names `libgit2` via FFI as the trigger).

## Mocks

- Desktop: [committing](mocks/committing-desktop.excalidraw) — stage, describe, commit, push in one flow. Visual design: [light](mocks/committing-desktop-light.svg) · [dark](mocks/committing-desktop-dark.svg).
- Mobile: [capture](mocks/capture-mobile.excalidraw) — record a decision and commit it.

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md#phases)*
