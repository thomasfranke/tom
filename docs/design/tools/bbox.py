"""Where the ink actually is inside a rectangle of a PNG.

    python3 docs/design/tools/bbox.py <image.png> <x> <y> <w> <h> [#background]

Prints the bounding box of every pixel that is not the background — the
rectangle's top-left pixel unless one is given — as `x y w h`, plus the
colours met. A glyph, a dot or a text run is measured by its ink and not by
the box it was drawn in, which is how the boards align a chevron.
"""

import sys

from pngio import hexof, read_png


def bbox(image, x, y, w, h, background=None):
    """Return ((left, top, width, height), colours) of the non-background ink."""
    _, _, rows = read_png(image)
    background = background or hexof(rows[y][x])
    left = top = None
    right = bottom = -1
    colours = {}
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            colour = hexof(rows[yy][xx])
            if colour == background:
                continue
            colours[colour] = colours.get(colour, 0) + 1
            left = xx if left is None else min(left, xx)
            top = yy if top is None else min(top, yy)
            right, bottom = max(right, xx), max(bottom, yy)
    if left is None:
        return None, colours
    return (left, top, right - left + 1, bottom - top + 1), colours


def main(argv):
    if len(argv) < 5:
        raise SystemExit(__doc__)
    image = argv[0]
    x, y, w, h = (int(v) for v in argv[1:5])
    background = argv[5] if len(argv) > 5 else None
    box, colours = bbox(image, x, y, w, h, background)
    print("no ink" if box is None else "%d %d %d %d" % box)
    for colour, count in sorted(colours.items(), key=lambda kv: -kv[1])[:8]:
        print(f"  {colour} ({count})")


if __name__ == "__main__":
    main(sys.argv[1:])
