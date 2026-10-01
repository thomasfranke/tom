# Opening it

The one request to the host, the token behind it, and the link when there is no token.

**Status:** Planned · Milestone M3

## Rules

- **Creating it is one request to the host, with a token the person gave.** The token lives in the operating system's keychain behind a capability, never in a file inside the space and never in the repository — a space is a folder somebody may well commit.
- **Without a token it degrades to a link, not to nothing.** A second action opens the host's own compare page with the branch already filled, and it is a button beside the first, not a line of small print under it — handing the work to the browser is a choice somebody makes, not a footnote.
- **It says the host's name, because the app knows it.** The address is read from `git remote get-url`, so the control reads `Open on GitHub instead` and never `the host`; a remote nothing recognises draws no action at all.
- **The action survives the column closing.** It sits at the foot of the right column, where `Commit` already is, and the status row takes it over when that column is shut — the same rule the band follows for `Push`. No screen may keep its only action somewhere the window can hide.
- **A branch with no upstream is pushed first.** Opening follows the push rather than replacing it, which is the chain the band already runs ([when it works](../../push-pull/when-it-works/doc.md)).

---

*See also: [pull-request/](../README.md) · [when it cannot be opened](../when-it-cannot-be-opened/doc.md) · [the right column](../the-right-column/doc.md)*
