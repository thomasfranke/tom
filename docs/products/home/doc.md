# Home

The first screen anyone sees: open a space, or start one from a remote URL.

**Status:** Planned · Milestone M0 (clone by URL: M3) · Mobile: not designed yet

## Rules — desktop

- With no space open, the app offers three ways in: choose a folder, clone from a URL, or pick a recently opened space.
- A space is a folder, not a repository: TOM can open a subfolder of a repository (a `docs/` folder, say) and still run Git against the repository root.
- Opening a folder that is not inside a Git repository is a named failure with a clear explanation, not a crash or a silent limited mode. TOM never creates a repository on the user's behalf.
- Recently opened spaces are offered here, so returning to one is one click.
- A repository can be cloned by pasting its URL, from this same screen. Progress and failure (bad URL, auth required, network down) are shown in place — never a silent hang. Once cloned, the repository opens as a space immediately, with no separate manual step.

## Rules — mobile

Not designed yet. `documents` ([file-tree](../navigation/file-tree/doc.md)) assumes a space is already open; how a space is chosen or connected on a phone in the first place hasn't been drawn.

## Mocks

- Desktop: [empty-state](mocks/empty-state.excalidraw) — no space open: brand, open a folder, recent.
- Desktop: [not-a-repository](mocks/not-a-repository.excalidraw) — the one way opening a folder fails.
- Mobile: not drawn yet.

---

*See also: [product.md](../../product/product.md) · [roadmap.md](../../product/roadmap.md) · [Decision 9](../../decisions/009-space-session-is-single-source-of-truth.md)*
