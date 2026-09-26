# Architecture

Eight packages in one pub workspace under `src/`. The layering is what the
pubspecs declare, so a violation does not resolve
([Decision 14](decisions/014-each-layer-is-its-own-package.md)).

```
core ← domain ← application ← presentation
  ↑       ↑                        ↑
  └─── infra ⇄ data ─────────────  desktop · mobile
                                       ↑
                                      ui
```

| Package | Holds | May depend on | Flutter |
|---|---|---|---|
| `tom_core` | `Result`, `AppFailure`, ports every layer needs (`Observability`) | nothing | no |
| `tom_domain` | entities, value objects, failures, repository contracts, ports, `BlockDifferService` | `tom_core` | no |
| `tom_application` | use cases | `tom_core`, `tom_domain` | no |
| `tom_infra` | capability contracts **and** their implementations — git, filesystem, settings, platform paths, markdown, search | `tom_core`, `tom_data` (for the DTOs that cross its contracts — [Decision 24](decisions/024-a-capability-is-a-folder.md); never `tom_domain`) | no |
| `tom_data` | DTOs, data sources, parsers, repository implementations | `tom_core`, `tom_domain`, `tom_infra` | no |
| `tom_presentation` | space session, notifiers, view state | `tom_core`, `tom_domain`, `tom_application` | no |
| `tom_ui` | colour roles, metrics, the brand marks, the components both applications draw ([Decision 26](decisions/026-the-look-is-a-package.md)) | nothing | **yes** |
| `tom_desktop` | composition root, screens | all of the above | **yes** |

Six of the eight run under `dart test`, with no Flutter binding available.
Folder names are short (`packages/core`); package names carry the `tom_`
prefix, because the folder is only a path while the package name is what every
import says.

`infra ⇄ data` is the one two-way edge, and it is deliberate: `infra` holds
each capability's contract and failures, `data` the DTOs that cross them, so
the two packages depend on each other and pub resolves the cycle
([Decision 24](decisions/024-a-capability-is-a-folder.md)). What `infra` never
depends on is `domain`.

What makes a violation fail rather than merely be discouraged:
[`enforcement.md`](enforcement.md). What changes when a second application
arrives: [`mobile.md`](mobile.md).

---

*See also: [technical/](README.md) · [decisions/](decisions/README.md)*
