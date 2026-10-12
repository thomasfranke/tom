"""The board, the app, and their difference, side by side in one PNG.

    python3 docs/design/tools/compare.py <board.svg|png> <app.png> <out.png> [x y w h]

The board is rendered through `render.py` when it is an SVG, both are cropped
to the same rectangle (the whole 1440×900 window by default), and the third
panel marks every pixel that differs in `removed`. **The render is the judge,
not the markup**: reading the SVG alone missed a strike-through, a disc and
a four-point gap in one afternoon.

The app's screenshot must be at the board's own size — `tom e2e <name>
--board` — or the comparison scales one side and every number off it is a lie.
"""

import os
import sys
import tempfile

from pngio import read_png, write_png
from render import render

DIFF = (207, 34, 46, 255)


def compare(board, app, out, crop=None):
    """Write *out*: board | app | diff, cropped to *crop* = (x, y, w, h)."""
    if board.lower().endswith(".svg"):
        rendered = os.path.join(tempfile.gettempdir(), "tom-compare-board.png")
        render(board, rendered)
        board = rendered
    bw, bh, brows = read_png(board)
    aw, ah, arows = read_png(app)
    if (bw, bh) != (aw, ah):
        raise SystemExit(f"sizes differ: board {bw}x{bh}, app {aw}x{ah} — render the app with --board")
    x, y, w, h = crop or (0, 0, bw, bh)
    gap = 8
    rows, differing = [], 0
    for yy in range(y, y + h):
        left = brows[yy][x:x + w]
        middle = arows[yy][x:x + w]
        right = []
        for a, b in zip(left, middle):
            same = a[:3] == b[:3]
            differing += 0 if same else 1
            right.append((236, 234, 229, 255) if same else DIFF)
        spacer = [(19, 20, 22, 255)] * gap
        rows.append(left + spacer + middle + spacer + right)
    write_png(out, w * 3 + gap * 2, h, rows)
    return differing


def main(argv):
    if len(argv) < 3:
        raise SystemExit(__doc__)
    crop = tuple(int(v) for v in argv[3:7]) if len(argv) >= 7 else None
    differing = compare(argv[0], argv[1], argv[2], crop)
    print(f"{argv[2]}: {differing} pixels differ")


if __name__ == "__main__":
    main(sys.argv[1:])
