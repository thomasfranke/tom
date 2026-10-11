# What the end-to-end suite proves, and what it does not

Which product subject each scenario walks, and the subjects no scenario does.
The scenarios themselves are `tom e2e list` ([commands](commands.md)); the bar
they are held to is in [testing](../conventions/testing.md).

- **A row under *Covered* means a scenario walks the subject, not that every rule of it has a step.** Rule by rule and control by control the suite is far thinner than this table reads, and closing that is its own item on the [roadmap](../../roadmap.md).
- **Read the gaps as work, not as a report.** A subject with no scenario is a feature nobody has watched working since the day it was written.
- A scenario's group is the `group:` it declares, and the menu's order is `scenarioGroups` in `tool/src/commands/e2e_catalogue.dart`. A scenario that declares none is listed under `Home`.

## Covered

| Subject | Walked by |
|---|---|
| [home/opening-a-space](../../product/home/opening-a-space/doc.md) | *Opens a docs folder inside a repository* · *Opens a repository at its own root* |
| [home/recent-spaces](../../product/home/recent-spaces/doc.md) | *Remembers a space, and offers it on the next visit* · *Forgets a space without touching the folder* |
| [home/cloning](../../product/home/cloning/doc.md) | *Clones a repository by its address and opens it* |
| [navigation/file-tree/what-is-shown](../../product/navigation/file-tree/what-is-shown/doc.md) | *Navigates the tree of a docs folder* · *Keeps git out of the tree* |
| [navigation/file-tree/order-and-shape](../../product/navigation/file-tree/order-and-shape/doc.md) | *Navigates the tree of a docs folder* |
| [navigation/file-tree/change-marks](../../product/navigation/file-tree/change-marks/doc.md) | *Arranges the window: the columns, their width and the git panel* · *Creates a document from the tree* |
| [navigation/file-tree/new-document](../../product/navigation/file-tree/new-document/doc.md) | *Creates a document from the tree* |
| [navigation/file-tree/explorer-menu](../../product/navigation/file-tree/explorer-menu/doc.md) | *Arranges the tree from its menu* |
| [workspace/columns](../../product/workspace/columns/doc.md) · [regions](../../product/workspace/regions/doc.md) | *Arranges the window: the columns, their width and the git panel* |
| [workspace/leaving-a-space](../../product/workspace/leaving-a-space/doc.md) | *Leaves a space, and goes to another without going home* |
| [workspace/without-a-repository](../../product/workspace/without-a-repository/doc.md) | *Opens a folder that is not inside a repository* |
| [workspace/the-account](../../product/workspace/the-account/doc.md) | *Says who commits, and that nothing is known without a GitHub login* |
| [workspace/commands](../../product/workspace/commands/doc.md) | *Shows the commands TOM ran, and the one that failed* |
| [workspace/terminal](../../product/workspace/terminal/doc.md) | *Runs git in the terminal under the document* |
| [editor/source-mode](../../product/editor/source-mode/doc.md) | *Edits a document and saves it* · *Reads a document with the source out of the way* |
| [editor/markdown-preview](../../product/editor/markdown-preview/doc.md) | *Reads a document with the source out of the way* · *Reads a document whose notes are at its foot* |
| [editor/formatting-shortcuts](../../product/editor/formatting-shortcuts/doc.md) | *Formats a document from the bar above it* — the buttons and the keys |
| [editor/tabs](../../product/editor/tabs/doc.md) | *Works in tabs* |
| [editor/conflicted-document](../../product/editor/conflicted-document/doc.md) | *A pull that conflicts is named, and can be undone* |
| [export](../../product/export/doc.md) | *Exports a document from its tab* |
| [wikilinks](../../product/wikilinks/doc.md) | *Follows a link by name, and creates the one that is missing* |
| [search/full-text-search/the-surface](../../product/search/full-text-search/the-surface/doc.md) · [what-is-searched](../../product/search/full-text-search/what-is-searched/doc.md) | *Finds a document by its contents* · *Reaches the search from the keyboard* |
| [search/in-the-document](../../product/search/in-the-document/doc.md) · [replacing](../../product/search/replacing/doc.md) | *Replaces a word inside the open document* |
| [diff/rendered-diff/how-it-is-drawn](../../product/diff/rendered-diff/how-it-is-drawn/doc.md) · [what-is-compared](../../product/diff/rendered-diff/what-is-compared/doc.md) | *Sees what changed, rendered* |
| [diff/branch-diff](../../product/diff/branch-diff/doc.md) | *Compares a document against the branch it came from* |
| [diff/rendered-diff/turning-it-off](../../product/diff/rendered-diff/turning-it-off/doc.md) | *Turns the marks off and back on from the Diff chip* |
| [git-workflow/commit/the-changes-list](../../product/git-workflow/commit/the-changes-list/doc.md) · [the-message](../../product/git-workflow/commit/the-message/doc.md) | *Commits one of two changes* · *Refuses to commit without a message, and stages everything at once* · *Puts one file back from the changes list* |
| [git-workflow/commit/opening-a-change](../../product/git-workflow/commit/opening-a-change/doc.md) | *Opens a change from beside the space* |
| [git-workflow/git-menu](../../product/git-workflow/git-menu/doc.md) | *Goes back to the last commit from the git menu* |
| [git-workflow/branch-switch](../../product/git-workflow/branch-switch/doc.md) | *Switches branches, and the documents follow* · *Refuses to switch away from unsaved work, and starts a branch* |
| [git-workflow/file-history](../../product/git-workflow/file-history/doc.md) | *Lists what changed this document, and nothing else* · *Opens a past version rendered, and comes back to now* |
| [git-workflow/push-pull/what-each-does](../../product/git-workflow/push-pull/what-each-does/doc.md) · [the-controls](../../product/git-workflow/push-pull/the-controls/doc.md) · [when-it-fails](../../product/git-workflow/push-pull/when-it-fails/doc.md) | *Fetches, and finds the branch has fallen behind* · *Refuses a push the remote got to first, and pulls instead* |
| [push-pull/when-it-works](../../product/git-workflow/push-pull/when-it-works/doc.md) | *Refuses a push the remote got to first, and pulls instead* — the band that counts what a pull brought |
| [push-pull/when-the-link-is-broken](../../product/git-workflow/push-pull/when-the-link-is-broken/doc.md) | *Says the link is down, and keeps committing* — no network, and no remote configured |
| [push-pull/when-it-fails](../../product/git-workflow/push-pull/when-it-fails/doc.md) | *Says the remote protects the branch, and offers a pull request* — fixture `docs-protected-branch`, a bare remote whose `pre-receive` hook refuses |
| [push-pull/when-a-pull-conflicts](../../product/git-workflow/push-pull/when-a-pull-conflicts/doc.md) | *A pull that conflicts is named, and can be undone* |
| [pull-request/the-control](../../product/git-workflow/pull-request/the-control/doc.md) · [the-draft](../../product/git-workflow/pull-request/the-draft/doc.md) · [writing-it](../../product/git-workflow/pull-request/writing-it/doc.md) · [the-right-column](../../product/git-workflow/pull-request/the-right-column/doc.md) | *Writes a pull request* |
| [pull-request/opening-it](../../product/git-workflow/pull-request/opening-it/doc.md) | *Opens a pull request through gh, and finds it open afterwards* |
| [pull-request/when-it-cannot-be-opened](../../product/git-workflow/pull-request/when-it-cannot-be-opened/doc.md) | *Says why a pull request cannot be opened without a remote* |
| [preferences/the-popover](../../product/preferences/the-popover/doc.md) · [what-it-holds](../../product/preferences/what-it-holds/doc.md) | *Chooses a preference, and the window answers at once* |
| [preferences/where-it-is-stored](../../product/preferences/where-it-is-stored/doc.md) | *Opens the preferences file and edits it by hand* |
| [about](../../product/about/doc.md) · [preferences/what-it-holds](../../product/preferences/what-it-holds/doc.md) | *Says which TOM this is, and asks for a newer one only when asked* · *Asks at opening only when the box was ticked* — a real server on a real socket plays GitHub, and the app's own `HttpClient` implementation runs |

## Not covered — built, and nobody has watched it work

| Subject | What is missing |
|---|---|
| [push-pull/while-a-request-runs](../../product/git-workflow/push-pull/while-a-request-runs/doc.md) | The progress bar across the top of the git column. A request in a fixture finishes too fast to catch, so this needs a remote that is slow on purpose |
| [push-pull/when-the-link-is-broken](../../product/git-workflow/push-pull/when-the-link-is-broken/doc.md) | Refused credentials and a remote that does not answer. Fixtures exist for no network and for no remote |
| [preferences/where-it-is-stored](../../product/preferences/where-it-is-stored/doc.md) | A preference **surviving a restart**. The file is read back in the scenario; the app is never relaunched on it |
| [search/full-text-search/staying-current](../../product/search/full-text-search/staying-current/doc.md) | A save re-filing the document. A notifier test carries it; no step does |
| [workspace/feedback](../../product/workspace/feedback/doc.md) | No scenario of its own. Bands are asserted in passing by the remote, export and conflict scenarios |
| [workspace/status-bar](../../product/workspace/status-bar/doc.md) | No scenario of its own. Some segments are asserted in passing by the commit, tree and opening-a-change scenarios |
| [home/the-brand-block](../../product/home/the-brand-block/doc.md) | Home's own half. Every Home scenario walks past it to the button |
| The source pane's **diff** marks and tint | Asserted for a conflict (`C`) and for a text file's changed line; a markdown document's own letters and the band behind its lines have no step |
| **Redo** | Undo is driven twice — after a replacement, and from preview. Redo is pressed by nothing |

## Not due

| Subject | Why |
|---|---|
| [git-workflow/approvals](../../product/git-workflow/approvals/doc.md) | The layers under the interface are built; no widget draws it |
| `Update and restart`, the download and `Restart now` ([about](../../product/about/doc.md)) | Not built; the dialog and the check are covered above |
| The three `*-on-mobile` subjects | Phase 3 |

---

*See also: [process/](README.md) · [product/](../../product/README.md) · [conventions/testing.md](../conventions/testing.md) · [ci.md](ci.md)*
