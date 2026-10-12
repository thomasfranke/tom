"""The colour runs along one row or column of a PNG.

    python3 docs/design/tools/pixels.py <image.png> row <y> [x0 x1]
    python3 docs/design/tools/pixels.py <image.png> col <x> [y0 y1]

Prints every run of one colour as `x0..x1 #RRGGBB (n)`, which is how a
control's width, a hairline's position or a tile's inset is read off a render
without trusting the eye. **Read a shape at its mid-height, never at its top
row**: a rounded corner makes a control read narrower than it is.
"""

import sys

from pngio import hexof, read_png


def runs(image, axis, index, start=None, stop=None):
    """Yield (first, last, colour) runs along *axis* ('row' or 'col') at *index*."""
    width, height, rows = read_png(image)
    if axis == "row":
        line = rows[index]
    else:
        line = [rows[y][index] for y in range(height)]
    start = 0 if start is None else start
    stop = len(line) if stop is None else stop
    first, colour = start, hexof(line[start])
    for i in range(start + 1, stop + 1):
        here = hexof(line[i]) if i < stop else None
        if here != colour:
            yield first, i - 1, colour
            first, colour = i, here


def main(argv):
    if len(argv) < 3:
        raise SystemExit(__doc__)
    image, axis, index = argv[0], argv[1], int(argv[2])
    start = int(argv[3]) if len(argv) > 3 else None
    stop = int(argv[4]) if len(argv) > 4 else None
    for first, last, colour in runs(image, axis, index, start, stop):
        print(f"{first}..{last} {colour} ({last - first + 1})")


if __name__ == "__main__":
    main(sys.argv[1:])
