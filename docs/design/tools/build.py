"""Builds every wireframe into ../screens/.

    python3 docs/design/tools/build.py

One screen per state the app is actually in, in the order the app reaches them.
Tokens and components live in kit.py — nothing here sets a colour or a padding
by hand.
"""

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from kit import (  # noqa: E402
    Scene, CANVAS_W, TOP_BAR, STATUS_BAR, EXPLORER_W, GIT_W,
    PAD, PAD_TIGHT, LIST_ROW, BODY_Y, SOFT, LABEL, MILESTONE, CAPTION, BODY,
)

OUT = os.path.join(os.path.dirname(HERE), "screens", "desktop")
os.makedirs(OUT, exist_ok=True)
H = 560
BODY_H = H - TOP_BAR - STATUS_BAR

TREE = [(0, "docs"), (1, "vision.md"), (1, "mvp.md"), (1, "architecture"), (0, "README.md")]


def tabs(s, x, y, labels, active):
    for i, label in enumerate(labels):
        tx = x + i * 80
        s.text(f"tab{i}", tx, y, label, size=CAPTION,
               color="#1e1e1e" if i == active else LABEL)
        if i == active:
            s.rect(f"tab{i}u", tx - 4, y + 20, 42, 2, sw=2)


# ── 1. no space open ─────────────────────────────────────────────────────
s = Scene(1)
s.title("Empty state", "Before a space is open · M0")
s.window(space=None, height=H)  # no space yet, so the top bar carries no name
s.chip("m0", CANVAS_W - 76, 15, "M0")


# Wording is the README's, verbatim — the empty state is the first thing a new
# user reads, so it must not invent a second way of describing the product.
s.text_centred("brand", 118, "TOM", 40)
s.text_centred("expand", 178, "Team-Oriented Markdown", 16, LABEL)
s.text_centred("tagline", 206, "A Git client built for documentation, not code.", BODY, LABEL)

s.button("open", 380, 268, 280, "Choose folder…", h=44)
s.button("clone", 380, 328, 280, "Clone from URL", h=44, muted=True)
s.chip("m3", 676, 338, "M3")

s.caption("rec", 380, 406, "Recent")
s.bars("rc", 380, 432, [190, 150, 210])
s.status("no space open")
s.save(f"{OUT}/empty-state.excalidraw")

# ── 2. reading and editing ───────────────────────────────────────────────
s = Scene(2)
s.title("Shell — reading and editing", "The working screen · M0")
s.window(height=H)
s.chip("m0", CANVAS_W - 76, 15, "M0")
s.explorer(TREE, selected=2, search_chip="M2", height=H)

CEN = CANVAS_W - EXPLORER_W
s.hline("modebar", EXPLORER_W, BODY_Y + 36, CEN)
tabs(s, EXPLORER_W + 28, BODY_Y + 9, ["Source", "Split", "Preview"], active=1)

PY_, PH = BODY_Y + 36, BODY_H - 36
HALF = CEN // 2
s.vline("splitdiv", EXPLORER_W + HALF, PY_, PH)
s.caption("srch", EXPLORER_W + PAD, PY_ + 14, "source")
s.bars("sl", EXPLORER_W + PAD, PY_ + 46,
       [180, 240, 200, 140, 240, 180, 220, 160, 230, 190])

s.caption("prevh", EXPLORER_W + HALF + PAD, PY_ + 14, "preview")
BX, BW = EXPLORER_W + HALF + PAD, HALF - 2 * PAD
by = PY_ + 42
for i, bh in enumerate([40, 72, 58, 46]):
    s.rect(f"bk{i}", BX, by, BW, bh, stroke=SOFT, dash=True)
    rows = 1 if bh < 50 else 2
    for r in range(rows):
        s.rect(f"bk{i}r{r}", BX + 14, by + 14 + r * 20,
               BW - (28 if r < rows - 1 else 70), 8, stroke=SOFT)
    by += bh + 16
s.caption("bknote", BX, by + 6, "one container per block")

s.status("~/dev/tom/docs", "mvp.md")
s.save(f"{OUT}/shell.excalidraw")

# ── 3. committing ────────────────────────────────────────────────────────
s = Scene(3)
s.title("Committing", "Stage, describe, commit, push · M1")
s.window(height=H)
s.explorer(TREE, selected=2, height=H)

s.rect("branch", 392, 12, 190, 28, round=True)
s.text("brancht", 408, 18, "feat/rendered-diff", size=BODY)
s.text("sync", 606, 18, "↑ 2  ↓ 0", size=BODY, color=LABEL)
s.button("push", 890, 12, 120, "Push", h=28)
s.chip("m1", 712, 15, "M1")

DOCW = CANVAS_W - EXPLORER_W - GIT_W
s.caption("doch", EXPLORER_W + PAD, BODY_Y + 16, "mvp.md")
s.bars("dl", EXPLORER_W + PAD, BODY_Y + 48,
       [280, 340, 300, 220, 340, 280, 320, 240, 300, 200])

GX = EXPLORER_W + DOCW
s.vline("gitdiv", GX, BODY_Y, BODY_H)
s.caption("gith", GX + PAD, BODY_Y + 18, "CHANGES")
y = BODY_Y + 48
for i in range(3):
    s.rect(f"ch{i}", GX + PAD_TIGHT, y, GIT_W - 2 * PAD_TIGHT, 34, stroke=SOFT, round=True)
    s.rect(f"cb{i}", GX + PAD_TIGHT + 18, y + 13, 160, 8, stroke=SOFT)
    y += LIST_ROW

s.rect("msg", GX + PAD_TIGHT, BODY_Y + 232, GIT_W - 2 * PAD_TIGHT, 96, round=True)
s.text("msgt", GX + PAD_TIGHT + 16, BODY_Y + 246, "Summary", size=CAPTION, color=SOFT)
s.button("commit", GX + PAD_TIGHT, BODY_Y + 344, GIT_W - 2 * PAD_TIGHT, "Commit")

s.status("feat/rendered-diff", "3 changes", "in sync")
s.save(f"{OUT}/committing.excalidraw")
