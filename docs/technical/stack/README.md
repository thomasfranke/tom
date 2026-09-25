# Dependency stack

Filter for every dependency: a **permissive license (MIT/BSD/Apache)** — the
project ships under MIT
([Decision 1](../decisions/001-license-is-mit.md)) —, maturity, and desktop
suitability. The license check is a PR checklist item.

*How* a dependency is reached, in three tiers, is
[`conventions/external-dependencies.md`](../conventions/external-dependencies.md).
This chapter is *which* ones are taken.

| File | Covers |
|---|---|
| [`state-and-models.md`](state-and-models.md) | Riverpod, Freezed, and the code generators — all pinned exactly |
| [`markdown-and-diff.md`](markdown-and-diff.md) | The heart: the parser, the block renderer, Myers, the highlighter |
| [`editor.md`](editor.md) | Source mode — `re_editor` and what it does not ship |
| [`platform.md`](platform.md) | sqlite/FTS5, the watcher, paths, and the desktop shell |

## Deliberately excluded

| Excluded | Reason |
|---|---|
| `dartz` | Result pattern with native sealed classes ([Decision 5](../decisions/005-errors-use-result-with-sealed-classes.md); rules in [conventions/errors.md](../conventions/errors.md)) |
| `appflowy_editor` (and anything AGPL/GPL) | Contaminates the MIT license ([Decision 1](../decisions/001-license-is-mit.md)) |
| AutoRoute / any routing package | A panel-based desktop app has no navigation ([Decision 6](../decisions/006-no-navigation-package.md)) |
| Dio / `http` | There is no HTTP in the MVP; it arrives with layer 3 (remote APIs) when needed |
| `sqflite` | Mobile-oriented; on desktop, plain `sqlite3` |
| `shared_preferences` | A Flutter plugin, and settings belong to `tom_infra` — see [`platform.md`](platform.md) |

## Scope

> Every judgment in this chapter is scoped to the **desktop** app. iOS and
> Android arrive in Phase 3, post-1.0 ([roadmap](../../roadmap.md#phases)), and
> get their own stack under `tom_infra_mobile` — `sqflite` and a
> touch-capable editor become live candidates there, and `re_editor` almost
> certainly does not travel. Nothing here is a verdict on mobile.

## Adding one

Add it to the pubspec of the package that needs it, not to the workspace root
([`process/setup.md`](../process/setup.md#adding-a-dependency)). A new
*external* dependency needs a licence check and a line in the file above that
covers its area.

---

*See also: [conventions/external-dependencies.md](../conventions/external-dependencies.md) · [process/setup.md](../process/setup.md)*
