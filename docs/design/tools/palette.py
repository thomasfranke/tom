"""The colour system: one set of roles, two modes.

    python3 docs/design/tools/palette.py

Emits ../visual-language/palette.svg (swatches, both modes) and checks every
text pairing against WCAG AA. The values are for the app, and this file is
where they are decided.
"""

import os

# ── Roles, not names ─────────────────────────────────────────────────────
# Nothing here is called "grey200". A role survives a palette change; a
# shade number does not, and renaming it later touches every widget.
LIGHT = {
    "surface":          "#E8E6E1",  # the window behind the islands. a touch warm, on the maintainer's eye
    "surface_raised":   "#F6F5F1",  # the islands: columns, popovers, cards. off-white, never #FFF
    "surface_sunken":   "#ECEAE5",  # inputs, code blocks, the source pane
    "control":          "#E2E0DA",  # the chosen segment, a secondary button
    "border":           "#DAD7D1",
    "border_strong":    "#C4C0B8",
    "text_primary":     "#1F2328",  # near-black, never pure #000
    "text_secondary":   "#4E5561",
    "text_muted":       "#7E7A72",
    "accent":           "#178F71",  # teal. the brand's green, pushed toward the screen
    "accent_soft":      "#D4EDE2",
    "accent_muted":     "#389E84",  # the accent over surface_raised at 85%: a folder's glyph, 3:1
    "added":            "#558F27",
    "added_soft":       "#E5EED5",
    "removed":          "#CF222E",
    "removed_soft":     "#F8E3DE",
    "modified":         "#9A6700",
    "modified_soft":    "#F7EECC",
}

DARK = {
    "surface":          "#131416",  # the window, darker than the islands on it
    "surface_raised":   "#1E1F22",
    "surface_sunken":   "#191A1D",
    "control":          "#2A2C31",
    "border":           "#2B2D31",
    "border_strong":    "#3E4148",
    "text_primary":     "#DFE1E5",  # off-white, never pure #FFF
    "text_secondary":   "#A8ADB6",
    "text_muted":       "#6E737C",
    "accent":           "#4FD1B0",
    "accent_soft":      "#15302A",
    "accent_muted":     "#3E937E",  # the accent over surface_raised at 65%
    "added":            "#9BCB5E",
    "added_soft":       "#1E2A17",
    "removed":          "#EF7B76",
    "removed_soft":     "#301C1C",
    "modified":         "#E2B45C",
    "modified_soft":    "#2C2516",
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
    ("text_primary", "control", 4.5),       # a secondary button's label
    ("text_secondary", "surface", 4.5),
    ("text_muted", "surface", 3.0),        # captions and placeholders only
    ("accent", "surface", 3.0),            # marks and borders, not body text
    ("accent_muted", "surface_raised", 3.0),  # a folder's glyph on the island
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
    swatch_svg(os.path.join(os.path.dirname(here), "visual-language", "palette.svg"))
    print("\nall pairings pass" if ok else "\nCONTRAST FAILURES ABOVE")
