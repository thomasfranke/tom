# About, and updates

Which TOM this is, and whether there is a newer one.

**Status:** Shipped · Milestone M3 — Planned: `Update and restart`, the download and `Restart now`

## About

- **The last row of the [preferences popover](../preferences/the-popover/doc.md)**: `About TOM` with the running version at its right. Pressing it shuts the popover and opens a dialog.
- **The dialog says what this build is**: the icon, the name and its line, then `Version` with the build it was made from, `Platform` and `License`.
- **Three links**: `Source on GitHub`, `Licenses` — those of what TOM is built with — and `Release notes`. Each opens in the browser.
- **`Close` shuts it**, as Escape and a press outside do.

## Updates

- **Builds are published on GitHub Releases**, one per tag; that is where a version is downloaded from and where the app asks what the latest is.
- **The app asks when it is asked to, and on opening until the person says no**: `Check for updates` in the dialog, or on opening while **`Check for updates when TOM opens`** in the popover stays ticked — a box that is on until they untick it. The one request carries nothing about the person or the machine ([about](../../about.md), principle on telemetry).
- **Until a first version is published the button is unavailable** and the line above it says `No release yet.` — the state the app ships first. **Whether a release exists is a build flag, `TOM_RELEASES`**, which the release pipeline sets once the first one is published; the version and the build in the dialog are `TOM_VERSION` and `TOM_BUILD`, set the same way.
- **While it asks**, a spinner sits before `Asking GitHub for the latest release…` and the button waits.
- **Up to date**: `TOM <version> is the latest version.` and when it was checked. The button stays, to ask again.
- **A newer version**: both versions are named, with a link to what is new, and one action — **`Update and restart`** — downloads it, replaces this one and opens it again. `Later` changes nothing.
- **The download shows how far it is** — a bar that fills, since a download knows its size — and `Cancel` throws the partial file away.
- **When it is on disk**: `Restart now`, or `Later`, which keeps the download so the next opening is the new version. **A document with unsaved changes asks first**, as [leaving a space](../workspace/leaving-a-space/doc.md) does.
- **GitHub not answering is said**, in `modified`, with `Try again`. The old answer is not left on screen.
- **An update found by the opening check is announced in two places, quietly**: a dot in `accent` on the gear, with `About TOM` reading `Update available` where the version was; and **`Update available: <version>` in the [status bar](../workspace/status-bar/doc.md)**, in `accent`, pressed to open the dialog. No band and no dialog on launch — an update is never urgent.

## Not decided

- What replaces the running app on each platform, and under what signature — a library per platform and a decision of its own. `Update and restart` waits on it and on code signing; the dialog and the check do not.

## Mocks

- **about TOM** — the dialog before any release exists. [light](../../design/screens/desktop/about-updates/about-tom-light.svg) · [dark](../../design/screens/desktop/about-updates/about-tom-dark.svg).
- **about — the update states** — checking for updates · up to date · update available · downloading the update · ready to restart · could not check. [light](../../design/screens/desktop/about-updates/about-the-update-states-light.svg) · [dark](../../design/screens/desktop/about-updates/about-the-update-states-dark.svg).
- **an update is waiting** — the gear's dot, the popover's row, the status bar. [light](../../design/screens/desktop/about-updates/an-update-is-waiting-light.svg) · [dark](../../design/screens/desktop/about-updates/an-update-is-waiting-dark.svg).
- **restart now, with unsaved work — the question** — asked before the restart. [light](../../design/screens/desktop/about-updates/restart-now-with-unsaved-work-the-question-states-light.svg) · [dark](../../design/screens/desktop/about-updates/restart-now-with-unsaved-work-the-question-states-dark.svg).

---

*See also: [product/](../README.md) · [preferences/](../preferences/README.md) · [workspace/regions/](../workspace/regions/doc.md)*
