# Explorer menu

What the `⋮` at the head of the explorer offers.

**Status:** Shipped · Milestone M3

## Rules

- **Four actions, in two groups**: `New folder`; then `Collapse all` and `Reload`; then `Reveal in Finder`. The verb names the platform's file manager, so it reads `Reveal in Explorer` on Windows and `Show in Files` on Linux.
- **`New folder` goes where [new document](../new-document/doc.md) goes**: inside the folder of the open document, or at the space's root with nothing open — a name is asked for in the tree the same way.
- **`Collapse all` closes every folder** and keeps the open document's own folder open, because a tree that hides what is on screen has lost its reader.
- **`Reload` re-reads the folder from disk, and asks git again** — a file that arrived from outside is untracked, and the tree's `N` comes from git. Nothing watches the folder ([search](../../../search/README.md) is filled from the tree's own listing), so such a file waits for this or for the space to be reopened.
- **`Reveal in Finder` opens the space's folder**, not the repository's — the space is what the tree shows ([a space is a folder](../../../workspace/README.md)).
- The menu is a [popover](../../../../design/components/controls.md) hanging from the `⋮`, 200 wide, and closes on a choice, on a click outside, or on Escape.

## Mocks

- **explorer menu** — the four under the `⋮`. [light](../../../../design/screens/desktop/workspace-tree/explorer-menu-light.svg) · [dark](../../../../design/screens/desktop/workspace-tree/explorer-menu-dark.svg).
- **new folder** — the field `New folder` puts in the tree, `untitled` selected beside a folder. [light](../../../../design/screens/desktop/workspace-tree/new-folder-light.svg) · [dark](../../../../design/screens/desktop/workspace-tree/new-folder-dark.svg).

---

*See also: [file-tree/](../README.md) · [new document](../new-document/doc.md) · [git menu](../../../git-workflow/git-menu/doc.md)*
