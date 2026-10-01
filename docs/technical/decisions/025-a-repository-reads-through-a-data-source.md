# Decision 25 — A repository reads through a data source

**Status:** accepted

## Context

[Decision 24](024-a-capability-is-a-folder.md) settled where a capability lives. It left the layer above undecided: `tom_data`'s repositories held capabilities directly — `SpaceRepositoryImpl` took a `Filesystem` and a `GitClientFor`, `GitRepositoryImpl` took a `GitClient` — and did the obtaining themselves.

That is defensible and it is what this project ran on for a while: the capability is already an interface, already swappable, already returns DTOs. Structurally it occupies the slot a data source occupies in the layering most Flutter and Android projects use, and adding a class between the two would have been a class that forwards.

The argument that changed it is not structural. A data source is shaped by **what the consumer needs**; a capability is shaped by **what the dependency offers**. With only the capability, the shaping has nowhere to go but the repository — so `SpaceRepositoryImpl` grew a level-by-level directory walk, and `RecentSpacesRepositoryImpl` grew JSON encoding and a storage key. Neither is a product rule, and both were sitting in the class whose whole job is product rules.

The second argument is arrival, not shape: the M2 search index gives `SearchRepository` two origins for the same data — the index, which is a cache, and the disk, which is the truth. A repository choosing between two sources is what a repository is for; a repository that also *is* both of them is not.

## Decision

**A repository obtains nothing itself. A data source does, and the repository orchestrates, converts and translates.**

```
tom_domain      SpaceRepository            ← the contract, in the domain's words
tom_data        SpaceRepositoryImpl        ← order, DTO → entity, failure translation
                SpaceDataSource            ← how it is gathered
tom_infra       Filesystem, GitClient      ← what the machine offers
```

Five sources today, one per aggregate: `SpaceDataSource`, `DocumentDataSource`, `GitDataSource`, `MarkdownDataSource`, `RecentSpacesDataSource`.

**A source is a concrete class, not an interface.** Whatever varies, varies at the capability below it — a second interface here would be one nothing implements differently.

**A source knows no domain type.** What it returns is what the capability produced, or a DTO of its own when the storage forced a shape: `RecentSpaceDto` keeps `lastOpened` as text because JSON has no `DateTime`, and the instant appears one layer up. Git is the same idea without a class — its output in the format `GitClient` documents is its DTO, and the parsers that turn it into entities stay in the repository.

**A source does not translate failures.** It hands the technical failure up untouched. Translating is the repository's single job at that boundary ([Decision 5](005-errors-use-result-with-sealed-classes.md)), and a source that did it would need the domain's vocabulary, which is the thing this layering removes.

**A repository may still name a capability's failure.** Naming a type in order to translate it is not obtaining data. What a repository may not do is *hold* a capability, and that is the form the check takes — `tom rules` fails on a field of a capability type in a `*_repository_impl.dart`.

## Consequences

**The shaping moved, and it took its rules with it.** The `.git/` walk is the clearest case: a recursive listing from the capability enters `.git/` before anything can filter it, so the walk goes one level at a time and decides before descending. That is inseparable from the policy it serves, so both live in `SpaceDataSource` — the file tree's rule is now enforced by the thing that does the walking rather than by the thing that interprets the result.

**One repository shrank to what it always claimed to be.** `SpaceRepositoryImpl` went from 215 lines to 153, and what is left is the order the two questions are asked in, the DTO-to-entity turn, and two failure translations. 602 tests passed across the move without a single assertion changing, including the ones that prove `.git/` is never even listed.

**A thin source is accepted.** `GitDataSource` is twelve one-line forwards, and that is the honest cost of a command-line tool where every question is one command. The alternative — giving it the parsers — would have had it building a `CommitEntity`. It is also where a question needing two commands gets composed, which M1 asks for the moment the status bar shows how far ahead of its upstream a branch is.

**A swallowed failure surfaced.** `RecentSpacesRepository` promises `Result<T, Never>`, and it was keeping that promise by discarding what the store said — including the result of a write, which was not even read. A preferences folder nobody can write would have forgotten the user's spaces on every restart in silence. The promise stands, because the caller genuinely has nothing to do; the failure now goes to `Observability` instead ([Decision 11](011-telemetry-is-opt-in.md)), which is the one place a failure nobody handles is allowed to end.

## Alternatives considered

**Keep the capability as the source.** One fewer layer, and every property people ask a data source for — an interface, a swappable implementation, DTOs out, no domain knowledge — was already true of the capability. Rejected for the two reasons above: the shaping had nowhere to go, and M2 brings a repository with two origins.

**Let the source return domain types.** It would make the repositories one line each. Rejected because the source would then name entities, and the boundary this decision draws would exist only in the folder names.

**Let the source swallow its own failures**, so `RecentSpacesRepositoryImpl` could stay simple. Rejected: a source that hides what the store said leaves the repository unable to keep a promise it did not make, and the silence is exactly the defect this decision found.
