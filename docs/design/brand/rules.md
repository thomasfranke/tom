# Rules

1. **The commit is never redrawn.** The O of the wordmark and the node in the icon come from the same numbers in [`brand.py`](../tools/brand.py); a wordmark set in Sora with the font's own O is not the wordmark.
2. **Cap height sets the size.** Scale the wordmark so its capitals are the height wanted and let the trunk reach where it reaches — cropping the trunk to the cap line removes the mark.
3. **Roles, not colours.** Letters are `text_primary`, the commit is `accent`, tiles are `surface` or `accent`. Any other colour is a new decision, made in [visual-language](../visual-language/README.md) first.
4. **Two colours per mark, no more.** No gradient, shadow, outline or third tone — and no edge around the tile. Where the cream tile needs separating from a white surface, use the sage colourway.
5. **Minimum sizes.** The icon holds down to 16px; the wordmark down to cap 20, about 30px tall. Below that, use the icon.
6. **Clear space** is half the icon's width around the icon, and the trunk's reach around the wordmark — the same distance the mark already keeps from its own box.

**Rule 4 cost a release.** The cream tile carried a hairline until macOS 26,
whose dark icon treatment keeps a drawn edge while replacing the tile under it,
turning it into a bright ring around a plate that is no longer cream.

---

*See also: [brand/](README.md) · [icon.md](icon.md) · [wordmark.md](wordmark.md)*
