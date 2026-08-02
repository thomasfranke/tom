# Git integration: three conceptual layers

From the user's point of view, "integration" means opening a folder. Underneath:

1. **Layer 1 — Open the folder (entry point).** The user opens a local folder that already is a Git repo (`.git/` present). No server, no account, no import. Folder without a repo → offer `git init` or run in degraded mode (editing/preview only).
2. **Layer 2 — Drive the `git` binary (the real integration, phase 1).** The app runs `git` through `Process.run` (`status --porcelain=v2`, `log`, `diff`, `add/commit/push/pull`, `switch`) and parses the output. **Credentials, SSH and config come for free** — it is the user's own git running. Zero authentication implemented. *(See [Decision 2](../decisions/002-git-via-system-binary.md).)*
3. **Layer 3 — Remote APIs (post-MVP).** PRs, reviews, OAuth clone — via GitHub/GitLab REST APIs. Only after the core is validated.
