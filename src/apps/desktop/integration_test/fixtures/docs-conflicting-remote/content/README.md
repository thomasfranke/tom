# A project whose remote rewrote the same line

The repository above `docs/`, so the space the app opens is a folder *inside*
a repository — the normal case (rule 12).

What makes this situation is not that the two sides diverged, but that they
diverged **on the same lines of the same file**. A pull here cannot merge
cleanly, and git stops in the middle with both versions written into the
working tree.
