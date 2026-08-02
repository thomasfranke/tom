# Versioning policy

TOM follows [semantic versioning](https://semver.org/). Because it is a desktop application rather than a library, "breaking change" needs a definition that fits what users and contributors actually depend on.

## What counts as breaking

| Breaks | Does not break |
|---|---|
| A space configured with one version stops opening in the next | Panel layout, colours, keyboard shortcuts changing |
| A file TOM writes into the user's repository changes format incompatibly | Internal package APIs changing (`tom_core` is not published) |
| The `TomModule` contract changes so an existing module no longer compiles | New optional members added to a contract |
| A CLI flag or `--dart-define` that users rely on is removed | A feature flag being removed after its feature ships |
| Minimum supported OS or git version is raised | New optional dependency added |

**The user's markdown files are never a compatibility concern** — TOM reads and writes plain `.md` and never owns a format. That is the whole point of the product, and it is why the breaking surface here is unusually small.

## Before 1.0

`0.x` releases may break anything in the left column, with the change stated prominently in the release notes. The MVP milestones are all `0.x`.

**1.0 is cut when** the MVP (M0–M3) is shipped, the rendered diff has reached v1, and the space/config format has been stable across at least two minor releases. It is a statement that the format and the extension contract can be relied on — not a statement about feature completeness.

## After 1.0

- **Major** — anything in the left column.
- **Minor** — new features, new optional contract members, new flags.
- **Patch** — fixes and performance work with no behavioural surprises.

Pre-releases use `-beta.N` (`v1.2.0-beta.1`) and are published from the same tag mechanism.

## Deprecation

A `TomModule` contract member that is going away is marked `@Deprecated` with the version that will remove it, kept for at least one minor release, and listed in the release notes. Anything that changes a written format ships with a migration path, or does not ship.

## Version alignment across the two repositories

The product has one version number, and it is **defined by the public repository**.

- A release is tagged `v0.4.0` on `tom`. That tag is the source of truth for the version.
- `tom-pro` is tagged with the **same** number and its build pins the public repo at that exact tag — never at a floating branch. The binary is therefore reproducible: the same two tags rebuild the same artifact months later.
- `tom-pro` never invents its own numbering. A user who sees "TOM 0.4.0" in the About dialog can find `v0.4.0` on the public repo and read exactly what is in it.
- The number does not change between an unlicensed and a licensed run of the same binary — a licence activates features, not a different version.

**Fixes exclusive to the commercial edition** (a bug in licence verification, say) need a new build without a public change. Those use a build suffix: `v0.4.0+2` — same product version, second build. The suffix never appears as a separate product version in release notes.

## The changelog

Generated from Conventional Commits since the previous tag ([workflow](../CONTRIBUTING.md#workflow)): `feat` entries become the features section, `fix` the fixes, and `BREAKING CHANGE` footers are surfaced at the top. This is the practical reason the commit convention is enforced rather than merely suggested.
