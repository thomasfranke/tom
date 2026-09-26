# Opening a space

The three ways in, and the one way it fails.

**Status:** Planned · Milestone M0

## Rules

- With no space open, the app offers three ways in: **choose a folder**, **clone from a URL**, or **pick a recently opened space**.
- **A space is a folder, not a repository.** TOM can open a subfolder of a repository — a `docs/` folder, say — and still run git against the repository root.
- Opening a folder that is not inside a git repository is a **named failure** with a clear explanation, not a crash and not a silent limited mode.
- **TOM never creates a repository on the user's behalf.**

## Mocks

- **not a Git repository** — [light](../../../design/screens/desktop/home/not-a-repository-light.svg) · [dark](../../../design/screens/desktop/home/not-a-repository-dark.svg).

---

*See also: [home/](../README.md) · [cloning/](../cloning/doc.md) · [Decision 9](../../../technical/decisions/009-space-session-is-single-source-of-truth.md)*
