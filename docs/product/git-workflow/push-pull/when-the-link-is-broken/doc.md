# When the link is broken

What the right column says when the trouble is the connection rather than the
operation.

**Status:** Shipped · Milestone M3

## Rules

- **The state of the link is a line at the foot of the git column**, ~~under the commit note and above the remote buttons~~ under the remote buttons, where every board draws it — every operation that touches the network is asked for there, so that is where its condition is said.
- **It is what the last request said, until another one answers.** A request that lands clears it, and so does the git menu's `Reload` — without that, three buttons gone unavailable for *no network* would have nothing that offers them again.
- **A band says what a press produced; the line says what the connection is.** One appears after somebody asks and goes when the news is old; the other is true whether or not anybody asked.
- ~~**The line is not drawn while the link is healthy.**~~ — **revoked 2026-10-08**, to what every board draws: a healthy link says where the branch stands against its upstream, in `text_muted` at 11 and with no glyph — `Up to date with origin/main`, `2 behind origin/main`, `1 ahead of origin/main`, `1 ahead, 2 behind origin/main`. A branch with no upstream says nothing, since there is nothing to stand against. The broken states replace it in the same place.
- **A glyph and the words, never colour alone** — the line wears `modified`, the palette's *needs attention*; `removed` belongs to an action that failed, which is the band's job.
- **It says what was refused, never why.** *Git refused the credentials* is honest where *your token expired* is a guess about a remote that may have said something else entirely.
- **The three controls stay on screen in every state.** ~~A control that cannot work is not drawn~~ does not reach here: a column whose foot changes shape with the weather is a column nobody can aim at, and unavailable already says the button is not for now.
- **Committing is never taken away.** A space that cannot reach its remote is still a space somebody is writing in.
- **Four states earn a sentence**, and they differ in what they leave available:

| | The line says | The buttons |
|---|---|---|
| No network | `No network` | Unavailable — the network can come back, so *later*, not *never* |
| Credentials refused | `Git refused the credentials` | Unavailable, and **nothing offers to try again**: the one failure where the same press gives the same answer |
| No remote configured | `No remote configured` | Unavailable, and the count leaves the label — `Push` with no number, because ahead is counted against a remote |
| Timed out | `The remote did not answer` | Live — this is the one where trying again is the remedy |

## Mocks

- **no network** — the line, and the three controls unavailable. [light](../../../../design/screens/desktop/git-connection/no-network-light.svg) · [dark](../../../../design/screens/desktop/git-connection/no-network-dark.svg).
- **credentials refused** — the failure with no remedy offered. [light](../../../../design/screens/desktop/git-connection/credentials-refused-light.svg) · [dark](../../../../design/screens/desktop/git-connection/credentials-refused-dark.svg).
- **no remote** — the count gone from the button and from the status bar. [light](../../../../design/screens/desktop/git-connection/no-remote-light.svg) · [dark](../../../../design/screens/desktop/git-connection/no-remote-dark.svg).
- **timed out** — the one that stays pressable. [light](../../../../design/screens/desktop/git-connection/timed-out-light.svg) · [dark](../../../../design/screens/desktop/git-connection/timed-out-dark.svg).

---

*See also: [push-pull/](../README.md) · [while a request runs](../while-a-request-runs/doc.md) · [when it fails](../when-it-fails/doc.md)*
