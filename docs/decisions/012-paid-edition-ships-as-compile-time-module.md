# Decision 12 — The paid edition ships as a compile-time module in a single binary

**Status:** accepted

## Context
The open-core model (Decision 4) requires paid features to live in a private repo without compromising the public repo's self-sufficiency. Dart compiles AOT — there are no plugins loaded at runtime; composition happens at compile time.

## Decision
1. **An extension point in the shell from M0:** the app exposes a public `TomModule` contract (panels, provider overrides, commands) and a `runTom(modules: [...])` entrypoint. Panels are registered through descriptors, never hardcoded in the shell.
2. **Two repositories, two entrypoints, one dependency direction:**
   - Public repo `tom`: defines the contract; `main.dart` calls `runTom(modules: [])`. **Clone it, build it, it works** — self-sufficient, the complete free-tier product.
   - Private repo `tom-pro` (future): a `tom_pro` package depending on the public one by path; `main_pro.dart` calls `runTom(modules: [ProModule()])`. The public repo never references the private one.
3. **A single distributed binary:** the official build (CI with access to both repos) compiles public + pro; paid features sit behind a **license key** verified in the app. No download matrix, upgrades without reinstalling.
4. **Licensing is a key plus good faith, not DRM:** the buyer is an organization (invoice, support, compliance) — the defense is commercial, not technical.
5. **The module mechanism ships in M0 even with an empty pro** — `runTom` + descriptors from the very first shell.

## Licensing model (once the first paid module exists)

- **No login, no account, no license server.** Purchase through a checkout acting as *merchant of record* (international taxes are their problem); the key arrives by email.
- **The key is a signed document, not a consumable:** payload `{ email, organization, seats, edition, valid_until }` + an **Ed25519** signature made with the project's private key. The app embeds only the public key; validating means checking the signature and the date. Local math, offline, with no "single use" — the key works on as many machines as it is pasted into (laptop, desktop, reinstall), because no activation ledger exists on any server.
- **Annual subscription with *perpetual fallback*:** letting it lapse keeps pro features working on the last covered version — what expires is the right to updates, not the software.
- **Seats on the honor system + contract.** Social mitigations, not technical ones: the UI shows *"Licensed to {organization} ({N} seats)"* — a leaked key carries its owner's name; the terms define the scope; and a denylist embedded in future updates is the emergency button for an egregious leak, still without a server.
- **No verification ever requires the network** — the app is offline-first down to billing (coherent with Decision 11). A leaked key decays by construction: it covers versions up to date X while paying customers get the new app.
- **Estimated build cost:** signing script + verification (tens of lines), an activation screen, checkout integration — about a week, zero infrastructure of our own.
- **Piracy is a priced-in cost:** lost conversion is near zero (whoever would pirate would not buy; whoever buys pays for invoice, compliance and support). The model's real exposure is a community clone of paid features — mitigated by the movable free/paid boundary in Decision 4.

## Rationale
- It is Decision 7 applied to the product itself: the paid edition is an "external dependency" behind a contract, isolated; the public repo does not even know it exists.
- Cost of being born extensible: hours. Cost of retrofitting a monolithic shell: weeks.
- A public `TomModule` contract is a feature, not a leak: it opens the door to a future community extension ecosystem.

## Consequences
- Contract and panel-registration templates: [../patterns/extension-modules.md](../patterns/extension-modules.md).
- M0 gains the "extensible shell" item.
- License infrastructure (signature verification, activation screen) is only built when the first paid module exists — the hook, not the vault.
