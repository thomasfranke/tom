# Decision 27 — Blocks are aligned by Myers, and paired by word overlap

**Status:** accepted

## Context

The rendered diff is the product's differentiator ([about.md](../../about.md)), and [Spike B](019-blocks-come-from-the-markdown-package.md) left it one constraint: **a block has no identity**. There is nothing to match on — 288 distinct heading paths across 848 blocks, 285 of them holding more than one — so the comparison has to align by position and then decide, for two blocks that ended up in the same place, whether one is a rewrite of the other or a deletion standing next to an addition.

That is two questions, and only the first has a published answer. Aligning two sequences is Myers; deciding that *"Prose."* became *"Prose, rewritten."* is a judgement about text.

[`stack/markdown-and-diff.md`](../stack/markdown-and-diff.md) had named two candidate packages and chosen neither. One of them decided itself: `diff_match_patch` is at 0.4.1 with an SDK constraint of `>=2.12.0 <3.0.0`, so it does not resolve in a Dart 3 workspace. `diffutil_dart` is Apache-2.0, current, and Myers over lists — and it takes an `equalityChecker`, which is exactly the hook the second question needs: what Myers treats as "the same item" is ours to define.

## Decision

**`text_differ` is a capability in `tom_infra`, fulfilled over `diffutil_dart`. It answers positions, never text. The domain holds the rule on top of it: `BlockDifferService` over `BlockAlignerPort`, pairing two blocks that share at least half their words.**

```
BlockDifferService (domain)   the threshold, and what the four verdicts mean
  └── BlockAlignerPort        blocks in, positions out
        └── TextDifferBlockAlignerImpl (data)   blocks ↔ strings
              └── TextDiffer (infra)            strings in, positions out
                    └── diffutil_dart
```

Three things are decided here, and each one was paid for:

**The capability answers positions.** `diffutil_dart` produces an *edit script* — what to insert and remove to turn one list into the other — whose positions are relative to the list as it is being changed, not to either original. The implementation replays that script over the old indices to recover which new entry is which old one. The contract then promises a format the domain can read without knowing any of that: every position of both sides appears in exactly one edit, and a removal is placed where the entry it names used to be.

**Similarity is word overlap, not a second diff.** Sørensen–Dice over the words of the two texts: `2 × shared / (|a| + |b|)`. Myers asks the equality question once per candidate pair — tens of thousands of times on a document-sized list — so running a character-level diff inside it would be a quadratic algorithm nested in a quadratic one. Case and the punctuation around a word are dropped, because neither decides whether two texts are *about* the same thing: with the full stop counted as part of the word, `Prose.` and `Prose, rewritten.` share nothing at all, and the preview drew a rewrite as a deletion beside an addition. A widget test found that one.

**Half the text is the threshold, and it lives in the domain.** Below half, calling a block "modified" asks the reader to diff two unrelated paragraphs in their head; a removal beside an addition is the honest drawing. The number is a product rule, so it sits in `BlockDifferService.pairingThreshold` and travels to the capability as an argument — **what "alike" is measured in belongs to the implementation, what it has to be worth belongs to the caller.**

## Consequences

**A removed block carries its own text.** `DiffBlockRemoved` holds the block from the *old* version, and `DocumentDiffValueObject` carries both parsed versions, so the preview can render something that is in no file on disk — with the link reference definitions it was written against. That is what makes "a struck-through removed paragraph" possible at all.

**Move detection is off.** A block that moved is reported as a removal and an addition, which is what a reader sees at both ends anyway. Pairing the two across a document is a diff v2 question, and so is a word-level diff *inside* a modified block — which starts from here, because `DiffBlockModified` already carries both sides.

**A pairing rule is not a correctness rule.** Whatever the threshold decides, the two texts are both on screen and neither is invented: the worst a bad pairing does is draw one rewrite as two events, or two events as one rewrite. That is why the number can be a constant with a test rather than a setting.

**The capability is generic, and the next caller is already named.** `TextDiffer` knows nothing about blocks, documents or markdown — it lines up sequences of text. The branch and commit diff ([roadmap](../../roadmap.md)) compares the same blocks against a different revision and needs no new algorithm.

---

*Revises nothing. The dependency stack named the two candidates; this chooses one and says what was built on top of it.*
