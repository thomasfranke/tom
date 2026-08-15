# Decision 2 — Git through the system binary first, libgit2 later

**Status:** accepted

## Decision
Phase 1 drives the system's `git` binary (`Process.run`), behind the `GitClientInterface` contract.

## Rationale
MVP speed; behavior identical to the user's own git (credentials, SSH and config come for free); libgit2 via FFI is an optimization, not a requirement.

## Consequences
- The app requires git installed (acceptable: the target audience is developers).
- The contract allows swapping the implementation without touching `application/`.

## Revisit when
Performance on large repos, or distribution to a non-developer audience, requires embedding the library (`Libgit2GitClient` via FFI).

The mobile platforms raise the same trigger, and no longer hypothetically: iOS and Android are a committed post-1.0 direction ([roadmap](../product/roadmap.md#phases)), and neither offers a `git` binary or a free filesystem. `Libgit2GitClient` is therefore a *scheduled* implementation of `GitClientInterface`, not a speculative one — which is the whole reason the contract exists.
