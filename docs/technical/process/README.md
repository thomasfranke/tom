# Process

Getting the repository building, keeping it building, and the settings that
live outside the code.

| File | Answers |
|---|---|
| [`setup.md`](setup.md) | Prerequisites, the clone, where things are, and how a dependency is added |
| [`commands.md`](commands.md) | The `tom` CLI — every command worth knowing, and what `make` is |
| [`ci.md`](ci.md) | The two levels: what a PR must pass, and what a tag triggers |
| [`versioning.md`](versioning.md) | What counts as breaking for a desktop app, before and after 1.0, and deprecation |
| [`repository-settings/`](repository-settings/README.md) | Access, branch and tag protection, Actions policy, the CLA bot — the configuration nobody can review in a diff |

The human-facing version of the branch and commit workflow is
[`CONTRIBUTING.md`](../../../CONTRIBUTING.md); the agent-facing one is the
`tom-git-workflow` skill.

---

*See also: [technical/](../README.md) · [conventions/testing.md](../conventions/testing.md)*
