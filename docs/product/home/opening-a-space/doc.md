# Opening a space

The three ways in, what Home's bars hold, and the four things it refuses over.

**Status:** Shipped · Milestones M0–M3

## Rules

- With no space open, the app offers three ways in: **choose a folder**, **clone from a URL**, or **pick a recently opened space**.
- **Home's top bar holds two controls and nothing else**: [preferences](../../preferences/the-popover/doc.md) and [the account](../../workspace/the-account/doc.md), whose popover has no repository section here. The status bar says `no space open`.
- **A space is a folder, not a repository.** TOM can open a subfolder of a repository — a `docs/` folder, say — and still run git against the repository root.
- **A folder that is not inside a git repository opens anyway**, as a space with the git column replaced by the sentence saying why it is empty ([without a repository](../../workspace/without-a-repository/doc.md)).
- **Home refuses only a folder it cannot open at all**, and says which of four it was — a title, a sentence under it, the folder's path, and `Choose another folder…`:

| What happened | Home says |
|---|---|
| The folder is gone | `That folder is no longer there` — it may be on a disk that is not connected, or was moved or renamed outside TOM |
| The machine has no git | `TOM cannot find git on this machine` — TOM drives the git already installed |
| The machine's git is older than 2.41 | `TOM needs git 2.41 or newer. This machine has <version>.` — the first half is the title, the second the sentence under it |
| Anything else | `That folder could not be opened` — git or the disk refused it without saying why |

- **git's version is read once per run and remembered**, not asked again at every opening.
- **The refusal over an older git offers no `Choose another folder…`** — no other folder would open either.

- **TOM never creates a repository on the user's behalf.**

## Mocks

- **empty state** — the three ways in. [light](../../../design/screens/desktop/home/home-empty-state-light.svg) · [dark](../../../design/screens/desktop/home/home-empty-state-dark.svg).
- **no repository** — a folder git knows nothing about, open: the message in the right column. [light](../../../design/screens/desktop/git-not-git/no-repository-light.svg) · [dark](../../../design/screens/desktop/git-not-git/no-repository-dark.svg).
- **a folder that did not open** — the folder is gone · no git on this machine · git older than 2.41 · anything else. [light](../../../design/screens/desktop/home/home-a-folder-that-did-not-open-states-light.svg) · [dark](../../../design/screens/desktop/home/home-a-folder-that-did-not-open-states-dark.svg).
- **the account on Home** — the popover, with no repository section. [light](../../../design/screens/desktop/home/the-account-on-home-states-light.svg) · [dark](../../../design/screens/desktop/home/the-account-on-home-states-dark.svg).

---

*See also: [home/](../README.md) · [cloning/](../cloning/doc.md) · [Decision 9](../../../technical/decisions/009-space-session-is-single-source-of-truth.md)*
