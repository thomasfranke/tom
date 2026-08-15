# Decision 11 — Observability behind a contract, telemetry opt-in

**Status:** accepted

## Context
The use case pattern captures unexpected exceptions and reports them. Calling a telemetry SDK directly from the application layer would (a) violate dependency isolation (Decision 7, Tier 1) and (b) in a local-first, privacy-friendly open source product, telemetry enabled by default contradicts the positioning and would be — rightly — attacked by the very community the project wants to attract.

## Decision
1. **Contract in the core:** `ObservabilityInterface` in `core/observability/` (`capture(error, stackTrace, {layer})` and the bare minimum). No layer knows about Sentry, print or any backend.
2. **Default: no-op.** The default implementation discards everything in release; in debug it may log to stderr. **No data leaves the user's machine by default.**
3. **Real telemetry is explicitly opt-in:** if it ever exists, it is an alternative implementation enabled only by an active choice in settings, with a clear description of what is sent. Never in the initial MVP.
4. Local crash reporting (a log file on the user's disk) is acceptable by default — the data does not leave the machine.

## Rationale
- Positioning coherence: "your files, your machine" must hold for errors too.
- Decision 7: observability is an external service → contract + isolated implementation.
- Flexibility: no-op, local file, hosted service — swappable in the composition root without touching the core.

## Consequences
- The use case template ([../patterns/error-handling.md](../architecture/core/error-handling.md)) always calls `_observability.capture(...)` — the contract, never a vendor.
- The product README/site can declare "zero telemetry by default" as a feature.
- If opt-in telemetry is implemented, it requires its own privacy section in the product documentation.
