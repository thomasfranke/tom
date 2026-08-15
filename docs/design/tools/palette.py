"""The colour system: one set of roles, two modes.

    python3 docs/design/tools/palette.py

Emits ../palette.svg (swatches, both modes) and checks every text pairing
against WCAG AA. Wireframes deliberately carry none of this — these values
are for the app, and this file is where they are decided.
"""

import os

# ── Roles, not names ─────────────────────────────────────────────────────
# Nothing here is called "grey200". A role survives a palette change; a
# shade number does not, and renaming it later touches every widget.
LIGHT = {
    "surface":          "#FAF9F6",  # the page. warm, so long reading does not glare
    "surface_raised":   "#FFFFFF",  # panels, popovers, cards
    "surface_sunken":   "#F0EEE9",  # inputs, code blocks, the inactive pane
    "border":           "#E2DFD8",
    "border_strong":    "#C9C5BB",
    "text_primary":     "#26251F",  # warm near-black, never pure #000
    "text_secondary":   "#57544C",
    "text_muted":       "#8B877D",
    "accent":           "#4C7D6E",  # sage. calm, and not the default corporate blue
    "accent_soft":      "#E4EEEA",
    "added":            "#3D7A52",
    "added_soft":       "#E6F0E8",
    "removed":          "#A24F46",
    "removed_soft":     "#F6E8E6",
    "modified":         "#8F6F2E",
    "modified_soft":    "#F4EDDF",
}

DARK = {
    "surface":          "#1A1917",  # warm, matching the light mode's temperature
    "surface_raised":   "#232220",
    "surface_sunken":   "#131211",
    "border":           "#34322D",
    "border_strong":    "#4C4942",
    "text_primary":     "#ECEAE4",  # off-white, never pure #FFF
    "text_secondary":   "#ADA9A0",
    "text_muted":       "#807C74",
    "accent":           "#84B5A5",
    "accent_soft":      "#1E2C28",
    "added":            "#86BC98",
    "added_soft":       "#1B2820",
    "removed":          "#DA9A92",
    "removed_soft":     "#2C1E1C",
    "modified":         "#D2B274",
    "modified_soft":    "#2A2418",
}


def _lin(c):
    c /= 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def luminance(hexstr):
    r, g, b = (int(hexstr[i:i + 2], 16) for i in (1, 3, 5))
    return 0.2126 * _lin(r) + 0.7152 * _lin(g) + 0.0722 * _lin(b)


def contrast(a, b):
    la, lb = luminance(a), luminance(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)


# Every pairing the UI actually produces. AA is 4.5 for body text, 3.0 for
# large text and for non-text marks such as the diff gutter.
PAIRS = [
    ("text_primary", "surface", 4.5),
    ("text_primary", "surface_raised", 4.5),
    ("text_secondary", "surface", 4.5),
    ("text_muted", "surface", 3.0),        # captions and placeholders only
    ("accent", "surface", 3.0),            # marks and borders, not body text
    ("added", "added_soft", 3.0),
    ("removed", "removed_soft", 3.0),
    ("modified", "modified_soft", 3.0),
]


def check():
    rows, ok = [], True
    for mode, pal in (("light", LIGHT), ("dark", DARK)):
        for fg, bg, need in PAIRS:
            r = contrast(pal[fg], pal[bg])
            passed = r >= need
            ok &= passed
            rows.append((mode, fg, bg, r, need, passed))
    return rows, ok


def swatch_svg(path):
    SW, SH, GAP, ROWGAP, COL = 148, 76, 12, 36, 4
    keys = list(LIGHT)
    rows = (len(keys) + COL - 1) // COL
    bw = COL * SW + (COL - 1) * GAP
    bh = rows * SH + (rows - 1) * ROWGAP
    W = bw + 80
    BLOCK = bh + 104          # 70 above the grid, ~34 below for the last labels
    H = 2 * BLOCK
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" '
           f'viewBox="0 0 {W} {H}" font-family="ui-sans-serif, system-ui, sans-serif">']
    y0 = 0
    for mode, pal in (("Light", LIGHT), ("Dark", DARK)):
        page = pal["surface"]
        ink = pal["text_primary"]
        sub = pal["text_muted"]
        out.append(f'<rect x="0" y="{y0}" width="{W}" height="{BLOCK}" fill="{page}"/>')
        out.append(f'<text x="40" y="{y0 + 46}" font-size="21" font-weight="600" fill="{ink}">{mode}</text>')
        for i, k in enumerate(keys):
            cx = 40 + (i % COL) * (SW + GAP)
            cy = y0 + 70 + (i // COL) * (SH + ROWGAP)
            out.append(f'<rect x="{cx}" y="{cy}" width="{SW}" height="{SH}" rx="8" '
                       f'fill="{pal[k]}" stroke="{pal["border_strong"]}"/>')
            out.append(f'<text x="{cx + 10}" y="{cy + SH + 16}" font-size="11" fill="{sub}">'
                       f'{k}  {pal[k]}</text>')
        y0 += BLOCK
    out.append('</svg>')
    open(path, "w", encoding="utf-8").write('\n'.join(out))


if __name__ == "__main__":
    rows, ok = check()
    width = max(len(f"{f}/{b}") for _, f, b, *_ in rows)
    for mode, fg, bg, r, need, passed in rows:
        print(f"{mode:5}  {fg + '/' + bg:{width}}  {r:5.2f}  need {need}  "
              f"{'ok' if passed else 'FAIL'}")
    here = os.path.dirname(os.path.abspath(__file__))
    swatch_svg(os.path.join(os.path.dirname(here), "palette.svg"))
    print("\nall pairings pass" if ok else "\nCONTRAST FAILURES ABOVE")
