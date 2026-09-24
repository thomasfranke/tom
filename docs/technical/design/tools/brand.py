"""The identity: the icon, the wordmark and the lockup, as data.

    python3 docs/technical/design/tools/brand.py                 # -> ../brand/*.svg + ../brand.svg
    python3 docs/technical/design/tools/brand.py --rasters DIR   # + PNG 16–1024, .icns, .ico

Same contract as palette.py: the repository holds the decision, and a file is
regenerated rather than edited. Every colour is a role from palette.py, and the
one shape both marks share — the commit on the trunk — is defined once, so the
O in the wordmark and the node inside the icon cannot drift apart.

The rasters need `rsvg-convert` (librsvg) and, for the `.icns`, macOS's
`iconutil`; the `.ico` is written here. They are build outputs for the apps,
not documentation, so the default run does not produce them.
"""

import argparse
import os
import shutil
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import palette  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
DESIGN = os.path.dirname(HERE)
BRAND_DIR = os.path.join(DESIGN, "brand")

LIGHT, DARK = palette.LIGHT, palette.DARK

# ── The commit on the trunk ──────────────────────────────────────────────
# A ring on a vertical line: one commit in the history of a document. It is
# the O of the wordmark and the mark inside the icon's page, and the two keep
# the same proportions — the trunk is 0.6 of the ring's stroke in both.
TRUNK_RATIO = 0.6

# ── The wordmark ─────────────────────────────────────────────────────────
# "TOM" set in Sora Bold (Google Fonts, SIL Open Font License 1.1) at a 200px
# master, 6px of tracking. T and M are the glyph outlines, extracted once from
# the TTF with fontTools so nothing here depends on a font being installed.
# The O is not the font's: it is the commit above, drawn at the O's ink box
# with a stroke the width of the letters' stem, and the trunk pokes 24% of the
# cap height past the cap line and the baseline — the one place the wordmark
# leaves the text line, on purpose.
CAP = 146.0                 # cap height at the 200px master
STEM = 32.8                 # the stem width at the master — the ring's stroke
T_PATH = "M45.4 146.0V24.6H78.2V146.0ZM4.4 28.6V0.0H119.4V28.6Z"
M_PATH = ("M320.8 146.0V0.0H366.0L399.4 82.0H403.2L436.2 0.0H482.2V146.0H449.8V21.4"
          "L454.4 21.8L415.8 116.4H384.6L345.8 21.8L350.8 21.4V146.0Z")
O_NODE = dict(cx=212.1, cy=72.7, r=60.7)   # centre of the O's ink box; mid-stroke radius
REACH = round(CAP * 0.24, 2)                # 35.04
INK_LEFT, INK_RIGHT = 4.4, 482.2            # the T's left edge, the M's right edge
WORDMARK_W = round(INK_RIGHT - INK_LEFT, 2)
WORDMARK_H = round(CAP + 2 * REACH, 2)
WORDMARK_VIEWBOX = f"{INK_LEFT} {-REACH} {WORDMARK_W} {WORDMARK_H}"


def wordmark(letter, accent):
    """The wordmark as an SVG string: letters in `letter`, the commit in `accent`."""
    o = O_NODE
    trunk_w = round(STEM * TRUNK_RATIO, 2)
    trunk = (f"M {o['cx']} {-REACH} L {o['cx']} {o['cy'] - o['r']} "
             f"M {o['cx']} {o['cy'] + o['r']} L {o['cx']} {CAP + REACH}")
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{WORDMARK_VIEWBOX}" '
            f'width="{WORDMARK_W}" height="{WORDMARK_H}">'
            f'<path id="T" d="{T_PATH}" fill="{letter}"/>'
            f'<path id="M" d="{M_PATH}" fill="{letter}"/>'
            f'<path id="trunk" d="{trunk}" fill="none" stroke="{accent}" stroke-width="{trunk_w}" '
            f'stroke-linecap="round"/>'
            f'<circle id="O-commit" cx="{o["cx"]}" cy="{o["cy"]}" r="{o["r"]}" fill="none" '
            f'stroke="{accent}" stroke-width="{STEM}"/></svg>')


# ── The icon ─────────────────────────────────────────────────────────────
# A document with the commit on the trunk inside it, on a 512 tile whose corner
# radius is 22% — the macOS icon grid. The page is solid, with its top-right
# corner cut on the diagonal and the fold shown as an L-shaped crease in the
# tile colour; the trunk runs from the page's top edge to its bottom edge and
# the ring sits a little below centre. Everything drawn on the page is cut out
# in the tile colour, so the mark is two colours wherever it goes.
TILE = 512
TILE_RADIUS = 112
PAGE = ("M 154 64 L 304 64 L 388 148 L 388 418 Q 388 448 358 448 L 154 448 "
        "Q 124 448 124 418 L 124 94 Q 124 64 154 64 Z")
CREASE = "M 304 54 L 304 148 L 398 148"
ICON_NODE = dict(cx=256, cy=278, r=52, w=38)
ICON_TRUNK_W = 24          # 38 × 0.6, rounded to the grid

# The two colourways. `cream` is the app icon on a light desktop, `sage` the
# same mark inverted, for dark surfaces and for anywhere the tile itself has to
# carry the colour. Neither has an outline: macOS 26 renders a legacy icon in
# its own dark treatment, which keeps a drawn edge and drops the tile under it,
# so the edge arrives as a bright ring around a plate that is no longer cream.
COLOURWAYS = {
    "cream": dict(tile=LIGHT["surface"], page=LIGHT["accent"]),
    "sage": dict(tile=LIGHT["accent"], page=LIGHT["surface"]),
}


def icon(colourway):
    """The app icon as an SVG string, 512 × 512."""
    c = COLOURWAYS[colourway]
    n = ICON_NODE
    outer = n["r"] + n["w"] / 2
    trunk = (f"M {n['cx']} 64 L {n['cx']} {n['cy'] - outer + 4} "
             f"M {n['cx']} {n['cy'] + outer - 4} L {n['cx']} 448")
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {TILE} {TILE}" '
            f'width="{TILE}" height="{TILE}">'
            f'<rect id="tile" x="0" y="0" width="{TILE}" height="{TILE}" rx="{TILE_RADIUS}" fill="{c["tile"]}"/>'
            f'<path id="page" d="{PAGE}" fill="{c["page"]}"/>'
            f'<path id="crease" d="{CREASE}" fill="none" stroke="{c["tile"]}" stroke-width="20" '
            f'stroke-linecap="butt" stroke-linejoin="miter"/>'
            f'<path id="trunk" d="{trunk}" fill="none" stroke="{c["tile"]}" stroke-width="{ICON_TRUNK_W}" '
            f'stroke-linecap="round"/>'
            f'<circle id="commit" cx="{n["cx"]}" cy="{n["cy"]}" r="{n["r"]}" fill="none" '
            f'stroke="{c["tile"]}" stroke-width="{n["w"]}"/></svg>')


# ── The lockup ───────────────────────────────────────────────────────────
# Icon and wordmark side by side: the icon at 128, a gap of 36, the wordmark
# with its cap height at 80 — so the trunk's reach top and bottom lands close
# to the tile's edges and the two read as one height.
LOCKUP_ICON = 128
LOCKUP_GAP = 36
LOCKUP_CAP = 80


def _inner(svg):
    return svg[svg.index(">") + 1:-len("</svg>")]


def _nested(svg, x, y, w, h):
    vb = svg.split('viewBox="', 1)[1].split('"', 1)[0]
    return f'<svg x="{x}" y="{y}" width="{w}" height="{h}" viewBox="{vb}">{_inner(svg)}</svg>'


def lockup(mode, colourway="cream"):
    letter, accent = (LIGHT["text_primary"], LIGHT["accent"]) if mode == "light" \
        else (DARK["text_primary"], DARK["accent"])
    k = LOCKUP_CAP / CAP
    w, h = round(WORDMARK_W * k, 2), round(WORDMARK_H * k, 2)
    total_w = round(LOCKUP_ICON + LOCKUP_GAP + w, 2)
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {total_w} {LOCKUP_ICON}" '
            f'width="{total_w}" height="{LOCKUP_ICON}">'
            + _nested(icon(colourway), 0, 0, LOCKUP_ICON, LOCKUP_ICON)
            + _nested(wordmark(letter, accent), LOCKUP_ICON + LOCKUP_GAP,
                      round((LOCKUP_ICON - h) / 2, 2), w, h)
            + "</svg>")


# ── The sheet: ../brand.svg, embedded by brand.md ────────────────────────
def sheet():
    cells = []
    # light half
    cells.append(f'<rect x="0" y="0" width="1200" height="300" fill="{LIGHT["surface"]}"/>')
    cells.append(_nested(lockup("light"), 40, 40, 427, 128))
    x = 560
    for px in (256, 64, 32, 16):
        cells.append(_nested(icon("cream"), x, 40 + 256 - px, px, px))
        x += px + 20
    x = 960
    for px in (64, 32, 16):
        cells.append(_nested(icon("sage"), x, 40 + 256 - px, px, px))
        x += px + 20
    cells.append(f'<text x="40" y="240" font-family="IBM Plex Sans, Helvetica, Arial" font-size="13" '
                 f'fill="{LIGHT["text_muted"]}">lockup · icon (cream) 256 / 64 / 32 / 16 · icon (sage) 64 / 32 / 16</text>')
    # dark half
    cells.append(f'<rect x="0" y="300" width="1200" height="300" fill="{DARK["surface"]}"/>')
    cells.append(_nested(lockup("dark"), 40, 340, 427, 128))
    cells.append(_nested(lockup("dark", "sage"), 560, 340, 427, 128))
    cells.append(f'<text x="40" y="540" font-family="IBM Plex Sans, Helvetica, Arial" font-size="13" '
                 f'fill="{DARK["text_muted"]}">dark: the wordmark in the dark roles · the icon in either colourway</text>')
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="600" viewBox="0 0 1200 600">'
            + "".join(cells) + "</svg>")


# ── Files ────────────────────────────────────────────────────────────────
def masters():
    return {
        "tom-icon.svg": icon("cream"),
        "tom-icon-sage.svg": icon("sage"),
        "tom-wordmark-light.svg": wordmark(LIGHT["text_primary"], LIGHT["accent"]),
        "tom-wordmark-dark.svg": wordmark(DARK["text_primary"], DARK["accent"]),
        "tom-lockup-light.svg": lockup("light"),
        "tom-lockup-dark.svg": lockup("dark"),
    }


def write_masters():
    os.makedirs(BRAND_DIR, exist_ok=True)
    for name, svg in masters().items():
        with open(os.path.join(BRAND_DIR, name), "w", encoding="utf-8") as f:
            f.write(svg + "\n")
    with open(os.path.join(DESIGN, "brand.svg"), "w", encoding="utf-8") as f:
        f.write(sheet() + "\n")


def _png(svg_path, out_path, width):
    subprocess.run(["rsvg-convert", "-w", str(width), "-o", out_path, svg_path], check=True)


def _write_ico(path, pngs):
    """An .ico holding PNG-compressed images (Vista and later read those)."""
    header = struct.pack("<HHH", 0, 1, len(pngs))
    offset = 6 + 16 * len(pngs)
    entries, data = b"", b""
    for size, blob in pngs:
        s = 0 if size >= 256 else size
        entries += struct.pack("<BBBBHHII", s, s, 0, 0, 1, 32, len(blob), offset + len(data))
        data += blob
    with open(path, "wb") as f:
        f.write(header + entries + data)


def write_rasters(out):
    if not shutil.which("rsvg-convert"):
        sys.exit("rasters need rsvg-convert (brew install librsvg)")
    os.makedirs(out, exist_ok=True)
    for stem in ("tom-icon", "tom-icon-sage"):
        src = os.path.join(BRAND_DIR, f"{stem}.svg")
        for px in (16, 24, 32, 48, 64, 128, 256, 512, 1024):
            _png(src, os.path.join(out, f"{stem}-{px}.png"), px)
        iconset = os.path.join(out, f"{stem}.iconset")
        os.makedirs(iconset, exist_ok=True)
        for base in (16, 32, 128, 256, 512):
            _png(src, os.path.join(iconset, f"icon_{base}x{base}.png"), base)
            _png(src, os.path.join(iconset, f"icon_{base}x{base}@2x.png"), base * 2)
        if shutil.which("iconutil"):
            subprocess.run(["iconutil", "-c", "icns", iconset, "-o", os.path.join(out, f"{stem}.icns")], check=True)
        pngs = []
        for px in (16, 24, 32, 48, 64, 128, 256):
            with open(os.path.join(out, f"{stem}-{px}.png"), "rb") as f:
                pngs.append((px, f.read()))
        _write_ico(os.path.join(out, f"{stem}.ico"), pngs)
    for mode in ("light", "dark"):
        for kind, w1 in (("wordmark", 263), ("lockup", 427)):
            src = os.path.join(BRAND_DIR, f"tom-{kind}-{mode}.svg")
            _png(src, os.path.join(out, f"tom-{kind}-{mode}@1x.png"), w1)
            _png(src, os.path.join(out, f"tom-{kind}-{mode}@2x.png"), w1 * 2)


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--rasters", metavar="DIR", help="also write PNG sets, .icns and .ico into DIR")
    args = ap.parse_args(argv)
    write_masters()
    print(f"{len(masters())} masters -> {os.path.relpath(BRAND_DIR)}  ·  sheet -> {os.path.relpath(os.path.join(DESIGN, 'brand.svg'))}")
    if args.rasters:
        write_rasters(args.rasters)
        print(f"rasters -> {args.rasters}")


if __name__ == "__main__":
    main(sys.argv[1:])
