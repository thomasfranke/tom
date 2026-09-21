# Decision 20 — The macOS app is not sandboxed

**Status:** accepted

## Context

Flutter generates a macOS runner with `com.apple.security.app-sandbox` enabled, and that is the right default for most apps. It is not compatible with this one, and the incompatibility is not a detail of one screen.

The App Sandbox forbids an app from:

- **executing a binary outside its own bundle** — so no `/usr/bin/git`;
- **reading outside its container** — so no `~/.gitconfig`, no `~/.ssh`, and no folder the user picks without an explicit entitlement;
- **reaching the user's credential helpers**, which is how their git authenticates today.

Every one of those is load-bearing. [Decision 2](002-git-via-system-binary.md) drives the system binary precisely so that *"credentials, SSH and config come for free: it is the user's own git running. Zero authentication implemented."* [Decision 12's rule 12](../../../AGENTS.md) makes a space a folder anywhere on disk, not a repository the app manages. Sandboxing would mean implementing authentication and a file-access story — building the two things the product deliberately does not build.

Found the ordinary way: the folder picker on Home did nothing.

## Decision

`com.apple.security.app-sandbox` is **false** in both `DebugProfile.entitlements` and `Release.entitlements`, with the reason written in the files themselves.

## What it costs

**The Mac App Store**, which requires sandboxing. The roadmap had already given it up without saying so: macOS ships as a **dmg** (M3), like Windows ships an msix and Linux an AppImage. Saying it here turns an implicit consequence into a stated one.

It does **not** cost notarisation or Gatekeeper: a non-sandboxed app is still signed, still notarised, and still opens without a warning. Signing remains an open question in the [roadmap](../../roadmap.md#open-questions) for its cost, not for its possibility.

## What this is not

Not a licence to reach anywhere. The product's own rules are unchanged and are stricter than the sandbox would be: nothing is written outside the user's space and the application-support folder, telemetry stays opt-in and off ([Decision 11](011-telemetry-is-opt-in.md)), and no data leaves the machine. The sandbox was enforcing a boundary TOM was already respecting, while blocking the one thing it exists to do.

## Windows and Linux

Nothing equivalent. Neither has a mandatory sandbox for a desktop application, and neither store is a target.

## Revisit when

A Mac App Store release becomes a business goal — at which point this decision is the thing that has to give first, and what replaces it is `libgit2` via FFI ([Decision 2](002-git-via-system-binary.md) already names that trigger for mobile, which has the same constraint for the same reason).
