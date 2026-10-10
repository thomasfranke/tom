# About, and updates

Which TOM this is, and whether there is a newer one.

**Status:** Draft · designed, not built — boards on `20 · Screens: Preferences`, drawn 2026-10-09, not yet exported

## About

- **The last row of the [preferences popover](../preferences/the-popover/doc.md)**: `About TOM` with the running version at its right. Pressing it shuts the popover and opens a dialog.
- **The dialog says what this build is**: the icon, the name and its line, then `Version` with the build it was made from, `Platform` and `License`.
- **Three links**: `Source on GitHub`, `Licenses` — those of what TOM is built with — and `Release notes`. Each opens in the browser.
- **`Close` shuts it**, as Escape and a press outside do.

## Updates

- **Builds are published on GitHub Releases**, one per tag; that is where a version is downloaded from and where the app asks what the latest is.
- **The app asks only when it is asked to**: `Check for updates` in the dialog, or on opening when the person ticked **`Check for updates when TOM opens`** in the popover — a box that is off until they tick it. Nothing leaves the machine unasked ([about](../../about.md), principle on telemetry).
- **Until a first version is published the button is unavailable** and the line above it says `No release yet.` — the state the app ships first.
- **While it asks**, a spinner sits before `Asking GitHub for the latest release…` and the button waits.
- **Up to date**: `TOM <version> is the latest version.` and when it was checked. The button stays, to ask again.
- **A newer version**: both versions are named, with a link to what is new, and one action — **`Update and restart`** — downloads it, replaces this one and opens it again. `Later` changes nothing.
- **The download shows how far it is** — a bar that fills, since a download knows its size — and `Cancel` throws the partial file away.
- **When it is on disk**: `Restart now`, or `Later`, which keeps the download so the next opening is the new version. **A document with unsaved changes asks first**, as [leaving a space](../workspace/leaving-a-space/doc.md) does.
- **GitHub not answering is said**, in `modified`, with `Try again`. The old answer is not left on screen.
- **An update found by the opening check is announced in two places, quietly**: a dot in `accent` on the gear, with `About TOM` reading `Update available` where the version was; and **`Update available: <version>` in the status bar**, in `accent`, pressed to open the dialog. No band and no dialog on launch — an update is never urgent.

## Not decided

- What replaces the running app on each platform, and under what signature — a library per platform and a decision of its own. Until then `Update and restart` is drawn, not built.

## Mocks

Drawn on `20 · Screens: Preferences`, both themes, **not yet exported**: **about tom** (no release yet) · **checking for updates** · **up to date** · **update available** · **downloading the update** · **ready to restart** · **could not check** · **an update is waiting** (the gear's dot, the row, the status bar).

---

*See also: [product/](../README.md) · [preferences/](../preferences/README.md) · [workspace/regions/](../workspace/regions/doc.md)*
