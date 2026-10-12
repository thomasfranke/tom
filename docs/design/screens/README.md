# Screens

Every screen the app has, exported from the Penpot file, light and dark.

**Normative.** A screen is approved in Penpot before its code is written and
exported here before that change merges ([AGENTS.md](../../../AGENTS.md)
rule 13), and nothing ships looking different from what was approved.

| | |
|---|---|
| [`conventions.md`](conventions.md) | Naming, the page split, what a board may and may not carry |
| [`measurements.md`](measurements.md) | The numbers every board shares, and the two the reader controls |
| [`not-drawn-yet.md`](not-drawn-yet.md) | What has no board, and why |
| [`divergences.md`](divergences.md) | Where the app draws something other than the board |
| [`desktop/`](desktop/) | The boards themselves, one folder per Penpot page |

```
desktop/<page>/<screen>-light.svg              a whole window, 1440 × 900
desktop/<page>/<screen>-dark.svg
desktop/<page>/<component>-states-light.svg    one component alone, in each of its states
desktop/<page>/<component>-states-dark.svg
```

- **A page exports its whole windows and its states boards, and nothing else** — the card around them, with its title and notes, is read in the Penpot file.
- **Every folder is the whole of its page**, exported after the page split, both themes, fonts embedded — a file's name is its board's name in kebab-case, so a board is found by name.
- The export happens only when the maintainer asks for it.

## The folders are the Penpot pages

| Folder | Page | Product |
|---|---|---|
| [`desktop/home/`](desktop/home/) | `Screens: Home` | [home](../../product/home/README.md) |
| [`desktop/workspace-shell/`](desktop/workspace-shell/) | `Screens: Workspace - Shell` | [workspace](../../product/workspace/README.md) · [tabs](../../product/editor/tabs/doc.md) |
| [`desktop/workspace-tree/`](desktop/workspace-tree/) | `Screens: Workspace - Tree` | [new document](../../product/navigation/file-tree/new-document/doc.md) · [explorer menu](../../product/navigation/file-tree/explorer-menu/doc.md) |
| [`desktop/editor/`](desktop/editor/) | `Screens: Editor` | [editor](../../product/editor/README.md) |
| [`desktop/editor-links-export/`](desktop/editor-links-export/) | `Screens: Editor - Links & Export` | [wikilinks](../../product/wikilinks/doc.md) · [export](../../product/export/doc.md) |
| [`desktop/git-commit/`](desktop/git-commit/) | `Screens: Git - Commit` | [commit](../../product/git-workflow/commit/README.md) |
| [`desktop/git-branches/`](desktop/git-branches/) | `Screens: Git - Branches` | [branch-switch](../../product/git-workflow/branch-switch/doc.md) |
| [`desktop/git-history/`](desktop/git-history/) | `Screens: Git - History` | [file-history](../../product/git-workflow/file-history/doc.md) |
| [`desktop/git-push/`](desktop/git-push/) | `Screens: Git - Push` | [push-pull](../../product/git-workflow/push-pull/README.md) · [when it fails](../../product/git-workflow/push-pull/when-it-fails/doc.md) |
| [`desktop/git-pull/`](desktop/git-pull/) | `Screens: Git - Pull` | [when it works](../../product/git-workflow/push-pull/when-it-works/doc.md) · [when a pull conflicts](../../product/git-workflow/push-pull/when-a-pull-conflicts/doc.md) |
| [`desktop/git-diff/`](desktop/git-diff/) | `Screens: Git - Diff` | [branch-diff](../../product/diff/branch-diff/doc.md) · [rendered-diff](../../product/diff/rendered-diff/README.md) |
| [`desktop/git-not-git/`](desktop/git-not-git/) | `Screens: Git - Not git` | [without-a-repository](../../product/workspace/without-a-repository/doc.md) |
| [`desktop/git-conflict/`](desktop/git-conflict/) | `Screens: Git - Conflict` | [when-a-pull-conflicts](../../product/git-workflow/push-pull/when-a-pull-conflicts/doc.md) · [conflicted-document](../../product/editor/conflicted-document/doc.md) |
| [`desktop/search/`](desktop/search/) | `Screens: Search` | [full-text-search](../../product/search/full-text-search/README.md) |
| [`desktop/git-pull-request/`](desktop/git-pull-request/) | `Screens: Git - Pull request` | [pull-request](../../product/git-workflow/pull-request/README.md) |
| [`desktop/preferences/`](desktop/preferences/) | `Screens: Preferences` | [preferences](../../product/preferences/README.md) |
| [`desktop/git-connection/`](desktop/git-connection/) | `Screens: Git - Connection` | [while a request runs](../../product/git-workflow/push-pull/while-a-request-runs/doc.md) · [when the link is broken](../../product/git-workflow/push-pull/when-the-link-is-broken/doc.md) |
| [`desktop/git-discarding/`](desktop/git-discarding/) | `Screens: Git - Discarding` | [the changes list](../../product/git-workflow/commit/the-changes-list/doc.md) · [git menu](../../product/git-workflow/git-menu/doc.md) |
| [`desktop/git-opening-a-change/`](desktop/git-opening-a-change/) | `Screens: Git - Opening a change` | [opening a change](../../product/git-workflow/commit/opening-a-change/doc.md) |
| [`desktop/git-pull-request-not-ready/`](desktop/git-pull-request-not-ready/) | `Screens: Git - Pull request, not ready` | [when it cannot be opened](../../product/git-workflow/pull-request/when-it-cannot-be-opened/doc.md) |
| [`desktop/git-approvals/`](desktop/git-approvals/) · [`desktop/git-approvals-the-setting/`](desktop/git-approvals-the-setting/) | `Screens: Git - Approvals` · `Screens: Git - Approvals, the setting` | [approvals](../../product/git-workflow/approvals/doc.md) |
| [`desktop/about-updates/`](desktop/about-updates/) | `Screens: About & Updates` | [about](../../product/about/doc.md) |
| [`desktop/account/`](desktop/account/) | `Screens: Account` | [the account](../../product/workspace/the-account/doc.md) |
| [`desktop/commands-terminal/`](desktop/commands-terminal/) | `Screens: Commands & Terminal` | [commands](../../product/workspace/commands/doc.md) · [terminal](../../product/workspace/terminal/doc.md) |
| [`desktop/editor-formatting/`](desktop/editor-formatting/) | the formatting page | [formatting shortcuts](../../product/editor/formatting-shortcuts/doc.md) — three boards (`Formatting overflow`, `Merged rows`, `What the preview renders`) that `desktop/editor/` holds too |
---

*See also: [design/](../README.md) · [components/](../components/README.md) · the [`tom-design`](../../../.ai/skills/tom-design/SKILL.md) skill*
