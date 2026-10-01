# ADR 001 — Why markdown

**Status:** accepted

## Decision

Documentation is markdown in the repository it describes.

## Rationale

It diffs, it reviews, and it survives whatever tool is fashionable.[^tools]

Plain text is also what every other tool in the chain already reads.[^chain]

[^tools]: Three editors were tried before this one, and none of them could be
    diffed by a reviewer who did not have it installed.

[^chain]: `grep`, `git` and the next thing nobody has written yet.
