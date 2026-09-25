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

## What enforces it

| Mechanism | Catches |
|---|---|
| the pubspecs | an import of a package the layer never declared — it does not resolve |
| `depend_on_referenced_packages: error` | that same import arriving through a *transitive* dependency, which would otherwise compile |
| `implementation_imports: error` | reaching into another package's `lib/src/` instead of using its barrel |
| `src/test/integrity/architecture_test.dart` | what no pubspec can express — see below |

The test carries three checks the mechanisms above cannot make:

- a dependency **added to a pubspec**, after which the illegal import is
  entirely legal;
- an **SDK library**, which needs no declaration at all. `dart:io` is
  available to every package by default, so the pubspec graph has nothing to
  say about a domain entity calling `Process.run`. The test holds a second
  table — which *capabilities* each layer may import — and scans every `.dart`
  file under `lib/`, generated code included;
- a **Flutter package in `dev_dependencies`**, the quiet version of the leak:
  nothing imports a widget, but the package stops running under `dart test`
  and framework independence stops being provable.

## When mobile arrives (Phase 3)

`apps/mobile` sits beside `apps/desktop` with its **own screens**, sharing
`tom_presentation` — which is why that package is pure Dart. Panels do not
become screens: a layout drawn for a phone is drawn from the job, not ported
from the desktop. What the two do share is the look — `tom_ui`, the marks and
the tokens ([Decision 26](decisions/026-the-look-is-a-package.md), which
revises the "no shared-UI package" this section used to state: the objection
was to sharing *layout*, and identity is not layout). `tom_infra` grows a
second implementation per capability (`libgit2/` next to `dart_io/`), chosen
at the composition root.

## Where the rest is

| Question | Chapter |
|---|---|
| What a package looks like inside, and what a name has to say | [`conventions/`](conventions/README.md) |
| How the layers behave while running | [`runtime/`](runtime/README.md) |
| What the entities and value objects are | [`domain/`](domain/README.md) |
| Which external packages are in, and why | [`stack/`](stack/README.md) |

---

*See also: [technical/](README.md) · [decisions/](decisions/README.md)*
