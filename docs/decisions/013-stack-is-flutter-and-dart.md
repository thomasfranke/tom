# Decision 13 — The stack is Flutter and Dart

**Status:** accepted

## Context

TOM parses markdown, renders it, drives the `git` binary, runs on three desktop platforms and is meant to reach phones after 1.0 ([roadmap](../roadmap.md#phases)). Nothing in that description points at one obvious toolkit. This is the most consequential choice in the project — every other decision is written against it — so it is recorded here with its counter-argument rather than left implicit.

## Decision

Flutter and Dart, with a pure Dart core ([Decision 8](008-monorepo-with-pure-dart-core.md)) and a deliberately minimal editor ([Decision 3](003-editor-is-source-plus-preview.md)).

## The alternative, stated fairly

A web stack inside a native shell is genuinely stronger on the two hardest problems this project has:

| | Web stack | Dart |
|---|---|---|
| Markdown parsing | `remark` / `mdast` exposes source positions natively | Whether the `markdown` package does is the entire question of **Spike B** |
| Source editor | CodeMirror 6 and Monaco are mature and desktop-grade | `re_editor` is a promising package, still under test in **Spike A** |
| Rendering | `markdown-it` plus CSS; KaTeX and mermaid are one dependency away | A widget tree we assemble ourselves |
| PDF | Falls out of the webview | A separate problem entirely |

The usual objection to that path no longer holds either. Electron does not run on phones, but **Tauri 2 does** — so "a web stack cannot reach mobile" is simply false. The alternative is real, and on both open spikes it would win.

## Rationale

Three things decide it anyway.

**A solo maintainer working in spare time, who knows Dart.** Familiarity is not a tie-breaker here, it is the dominant term. A stack that is thirty percent better and three times slower *for this maintainer* is the worse stack for this project. Sustained output over years beats a better starting position.

**The web path buys those wins with a Rust backend.** Tauri's filesystem, process and git layer is Rust — a second language to maintain in precisely the layer where correctness matters most, traded for advantages in two layers that [Decision 3](003-editor-is-source-plus-preview.md) already minimized on purpose. The editor is Flutter's real weakness and it is the one thing this product deliberately does not need to be excellent at.

**One core, two platforms.** `tom_core` is pure Dart by construction, so mobile means new infrastructure implementations plus a new presentation — not a rewrite. That property is what keeps a future mobile app affordable for one person, and it is the reason the trade lands here rather than in the table above.

## Rust stays available without adopting Tauri

Choosing Dart does not forfeit the Rust ecosystem. A crate compiles to a native library and is reached over `dart:ffi` behind an ordinary infrastructure contract ([Decision 7](007-external-dependencies-behind-contracts.md)). That matters most for markdown parsing, where `pulldown-cmark`, `comrak` and `markdown-rs` all expose source positions that the Dart ecosystem may not.

It is the **third** option for Spike B, behind the `markdown` package alone and our own block parser with inline delegated to it ([domain model](../architecture/08-domain-model.md)). It is not the plan, and the price is real: a Rust toolchain in CI for every target, cross-compilation, and the loss of `dart test` as a self-contained proof that the core is framework-independent. It is named here so that it is not discovered *after* a hand-written parser has already been paid for.

FFI is on this project's path regardless — `libgit2` is the scheduled implementation of `GitClientInterface` for mobile ([Decision 2](002-git-via-system-binary.md)).

## Revisit when

Not for the desktop app: a rewrite costs more than this project has. The honest revisit is narrower — if both spikes fail and an FFI parser proves necessary, re-read this decision and check that the reasoning still holds with a second toolchain in the build.
