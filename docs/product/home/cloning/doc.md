# Cloning by URL

Start a space from a repository that is not on the machine yet.

**Status:** Shipped · Milestone M3

## Rules

- A repository can be cloned by **pasting its URL**, from Home itself.
- Progress and failure are shown in place. **Never a silent hang.**
- Once cloned, the repository **opens as a space immediately**, with no separate manual step.
- **The field takes the button's place**: the address, then `Clone` — Enter presses it — with Home still on screen. The folder is asked for next.
- **The folder asked for is the one the clone goes into**: the repository lands inside it under the name `git clone` would give it — the address's last segment, without `.git`.
- **A failure is a sentence under the field**, the address kept so trying again is one press. The app holds no credential of its own. There are seven:

| What happened | The field says |
|---|---|
| Nothing at that address | `There is no repository at that address.` |
| Git refused the credentials | `Git refused the credentials for <host>. Sign in with your own git, then try again.` |
| No network | `No network — the address could not be reached.` |
| The address went silent | `The address did not answer in time — try again.` |
| The folder the clone would land in exists | `<folder> already exists — choose another folder.` — nothing is ever written over |
| The machine has no git | `Git is not installed on this machine.` |
| Anything else | `Git could not clone that address.` |
- **A clone that fails leaves nothing behind it.** What the clone created is removed — the folder itself when it did not exist before, its contents when it was an empty folder somebody chose — and nothing that was there before is touched, so trying again needs no cleaning by hand.
- **The remote is always `origin`**, git's own default; nothing on the screen asks for a name, and publishing and the pull request read `origin` too.

## Mocks

- **clone from URL** — the field in the button's place. [light](../../../design/screens/desktop/home/cloning-by-address-the-field-states-light.svg) · [dark](../../../design/screens/desktop/home/cloning-by-address-the-field-states-dark.svg).
- **cloning** — the bar under the field, git's own phase beside it. [light](../../../design/screens/desktop/home/cloning-by-address-the-field-states-light.svg) · [dark](../../../design/screens/desktop/home/cloning-by-address-the-field-states-dark.svg).
- **clone failed** — one of the seven, the address kept. [light](../../../design/screens/desktop/home/clone-failed-the-seven-sentences-states-light.svg) · [dark](../../../design/screens/desktop/home/clone-failed-the-seven-sentences-states-dark.svg).
---

*See also: [home/](../README.md) · [opening-a-space/](../opening-a-space/doc.md) · [feedback](../../workspace/feedback/doc.md)*
