<h1 align="center">TOM</h1>
<p align="center"><strong>Team-Oriented Markdown</strong></p>
<p align="center">A Git client built for documentation, not code.</p>

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
  <img alt="Status: pre-alpha" src="https://img.shields.io/badge/status-pre--alpha-orange.svg">
  <img alt="Platforms: Windows, macOS, Linux" src="https://img.shields.io/badge/platforms-windows%20%7C%20macos%20%7C%20linux-lightgrey.svg">
</p>

---

> **Pre-alpha: there is no application yet.** This repository currently holds the architecture, the decisions behind it, and the code patterns the implementation will follow. Building in public from the first commit — the design came before the first line of code, and it is all in [`docs/`](docs/).

## The problem

Engineering teams keep their documentation as markdown in Git repositories, and every current option forces a bad trade-off:

| Option | Problem |
|---|---|
| Confluence / Notion | Paid, cloud-bound, disconnected from the code, weak versioning |
| Obsidian + Git plugin | Git is a bolted-on add-on; built for personal notes; closed source |
| VS Code + extensions | Hostile to non-developers; no documentation experience |
| MkDocs / Docusaurus | Read-only output; editing still happens in a code editor |

## The bet

The differentiator is not the editor — it is **the Git workflow as a first-class citizen**, designed for documentation:

- **Rendered markdown diff** — see changes over the *formatted* document, not `+/-` on raw text. Nothing does this well today.
- **Branching without ceremony** — switch branches and watch the docs change; commit and push in a single gesture.
- **History and section blame** — who wrote this paragraph, and in which PR.
- **Assisted conflict resolution** — both sides rendered side by side.
- **A documentation experience** — space navigation, full-text search, wikilinks, images.

Your `.md` files stay plain files on disk. Any other tool edits the same files without breaking anything. No proprietary format, no mandatory cloud, no account.

## Principles

Files are the truth, Git is the backbone rather than a plugin, everything works offline, your documents never leave your machine unless you ask them to ([Decision 11](docs/decisions/011-telemetry-is-opt-in.md)), and it's MIT — whatever is free today stays free. The full list, with the reasoning behind each one, is in [product.md](docs/product/product.md#principles).

## Documentation

Everything is in [`docs/`](docs/) — and yes, it is edited the way TOM proposes: markdown, in this repo, reviewed in pull requests.

| | |
|---|---|
| [Product](docs/product/product.md) | What this is, and the non-goals it will not drift into |
| [Architecture](docs/architecture/layers.md) | The seven packages, the graph, and what enforces it |
| [Decisions](docs/decisions/) | Every architectural choice and why — the folder listing reads as a summary |
| [Roadmap](docs/product/roadmap.md) | What is being built, in what order, and by which package |
| [Products](docs/products/) | What each feature must do, one folder per feature |

## Status

Phase 0: technical spikes. The milestones are in [`docs/product/roadmap.md`](docs/product/roadmap.md).

Watch or star the repository if you want to know when there is something to run.

## Contributing

Contributions are welcome — please read [CONTRIBUTING.md](CONTRIBUTING.md) first, and in particular the [non-goals](docs/product/product.md#non-goals-equally-important): TOM deliberately will not become a WYSIWYG editor, a real-time collaboration tool, or a Notion-style workspace.

Security issues: see [SECURITY.md](SECURITY.md) — please do not open a public issue.

## License

MIT — see [LICENSE](LICENSE).
