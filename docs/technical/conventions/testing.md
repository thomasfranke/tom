# Testing

## The layout

`test/` **mirrors `lib/src/` exactly**, under one of three top-level folders —
`unit/`, `integration/`, `integrity/` — chosen by what the test needs, not by
which package it is in:

- `unit/` — pure logic, no I/O, fakes over real dependencies (failures,
  parsers, `BlockDifferService`, use cases, notifiers).
- `integration/` — talks to a real system (a `git init` temp repo, real disk,
  real sqlite). Slower, and the project's confidence differentiator — never
  mocked away.
- `integrity/` — asserts something about the codebase itself, not its runtime
  behavior (the layer graph, a barrel's exports). Workspace-wide checks live
  here too: the architecture test is
  `src/test/integrity/architecture_test.dart`.

Below that folder, the path matches `lib/src/` exactly, filename plus `_test`:
`lib/src/filesystem/dart_io/dart_io_filesystem_impl.dart` (integration, real
disk) is tested by
`test/integration/filesystem/dart_io/dart_io_filesystem_impl_test.dart`. The
layout answers "where are this file's tests, and what kind" without a search.

**Exactly** means exactly: no test file named after a theme rather than its
subject, and no second file for the same subject in the same kind. One subject
can have a file under two kinds — `json_file_settings_impl.dart` has a unit
test for the failures a real disk will not produce on demand, and an
integration test against a real one — because the kind is part of the path.

The one exception, and it needs no other: a test whose subject is the **stack**
rather than a class. `data/test/integration/spaces/opening_end_to_end_test.dart`
wires real disk, real git and a real settings file the way the composition
root does and asks the question the user asks. It mirrors nothing because it
is about no one file, and it is the only test that fails when the pieces are
each right and do not fit.

## What each subject gets

| Target | Type | Approach |
|---|---|---|
| Parsers (git porcelain, log, markdown AST) | unit | fixtures of real git output; pure and fast |
| `BlockDifferService` | unit + integration | a fake alignment for the classification; the real parser and the real differ over real markdown for what the two of them decide together |
| Use cases | unit | fake repositories; orchestration and failure propagation |
| Repository implementations | integration | a real repo created by `git init` in a temp dir |
| Notifiers | unit | `ProviderContainer` with overridden use cases |
| Diff view | widget / golden | screenshots of the main states |

Integration against real git is the project's confidence differentiator, and
runs on all three platforms.

---

*See also: [inside-a-package.md](inside-a-package.md) · [process/ci.md](../process/ci.md)*
