# What the end-to-end suite proves, and what it does not

Every user-facing feature ships with a scenario that drives the real app and
leaves a video (`.ai/skills/tom-testing`). This is that rule, checked: one row
per product subject, the scenario that proves it, and the gap where there is
none.

**Read the gaps as work, not as a report.** A subject with no scenario is a
feature nobody has watched working since the day it was written.

## Where it stands

Nineteen scenarios in eight groups, against fifty-two product subjects — of
which thirty-eight are built and fourteen are not yet drawn or not yet due.

## Covered

| Subject | Proved by |
|---|---|
| [home/opening-a-space](../../product/home/opening-a-space/doc.md) | *Opens a docs folder inside a repository* · *Opens a repository at its own root* |
| [home/recent-spaces](../../product/home/recent-spaces/doc.md) | *Remembers a space, and offers it on the next visit* · *Forgets a space without touching the folder* |
| [navigation/file-tree/what-is-shown](../../product/navigation/file-tree/what-is-shown/doc.md) | *Navigates the tree of a docs folder* · *Keeps git out of the tree* |
| [navigation/file-tree/order-and-shape](../../product/navigation/file-tree/order-and-shape/doc.md) | *Navigates the tree of a docs folder* |
| [workspace/columns](../../product/workspace/columns/doc.md) · [regions](../../product/workspace/regions/doc.md) | *Arranges the window: the columns, their width and the git panel* |
| [workspace/leaving-a-space](../../product/workspace/leaving-a-space/doc.md) | *Leaves a space, and goes to another without going home* |
| [workspace/without-a-repository](../../product/workspace/without-a-repository/doc.md) | *Refuses a folder that is not inside a repository* · *Offers another folder after refusing one* |
| [editor/source-mode](../../product/editor/source-mode/doc.md) | *Edits a document and saves it* · *Reads a document with the source out of the way* |
| [editor/markdown-preview](../../product/editor/markdown-preview/doc.md) | *Reads a document with the source out of the way* · *Reads a document whose notes are at its foot* |
| [editor/formatting-shortcuts](../../product/editor/formatting-shortcuts/doc.md) | *Formats a document from the bar above it* |
| [editor/conflicted-document](../../product/editor/conflicted-document/doc.md) | *A pull that conflicts is named, and can be undone* |
| [search/full-text-search/the-surface](../../product/search/full-text-search/the-surface/doc.md) · [what-is-searched](../../product/search/full-text-search/what-is-searched/doc.md) | *Finds a document by its contents* |
| [search/in-the-document](../../product/search/in-the-document/doc.md) · [replacing](../../product/search/replacing/doc.md) | *Replaces a word inside the open document* |
| [diff/rendered-diff/how-it-is-drawn](../../product/diff/rendered-diff/how-it-is-drawn/doc.md) · [what-is-compared](../../product/diff/rendered-diff/what-is-compared/doc.md) | *Sees what changed, rendered* |
| [diff/branch-diff](../../product/diff/branch-diff/doc.md) | *Compares a document against another branch* · *…against an earlier commit* |
| [git-workflow/commit/the-changes-list](../../product/git-workflow/commit/the-changes-list/doc.md) · [the-message](../../product/git-workflow/commit/the-message/doc.md) | *Commits one of two changes* · *Refuses to commit without a message, and stages everything at once* |
| [git-workflow/branch-switch](../../product/git-workflow/branch-switch/doc.md) | *Switches branches, and the documents follow* · *Refuses to switch away from unsaved work, and starts a branch* |
| [git-workflow/file-history](../../product/git-workflow/file-history/doc.md) | *Lists what changed this document, and nothing else* · *Opens a past version rendered, and comes back to now* |
| [git-workflow/push-pull/what-each-does](../../product/git-workflow/push-pull/what-each-does/doc.md) · [the-controls](../../product/git-workflow/push-pull/the-controls/doc.md) · [when-it-fails](../../product/git-workflow/push-pull/when-it-fails/doc.md) | *Fetches, and finds the branch has fallen behind* · *Refuses a push the remote got to first, and pulls instead* |
| [push-pull/when-a-pull-conflicts](../../product/git-workflow/push-pull/when-a-pull-conflicts/doc.md) | *A pull that conflicts is named, and can be undone* |
| [preferences/the-popover](../../product/preferences/the-popover/doc.md) · [what-it-holds](../../product/preferences/what-it-holds/doc.md) | *Chooses a preference, and the window answers at once* |

## Not covered — built, and nobody has watched it work

| Subject | What is missing |
|---|---|
| [diff/rendered-diff/turning-it-off](../../product/diff/rendered-diff/turning-it-off/doc.md) | The `Diff` chip is on every screen and **no scenario presses it**. Turning the diff off is the one thing this subject is about |
| [push-pull/while-a-request-runs](../../product/git-workflow/push-pull/while-a-request-runs/doc.md) | The progress bar across the top of the git column. A request in a fixture finishes too fast to catch, so this needs a remote that is slow on purpose |
| [push-pull/when-it-works](../../product/git-workflow/push-pull/when-it-works/doc.md) | The band that says how many commits arrived. It has no board either, so it is blocked twice |
| [push-pull/when-the-link-is-broken](../../product/git-workflow/push-pull/when-the-link-is-broken/doc.md) | No network, refused credentials, no remote configured. Four states, four fixtures nobody has built |
| [preferences/where-it-is-stored](../../product/preferences/where-it-is-stored/doc.md) | A preference **surviving a restart**. The scenario chooses one and never relaunches, so what is proved is the choice and not the store |
| [search/full-text-search/staying-current](../../product/search/full-text-search/staying-current/doc.md) | A save re-filing the document. The step existed and was **dropped** when the search scenario became unreliable; a widget test carries it instead |
| [commit/confirming](../../product/git-workflow/commit/confirming/doc.md) | A commit that worked says so. The scenario checks the list and the box, never the confirmation |
| [navigation/file-tree/change-marks](../../product/navigation/file-tree/change-marks/doc.md) | The letter on a file's row and the dot on its folder. Seen in passing in other scenarios, asserted by none |
| [home/the-brand-block](../../product/home/the-brand-block/doc.md) | Home's own half. Every Home scenario walks past it to the button |
| The source pane's **diff** marks and tint | The gutter's `A`/`R`/`M` and the band behind the lines. The conflict scenario asserts `C`; the diff's own letters have no scenario |
| **Undo and redo** | Wired to `re_editor`'s history and pressed by nothing. The keystroke has never been driven either |

## Not due

`editor/tabs`, `export`, `home/cloning`, `wikilinks`, the six
`git-workflow/pull-request/` subjects and `workspace/feedback` are not built;
the three `*-on-mobile` subjects are Phase 3. None of them is a gap.

## The status lines lie

Thirteen subjects that shipped milestones ago still say **Planned** — source
mode, the preview, the whole of `commit/`, branch switch, file history,
`push-pull/what-each-does`, the file tree's four, `home/`'s three,
`search/in-the-document` and `replacing`. A status nobody updates is worse
than none, because the next reader takes it for a to-do list.

---

*See also: [process/](README.md) · [product/](../../product/README.md) · [ci.md](ci.md)*
