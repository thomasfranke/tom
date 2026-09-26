# Markdown and diff (the heart)

| Package | License | Role |
|---|---|---|
| `markdown` | BSD-3 | The official Dart parser — **chosen**, `^7.3.0` ([Decision 19](../decisions/019-blocks-come-from-the-markdown-package.md)). The AST has no source positions; they are recovered by extending each block syntax. It belongs to `tom_infra`, behind the `MarkdownParser` capability: text in, spans out, and no package type above it |
| `flutter_markdown_plus` | BSD-3 | Renders the inline content **inside** a block — **in use**, `^1.0.12`. One `MarkdownBody` per block, never one for the document: block-level layout and the container around each block are ours, which is what the rendered diff needs ([runtime/preview.md](../runtime/preview.md)) |
| `diffutil_dart` | Apache-2.0 | Myers over lists — **chosen**, `^5.0.0` ([Decision 27](../decisions/027-blocks-are-aligned-by-myers-and-paired-by-words.md)). It belongs to `tom_infra`, behind the `TextDiffer` capability: sequences of text in, positions out. Its `equalityChecker` is what lets a *rewrite* be recognised as one, since blocks carry no identity. `diff_match_patch` was the alternative and rules itself out: 0.4.1 declares SDK `<3.0.0` |
| `re_highlight` | MIT | Syntax highlighting for code blocks in the preview — **in use**, `^0.0.3`, and no longer a choice between two since `re_editor` brings the same one ([Decision 18](../decisions/018-source-mode-uses-re-editor.md)). A language it does not know is drawn unstyled rather than guessed at |

> Spike B is answered and **neither fallback is taken** — no hand-written block
> parser, no Rust parser over `dart:ffi`
> ([Decision 13](../decisions/013-stack-is-flutter-and-dart.md)). What the
> package costs instead is one subclass per block syntax to recover positions,
> and a footnote in an isolated block that renders as literal text.

---

*See also: [domain/blocks.md](../domain/blocks.md) · [editor.md](editor.md)*
