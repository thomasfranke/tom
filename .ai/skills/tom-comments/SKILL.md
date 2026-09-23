---
name: tom-comments
description: Writes and trims the comments and dartdoc in this repository. Use this skill when writing a new class, method or library and reaching for a comment; when reviewing a diff and judging whether a comment earns its lines; when the user says "the comments are too long", "keep them cohesive", "trim this", or asks what belongs in a dartdoc. Also use before adding a paragraph to any existing dartdoc.
---

# TOM — writing a comment

The rule is one sentence, in [`layers.md`](../../../docs/technical/layers.md#inside-a-package): **a comment is two or three lines — what the thing is, then why it is that way.** This skill exists because knowing the rule is not what keeps it. The rule was written down, read, and then broken in the same session by a 23-line dartdoc — so what follows is shape and examples, not a restatement.

## The three shapes, and nothing else

**The `library` line.** One sentence, no blank line, no second paragraph. It says what the file is *for*, not what is in it — a reader who wants the contents reads the contents.

```dart
/// Reading and writing one document's bytes.
library;
```

**The dartdoc.** First line says what the thing is, in a noun phrase. Then, after a blank line, the reason it is that way — the decision a reader would otherwise have to reverse-engineer or, worse, undo.

```dart
/// The last segment of [path], either platform's separator.
static String _lastSegmentOf(String path) => ...
```

```dart
/// Whether [folder] is there.
///
/// False for a folder that is gone; a failure when the machine will not
/// say, which is not the same answer.
Future<Result<bool, FilesystemFailure>> exists(String folder) => ...
```

**The why-comment, inside a body.** Only where the code reads wrong without it. It explains the choice, never the mechanics.

```dart
// Written beside the target and renamed over it, because a rename is the
// only write the operating system finishes or does not start: the files
// are the truth for this product, and a document half-written by a crash
// is a document lost.
await temporary.writeAsString(content, flush: true);
```

## What is not a comment

- **Restating the signature.** `/// Returns the list of entries.` on `entries()`. Delete it; Dart already said that.
- **Narrating the code.** `// loop over the entries and add each one`. If the loop needs narration, the loop needs a name.
- **Repeating `docs/`.** The canonical form of a rule is the dartdoc of the code that implements it ([`AGENTS.md`](../../../AGENTS.md)) — so the rule goes in *one* dartdoc and everything else links to it. Two copies is one copy and one future lie.
- **A decision's reasoning in full.** That is what `docs/technical/decisions/` is for. The dartdoc names the decision and links; it does not argue the case again.

## The exception, and its ceiling

A longer dartdoc earns itself in exactly two situations, and both are rare:

1. **A rule whose only home is this file.** Nowhere else documents it, and a reader who does not know it will break something.
2. **A trap that costs an afternoon.** The `markdown` package recognising its own syntaxes *by type*, so a decorator silently changes the parse. Someone will try the decorator again; the comment is what stops them.

Neither licenses a page. **Twelve lines is the ceiling** — past that, either the paragraph belongs in `docs/technical/` with a link from here, or it is two comments in a trench coat.

## The trim, worked

This is a real dartdoc from this repository, before and after. It said three true things and took twenty-three lines to say them.

**Before** — three paragraphs, each restating the one above it, plus the contract's own dartdoc quoted back:

```
/// The rules, and nothing about storage. How a row is spelled, which key it
/// lives under and how it is encoded belong to the source ([Decision 25](…));
/// what is left here is what the product decided: newest first, one row per
/// folder, a bounded list.
///
/// **A failure never propagates as one.** Every method answers success even
/// when the store could not be read, because the contract says everything
/// here is a convenience and no caller should be made to handle it
/// ([RecentSpacesRepository]). What a broken store costs is the list, not the
/// session — and `Result<T, Never>` is that promise checked, since a
/// `Failure<T, Never>` cannot be constructed.
///
/// Not handing a failure to the caller is not the same as losing it. A
/// preferences folder that cannot be written would otherwise forget the
/// user's spaces on every restart in silence, and the bug report would say
/// "TOM forgets my spaces" with nothing behind it. Every failure goes to
/// [Observability] instead ([Decision 11](…)), which is no-op by default and
/// is the one place a failure nobody handles is allowed to end.
```

**After** — same three things, nine lines:

```
/// The product's rules and nothing about storage: newest first, one row per
/// folder, a bounded list. How a row is spelled and where it is kept is the
/// source's ([Decision 25](…)).
///
/// **A failure never reaches the caller, and is never dropped either.**
/// `Result<T, Never>` is the contract's promise that nothing here is worth
/// interrupting a session for; the failure goes to [Observability] instead,
/// so a preferences folder nobody can write is findable rather than silent.
```

What came out: the quote from `RecentSpacesRepository`'s own dartdoc (link, don't restate), the explanation of why `Failure<T, Never>` cannot be constructed (that belongs on `Result`), and the imagined bug report (a good line in a code review, not in a file read a hundred times).

## Before adding a paragraph, ask three things

1. **Is it already written somewhere?** A contract's dartdoc, a Decision, `layers.md`. Then link.
2. **Would the next reader undo the code without it?** No — then it is not load-bearing.
3. **Is it about this file, or about the idea?** The idea goes in `docs/technical/`.

## Keep it prose

Cutting a paragraph into a list of fragments is not the same as making it short. Two sentences of prose beat five bullets of noun phrases — the sentences carry the *because*, which is the whole reason the comment exists.
