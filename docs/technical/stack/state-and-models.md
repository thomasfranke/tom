# State and models

| Package | License | Role |
|---|---|---|
| `flutter_riverpod` (app) + `riverpod` (presentation) | MIT | State; providers per space/document/panel. Two packages, one split: `tom_presentation` is pure Dart and takes the plain `riverpod`, the app takes the Flutter one. **Pinned exactly at 3.2.1**, because `riverpod_annotation` pins the runtime it generates against and the pair moves together. Note that Riverpod 3 does not export `Override` from its main barrel — it is in `misc.dart`, and `select` is in the runtime package rather than in `riverpod_annotation` |
| `freezed` + `freezed_annotation` | MIT | Mandatory for immutable entities, multi-field value objects, view-state and sealed hierarchies ([Decision 16](../decisions/016-freezed-is-mandatory-for-immutable-data.md)) — `GitStatusValueObject`, `CommitEntity`, `DiffBlock`… as they get built; already in use for the `AppFailure` hierarchies (`GitFailure`, `DocumentFailure`, `SearchFailure`, `FilesystemFailure`) in `tom_core`/`tom_domain`/`tom_infra` |
| `riverpod_annotation` + `riverpod_generator`, `build_runner` | MIT | Every provider is generated from an annotation — a `@riverpod` function for a seam, a `@riverpod class` for a notifier, which is what names `homeProvider` after `Home`. Both pinned exactly, like `freezed`: a generator that moves on its own writes a diff nobody asked for |

Where each of these is allowed to appear — Riverpod in `tom_presentation` and
the composition root only, Freezed in any layer — is
[`conventions/external-dependencies.md`](../conventions/external-dependencies.md).

---

*See also: [stack/](README.md) · [runtime/state.md](../runtime/state.md)*
