# Recent spaces

Returning to a space is one click, and the row says enough to know which one.

**Status:** Shipped · Milestone M0 — the branch on the row since 2026-10-09, built ahead of its board

## Rules

- Recently opened spaces are offered on Home, so returning to one is one click.
- Each row names the space, the folder it is in, and **the branch it was left on** — coming back to the wrong branch is the one surprise the screen can prevent.
- **The branch is asked of git each time Home shows the row**, so it is the branch the folder is on now, not the one it was opened on; the command shows in the [commands panel](../../workspace/commands/doc.md) like any other.
- **A row with no branch to name draws none** — a detached `HEAD`, a folder that is gone, or one that is no longer a repository. The row stays, and forgetting it is still offered.
- **A recent space can be forgotten from its own row**, by a control that appears on that row and nowhere else.
- **Forgetting a space never touches the folder.** The list is the app's memory, not the disk's.

The same list is reachable from inside a space, through the breadcrumb —
switching from there skips the trip through Home
([leaving a space](../../workspace/leaving-a-space/doc.md)).

---

*See also: [home/](../README.md) · [opening-a-space/](../opening-a-space/doc.md)*
