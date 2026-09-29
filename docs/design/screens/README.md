# Screens

Every screen the app has, exported from the Penpot file, light and dark.

**Normative.** Nothing the user can see is written before it exists here
([AGENTS.md](../../../AGENTS.md) rule 13), and nothing ships looking different
from what is here.

| | |
|---|---|
| [`conventions.md`](conventions.md) | Naming, the page split, what a board may and may not carry |
| [`measurements.md`](measurements.md) | The numbers every board shares, and the two the reader controls |
| [`not-drawn-yet.md`](not-drawn-yet.md) | What has no board, and why |
| [`desktop/`](desktop/) | The boards themselves, one folder per Penpot page |

```
desktop/<page>/<screen>-light.svg
desktop/<page>/<screen>-dark.svg
desktop/<page>/<page>.pdf
```

## The folders are the Penpot pages

| Folder | Page | Product |
|---|---|---|
| [`desktop/home/`](desktop/home/) | `Screens: Home` | [home](../../product/home/README.md) |
| [`desktop/workspace/`](desktop/workspace/) | `Screens: Workspace` | [workspace](../../product/workspace/README.md) |
| [`desktop/editor/`](desktop/editor/) | `Screens: Editor` | [editor](../../product/editor/README.md) |
| [`desktop/git-commit/`](desktop/git-commit/) | `Screens: Git - Commit` | [commit](../../product/git-workflow/commit/README.md) |
| [`desktop/git-branches/`](desktop/git-branches/) | `Screens: Git - Branches` | [branch-switch](../../product/git-workflow/branch-switch/doc.md) |
| [`desktop/git-history/`](desktop/git-history/) | `Screens: Git - History` | [file-history](../../product/git-workflow/file-history/doc.md) |
| [`desktop/git-remote/`](desktop/git-remote/) | `Screens: Git - Remote` | [push-pull](../../product/git-workflow/push-pull/README.md) |
| [`desktop/git-diff/`](desktop/git-diff/) | `Screens: Git - Diff` | [branch-diff](../../product/diff/branch-diff/doc.md) · [rendered-diff](../../product/diff/rendered-diff/README.md) |
| [`desktop/git-not-git/`](desktop/git-not-git/) | `Screens: Git - Not git` | [without-a-repository](../../product/workspace/without-a-repository/doc.md) |
| [`desktop/git-conflict/`](desktop/git-conflict/) | `Screens: Git - Conflict` | [when-a-pull-conflicts](../../product/git-workflow/push-pull/when-a-pull-conflicts/doc.md) · [conflicted-document](../../product/editor/conflicted-document/doc.md) |
| [`desktop/search/`](desktop/search/) | `Screens: Search` | [full-text-search](../../product/search/full-text-search/README.md) |
| [`desktop/git-pull-request/`](desktop/git-pull-request/) | `Screens: Git - Pull request` | [pull-request](../../product/git-workflow/pull-request/README.md) |
| [`desktop/preferences/`](desktop/preferences/) | `Screens: Preferences` | [preferences](../../product/preferences/README.md) |
| [`desktop/git-connection/`](desktop/git-connection/) | `Screens: Git - Connection` | [while a request runs](../../product/git-workflow/push-pull/while-a-request-runs/doc.md) · [when the link is broken](../../product/git-workflow/push-pull/when-the-link-is-broken/doc.md) |

---

*See also: [design/](../README.md) · [components/](../components/README.md) · the [`tom-design`](../../../.ai/skills/tom-design/SKILL.md) skill*
