# Pattern: Dependency injection

Complements [Decision 7](../decisions/007-external-dependencies-behind-contracts.md) (Riverpod restricted to presentation + bootstrap/di) and [Decision 8](../decisions/008-monorepo-with-pure-dart-core.md). The core does not know Riverpod: classes receive everything **through constructors**. The object graph is assembled in the app's **composition root**.

## Mirrored composition root

No monolithic `di.dart`: the folder mirrors the core's areas, one small file per area.

```
apps/tom_desktop/lib/bootstrap/di/
├── observability_providers.dart
├── git_providers.dart          # gitClient, gitRepository, git use cases
├── documents_providers.dart
├── diff_providers.dart         # parsers, blockDiffer, computeRenderedDiff
└── search_providers.dart
```

Navigation rule: *the wiring for X lives in `di/x_providers.dart`*. Colocating providers next to their classes applies only to presentation's own artifacts (notifiers/states).

## The three lifetimes

| Lifetime | What | Mechanism |
|---|---|---|
| **App-lifetime** | parsers, `BlockDiffer`, `ObservabilityInterface`, config | plain `@Riverpod(keepAlive: true)` |
| **Space-lifetime** (one per open space) | `GitClient` (the serialized queue is PER space), watcher, FTS5 index, `SpaceSession` | **`.family` keyed by the space root** + `keepAlive` tied to the session; `autoDispose` tears down watcher/connections when the space closes |
| **Transient** | use cases | default `@riverpod` — lightweight classes, created on demand |

Per-space scoping is the central requirement: the git queue and the sqlite connection live tied to the space, not floating — the lifecycle that would otherwise produce a class of "closed resource" bugs is solved by design.

## Canonical provider file template

```dart
// apps/tom_desktop/lib/bootstrap/di/git_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'git_providers.g.dart';

/// Git client (serialized queue) — one per open space.
@Riverpod(keepAlive: true)
GitClientInterface gitClient(final Ref ref, final String spaceRoot) =>
    ProcessGitClient(root: spaceRoot);

/// Git repository — one per open space.
@Riverpod(keepAlive: true)
GitRepositoryInterface gitRepository(final Ref ref, final String spaceRoot) =>
    GitRepositoryImpl(
      client: ref.watch(gitClientProvider(spaceRoot)),
      statusParser: ref.watch(gitStatusParserProvider),
      logParser: ref.watch(gitLogParserProvider),
    );

/// Commit use case.
@riverpod
CommitChanges commitChanges(final Ref ref, final String spaceRoot) =>
    CommitChanges(
      ref.watch(gitRepositoryProvider(spaceRoot)),
      ref.watch(observabilityProvider),
    );
```

Fixed points:

- Composition root providers **only instantiate and wire** — zero logic.
- Space-scoped providers always use a `family` keyed by `spaceRoot`.
- `ref.watch` while wiring (the graph rebuilds if a dependency changes); never `ref.read` inside a DI provider.
- The core is imported through its barrel file (`package:tom_core/tom_core.dart`).

## Anti-patterns

| ❌ | Why |
|---|---|
| `@riverpod` / `Ref` in a `tom_core` file | Violates Decision 7; the core stops being framework-agnostic |
| A use case receiving `Ref` instead of dependencies | Implicit injection; tests then require a container |
| A space-scoped provider without `family` (app singleton) | State from one space leaks into another; wrong queue/connection |
| Business logic inside a DI provider | The composition root wires, it does not decide |
| `get_it`/`injectable` | Redundant with Riverpod; a global service locator contradicts explicit injection; per-space scoping is their weak spot and family's strength |

## Testing

- **Core:** direct constructors with fakes — `CommitChanges(FakeGitRepository(), NoopObservability())`. No container.
- **Presentation:** `ProviderContainer` with overrides of the composition root providers.
