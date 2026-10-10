# Cloning by URL

Start a space from a repository that is not on the machine yet.

**Status:** Shipped · Milestone M3 — the folder asked for is the one the clone goes *into*, as `git clone` names it: the address's last segment without `.git`

## Rules

- A repository can be cloned by **pasting its URL**, from Home itself.
- Progress and failure — bad URL, auth required, network down — are shown in place. **Never a silent hang.**
- Once cloned, the repository **opens as a space immediately**, with no separate manual step.

- **The field takes the button's place**: the address, then `Clone`, with Home still on screen. The folder is asked for next.
- **The three failures are sentences under the field**, the address kept so trying again is one press: no repository at that address, git refused the credentials, no network. The app holds no credential of its own.
- **A clone that fails leaves nothing behind it.** What the clone created is removed — the folder itself when it did not exist before, its contents when it was an empty folder somebody chose — and nothing that was there before is touched, so trying again needs no cleaning by hand.
- **The remote is always `origin`**, git's own default; nothing on the screen asks for a name, and publishing and the pull request read `origin` too.

## Mocks

- **clone from URL** — [light](../../../design/screens/desktop/home/clone-from-url-light.svg) · [dark](../../../design/screens/desktop/home/clone-from-url-dark.svg).
- **cloning** — the bar under the field, git's own phase beside it. [light](../../../design/screens/desktop/home/cloning-light.svg) · [dark](../../../design/screens/desktop/home/cloning-dark.svg).
- **clone failed** — [light](../../../design/screens/desktop/home/clone-failed-light.svg) · [dark](../../../design/screens/desktop/home/clone-failed-dark.svg).

---

*See also: [home/](../README.md) · [opening-a-space/](../opening-a-space/doc.md) · [feedback](../../workspace/feedback/doc.md)*
