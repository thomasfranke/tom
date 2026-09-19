---
id: spec-0001
task_ref: task-0001
status: draft
created: 2026-09-19T21:41:32Z
---

# spec-0001 — Decide whether re_editor can carry source mode

**References:** [task-0001](../tasks/task-0001-editor-ast-spikes.md)

- **Goal:** Answer with evidence whether `re_editor` can carry source mode on a document of real size — and record the verdict, or name the fallback.

## Scope

In: a throwaway desktop harness; a markdown document of 2000+ lines; keystroke-to-paint latency; caret and selection behaviour; the desktop shortcuts a writer expects; find and replace; the package's license.

Out: integrating the editor into the shell, theming, the formatting shortcuts of M3, anything touching mobile. The spike decides; it does not build.

## Steps

1. Build a minimal Flutter desktop harness that loads one file into `re_editor` and does nothing else.
2. Assemble a markdown document of at least 2000 lines carrying headings, tables, fenced code and long paragraphs.
3. Measure keystroke-to-paint while typing mid-document, and again with the caret directly after a large table.
4. Exercise the desktop shortcuts: word and line jumps, select-to-end, undo/redo, copy/cut/paste, and multi-caret where offered.
5. Exercise find and replace, including replace-all across the whole document.
6. Confirm the license against Decision 1 and record the exact version measured.
7. Write the verdict: adopt, adopt with named gaps, or fall back to a custom `TextField`.

## Acceptance criteria (EARS)

- When a 2000-line document is open and a character is typed, the system shall paint the result within one 60fps frame budget on the reference machine.
- When the verdict is written, it shall name the exact `re_editor` version it was measured against.
- When a shortcut listed in Scope is unavailable, the verdict shall record it as a named gap rather than as a blocking failure.
- When the license is not MIT-compatible, the spike shall end in the fallback regardless of every other result.

## Edge cases

- A single line of several thousand characters, with no wrapping opportunity.
- CRLF line endings.
- Non-ASCII text and emoji inside a table cell.
- The file changing on disk while the harness holds it open.

## Tests required

None merged. The harness is throwaway and never enters `src/`; the deliverable is the written verdict. Measurements are recorded in the Outcome, not asserted by a test.

## Definition of Done

- [ ] The verdict rests on numbers, not impressions.
- [ ] The version measured is named.
- [ ] Where the verdict is the fallback, the reason is one sentence a reader can disagree with.
- [ ] Spike A is checked off in `docs/tasks/roadmap.md`.

## Proposed product changes

- none — a spike decides; it ships no behaviour.

## Proposed technical changes

- `technical/dependencies.md#editor-source-mode` — record the verdict, the version measured, and any named gaps.

## Outcome

_(fill after execution)_
