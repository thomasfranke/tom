# The right column

Two segments — the proposal, and what the branch did in numbers.

**Status:** Shipped · Milestone M3

## Rules

- **The right column is two segments, `Pull request` and `Overview`.** The first is the proposal — the base, the branch's commits and the actions; the second is what the branch did, in numbers. The workspace's own `Git · History` is not on this screen: neither panel it offers is here, and a switch that offers two absent things is a control that cannot work.
- **What it proposes is the branch you are on, onto a base you pick.** The base starts at the branch the current one came from — the same base the [rendered diff](../../../diff/branch-diff/doc.md) is read against — or at the remote's default branch when there is none, and is chosen with the same control the [branch switch](../../branch-switch/doc.md) uses; the remote's default branch stays on offer either way. The compare side is never a choice, because it is where you are.
- **This base is a choice where the diff's is not** — a pull request may be aimed at any branch, while the diff answers where this one came from. Choosing here changes what is proposed and never what the documents are compared against.
- **It is `Overview` and not `Summary`, because `Summary` is taken.** That word already names the commit message's first line, in the field the changes panel draws; one word meaning two things in the same column is worse than a duller word.
- **Half the overview comes from git and half only this tool can give.** Documents, commits, folders and the most changed file are read from `log`, `diff --name-status` and `diff --stat`. **Words, blocks by kind and the reading time are not** — they come from the same block differ the [rendered diff](../../../diff/rendered-diff/README.md) already runs, and they are the point: prose is measured in words and paragraphs, and every other tool measures it in lines.
- **The overview carries no action.** Opening belongs to the other segment, so this one only reports; a number and a button in the same panel invite pressing the button because the number looked fine.

## Mocks

- **branch overview** — the column with the second segment chosen. [light](../../../../design/screens/desktop/git-pull-request/branch-overview-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request/branch-overview-dark.svg).
- **proposing onto — choosing the base** — the base control open, the default branch ticked. [light](../../../../design/screens/desktop/git-pull-request/proposing-onto-choosing-the-base-states-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request/proposing-onto-choosing-the-base-states-dark.svg).

---

*See also: [pull-request/](../README.md) · [opening it](../opening-it/doc.md) · [the message](../../commit/the-message/doc.md)*
