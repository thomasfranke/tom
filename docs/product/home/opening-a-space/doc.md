# Opening a space

The three ways in, and what a folder without a repository does instead.

**Status:** Planned · Milestone M0

## Rules

- With no space open, the app offers three ways in: **choose a folder**, **clone from a URL**, or **pick a recently opened space**.
- **A space is a folder, not a repository.** TOM can open a subfolder of a repository — a `docs/` folder, say — and still run git against the repository root.
- **A folder that is not inside a git repository opens anyway**, as a space with the git column replaced by the sentence saying why it is empty ([without a repository](../../workspace/without-a-repository/doc.md)). Home refuses nothing; what it cannot do is said where it would have been done.
- That **revokes the earlier rule** that such a folder is a named failure on Home, and the board that drew the refusal is gone. Refusing it made a space mean *a repository*, and [rule 12](../../../../AGENTS.md) says it does not.
- **TOM never creates a repository on the user's behalf.**

## Mocks

- **empty state** — the three ways in. [light](../../../design/screens/desktop/home/empty-state-light.svg) · [dark](../../../design/screens/desktop/home/empty-state-dark.svg).
- **no repository** — where the old refusal went: the space open, the message in the right column. [light](../../../design/screens/desktop/git-not-git/no-repository-light.svg) · [dark](../../../design/screens/desktop/git-not-git/no-repository-dark.svg).

---

*See also: [home/](../README.md) · [cloning/](../cloning/doc.md) · [Decision 9](../../../technical/decisions/009-space-session-is-single-source-of-truth.md)*
