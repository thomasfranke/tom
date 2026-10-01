# Git workflow

Everything the product does against a repository: recording a change, moving
between branches, reading what came before, and exchanging both with a remote.

**Status:** Planned · Milestones M1–M3

Git runs through the system binary and is never predicted — what the app shows
is what git answered ([Decision 2](../../technical/decisions/002-git-via-system-binary.md)).
The rendered comparison that makes those answers readable is
[`diff/`](../diff/README.md); this group is the actions around it.

| | |
|---|---|
| [`commit/`](commit/README.md) | The changes list, the message, and confirming it |
| [`branch-switch/`](branch-switch/doc.md) | Moving between branches, and starting one |
| [`file-history/`](file-history/doc.md) | The commits that touched the open document |
| [`push-pull/`](push-pull/README.md) | The controls, what each does, and every way the link fails |
| [`pull-request/`](pull-request/README.md) | Writing and opening the request for the branch just pushed |

---

*See also: [product/](../README.md) · [diff/](../diff/README.md) · [workspace/regions/](../workspace/regions/doc.md)*
