# The wordmark

`TOM`, Sora Bold, 200px master, 6px of tracking.

- **T and M are glyph outlines**, extracted once from the font with fontTools and kept in [`brand.py`](../tools/brand.py) as path data — so rendering needs no font installed anywhere, not in the app and not on the machine that builds the docs.
- The O is not the font's. It is the commit ring ([the-shape.md](the-shape.md)).
- The letters take `text_primary`, the commit takes `accent`. `tom-wordmark-light.svg` and `tom-wordmark-dark.svg` are the same file in the two role tables.
- **It is sized by cap height, never by the file's box**, because the trunk's reach above and below is part of the mark: at cap 60 the wordmark is 89px tall.

Sora is published under the
[SIL Open Font License 1.1](https://openfontlicense.org), which permits the
outlines in a logo without obligation. It is not a dependency of the code and
does not appear in [the dependency stack](../../technical/stack/README.md).

---

*See also: [brand/](README.md) · [the-shape.md](the-shape.md) · [rules.md](rules.md)*
