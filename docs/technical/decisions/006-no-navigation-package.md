# Decision 6 — No navigation package

**Status:** accepted

## Decision
No routing package in the MVP. Plain `Navigator` for dialogs only.

## Rationale
A panel-based desktop app (tree + editor + git panel in the same window) has *stateful layout*, not navigation. AutoRoute would add codegen and ceremony with no benefit.

## Revisit when
Real multi-screen flows appear (complex settings, staged onboarding).
