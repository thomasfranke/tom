"""Builds every desktop wireframe into the product it belongs to (../../products/<feature>/mocks/).

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

DESIGN = os.path.dirname(HERE)
PRODUCTS = os.path.join(os.path.dirname(DESIGN), "products")  # every screen lives next to the product's doc.md
H = 560


def save(scene, path):
    """Write a screen, creating the destination folder (e.g. a product's mocks/) if needed."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    scene.save(path)


BODY_H = H - TOP_BAR - STATUS_BAR

TREE = [(0, "docs"), (1, "product.md"), (1, "roadmap.md"), (1, "architecture"), (0, "README.md")]


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
save(s, f"{PRODUCTS}/home/mocks/empty-state.excalidraw")

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

s.status("~/dev/tom/docs", "roadmap.md")
save(s, f"{PRODUCTS}/workspace/mocks/shell.excalidraw")

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
s.caption("doch", EXPLORER_W + PAD, BODY_Y + 16, "roadmap.md")
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
save(s, f"{PRODUCTS}/git-workflow/commit/mocks/committing-desktop.excalidraw")

# ── 4. reading ───────────────────────────────────────────────────────────
# product.md: "Reading is not a lesser mode" — for anyone who does not write
# markdown by hand, the rendered view is the product and the editor is the
# part they never open. So it gets its own screen, not a variant of the split.
s = Scene(4)
s.title("Reading", "Preview only — the default for whoever does not edit · M0")
s.window(height=H)
s.chip("m0", CANVAS_W - 76, 15, "M0")
s.explorer(TREE, selected=2, search_chip="M2", height=H)

CEN = CANVAS_W - EXPLORER_W
s.hline("modebar", EXPLORER_W, BODY_Y + 36, CEN)
tabs(s, EXPLORER_W + 28, BODY_Y + 9, ["Source", "Split", "Preview"], active=2)

RX = EXPLORER_W + 120           # generous margins: this is a reading column
RW = CEN - 240
by = BODY_Y + 76
for i, bh in enumerate([40, 84, 62, 84, 48]):
    s.rect(f"bk{i}", RX, by, RW, bh, stroke=SOFT, dash=True)
    rows = 1 if bh < 50 else 2
    for r in range(rows):
        s.rect(f"bk{i}r{r}", RX + 16, by + 16 + r * 22,
               RW - (32 if r < rows - 1 else 90), 8, stroke=SOFT)
    by += bh + 18

s.status("~/dev/tom/docs", "roadmap.md", "read-only")
save(s, f"{PRODUCTS}/editor/markdown-preview/mocks/reading-desktop.excalidraw")

# ── 5. folder is not in a Git repository ─────────────────────────────────
# A space is a folder *inside* a repository, so this is the one way opening
# can fail. Drawn because the wording is the design: the message has to say
# what is wrong without implying TOM will create a repository — that is not
# in the MVP.
s = Scene(5)
s.title("Not a Git repository", "The one way opening a folder fails · M0")
s.window(space=None, height=H)
s.chip("m0", CANVAS_W - 76, 15, "M0")

s.text_centred("head", 176, "That folder is not inside a Git repository", 22)
s.text_centred("l1", 224, "~/Documents/notes", BODY, LABEL)
s.text_centred("l2", 262, "TOM works on documentation that is already versioned. Open a folder", BODY, LABEL)
s.text_centred("l3", 288, "inside a repository — the repository root, or any folder within it.", BODY, LABEL)

s.button("again", 380, 340, 280, "Choose another folder…", h=44)
s.text_centred("hint", 400, "Creating a repository is not something TOM does.", CAPTION, SOFT)
s.status("no space open")
save(s, f"{PRODUCTS}/home/mocks/not-a-repository.excalidraw")

# ── 6. unsaved changes ───────────────────────────────────────────────────
# "Files are the truth" only holds once the buffer reaches disk, so the gap
# between the two has to be visible. The question this screen settles is
# where that mark lives.
s = Scene(6)
s.title("Unsaved changes", "The gap between the buffer and the file · M0")
s.window(height=H)
s.chip("m0", CANVAS_W - 76, 15, "M0")
s.explorer(TREE, selected=2, search_chip="M2", height=H)
s.dot("dirty-tree", EXPLORER_W - 34, BODY_Y + 113)      # against the file that is dirty

CEN = CANVAS_W - EXPLORER_W
s.hline("modebar", EXPLORER_W, BODY_Y + 36, CEN)
tabs(s, EXPLORER_W + 28, BODY_Y + 9, ["Source", "Split", "Preview"], active=1)
s.dot("dirty-tab", CANVAS_W - 132, BODY_Y + 13)
s.text("dirtytab", CANVAS_W - 116, BODY_Y + 8, "Unsaved", size=CAPTION)

PY_, PH = BODY_Y + 36, BODY_H - 36
HALF = CEN // 2
s.vline("splitdiv", EXPLORER_W + HALF, PY_, PH)
s.caption("srch", EXPLORER_W + PAD, PY_ + 14, "source")
s.bars("sl", EXPLORER_W + PAD, PY_ + 46, [180, 240, 200, 140, 240, 180, 220])
s.caption("prevh", EXPLORER_W + HALF + PAD, PY_ + 14, "preview")
BX, BW = EXPLORER_W + HALF + PAD, HALF - 2 * PAD
by = PY_ + 42
for i, bh in enumerate([40, 72, 58]):
    s.rect(f"bk{i}", BX, by, BW, bh, stroke=SOFT, dash=True)
    s.rect(f"bk{i}r", BX + 14, by + 14, BW - 70, 8, stroke=SOFT)
    by += bh + 16

s.status("~/dev/tom/docs", "roadmap.md — unsaved", "⌘S to save")
save(s, f"{PRODUCTS}/editor/source-mode/mocks/unsaved-changes.excalidraw")

# ── 7. branch switcher ───────────────────────────────────────────────────
# The first non-modal surface in the app. Decision 6 keeps `Navigator` for
# dialogs only, so this is a popover anchored to its trigger — and it sets
# the pattern every later one follows.
s = Scene(7)
s.title("Branch switcher", "Switch branches, or start one · M1")
s.window(height=H)
s.explorer(TREE, selected=2, height=H)

s.rect("branch", 392, 12, 190, 28, sw=2, round=True)
s.text("brancht", 408, 18, "feat/rendered-diff", size=BODY)
s.chip("m1", 608, 15, "M1")

DOCW = CANVAS_W - EXPLORER_W - GIT_W
s.caption("doch", EXPLORER_W + PAD, BODY_Y + 16, "roadmap.md")
s.bars("dl", EXPLORER_W + PAD, BODY_Y + 48, [280, 340, 300, 220, 340, 280])

POPX, POPW = 392, 260
s.popover("pop", POPX, BODY_Y + 4, POPW, 254)
s.field("popf", POPX + PAD_TIGHT, BODY_Y + 20, POPW - 2 * PAD_TIGHT, "Filter branches")
y = BODY_Y + 68
branches = [("feat/rendered-diff", True), ("main", False), ("feat/space-session", False), ("fix/watcher-echo", False)]
for i, (name, current) in enumerate(branches):
    if current:
        s.rect(f"pr{i}", POPX + 8, y - 5, POPW - 16, 26, stroke=MILESTONE["M0"], round=True)
    s.text(f"pb{i}", POPX + PAD_TIGHT + 8, y, name, size=BODY)
    y += 32
s.hline("popsep", POPX, y + 4, POPW, color=SOFT)
s.text("popnew", POPX + PAD_TIGHT + 8, y + 18, "Create branch…", size=BODY)

s.status("feat/rendered-diff", "3 changes")
save(s, f"{PRODUCTS}/git-workflow/branch-switch/mocks/branch-switcher.excalidraw")

# ── 8. file history ──────────────────────────────────────────────────────
# "The commits that touched this file" — scoped to the open document rather
# than the repository, which is what makes it useful for documentation and
# is also what the M1 line actually says.
s = Scene(8)
s.title("File history", "The commits that touched this document · M1")
s.window(height=H)
s.explorer(TREE, selected=2, height=H)
s.chip("m1", CANVAS_W - 76, 15, "M1")

DOCW = CANVAS_W - EXPLORER_W - GIT_W
s.caption("doch", EXPLORER_W + PAD, BODY_Y + 16, "roadmap.md")
s.bars("dl", EXPLORER_W + PAD, BODY_Y + 48,
       [280, 340, 300, 220, 340, 280, 320, 240])

GX = EXPLORER_W + DOCW
s.vline("histdiv", GX, BODY_Y, BODY_H)
s.caption("histh", GX + PAD, BODY_Y + 18, "HISTORY")
y = BODY_Y + 50
for i in range(5):
    s.rect(f"hb{i}", GX + PAD_TIGHT + 4, y, 190, 8, stroke=SOFT)   # subject
    s.text(f"hm{i}", GX + PAD_TIGHT + 4, y + 16, "abc1234 · 3 days ago",
           size=CAPTION, color=LABEL)
    y += 56
s.caption("histnote", GX + PAD, y + 4, "scoped to this file, not the repo")

s.status("feat/rendered-diff", "roadmap.md")
save(s, f"{PRODUCTS}/git-workflow/file-history/mocks/file-history.excalidraw")

# ── 9. push rejected ─────────────────────────────────────────────────────
# The interesting half of push/pull. Named as a state because the wording
# decides whether a non-developer understands what to do next — the whole
# point of not hiding Git behind a Sync button (product.md).
s = Scene(9)
s.title("Push rejected", "The remote moved first · M1")
s.window(height=H)
s.explorer(TREE, selected=2, height=H)

s.rect("branch", 392, 12, 190, 28, round=True)
s.text("brancht", 408, 18, "feat/rendered-diff", size=BODY)
s.text("sync", 606, 18, "↑ 2  ↓ 3", size=BODY, color=MILESTONE["M2"])
s.button("push", 890, 12, 120, "Push", h=28, muted=True)
s.chip("m1", 712, 15, "M1")

DOCW = CANVAS_W - EXPLORER_W - GIT_W
s.caption("doch", EXPLORER_W + PAD, BODY_Y + 16, "roadmap.md")
s.bars("dl", EXPLORER_W + PAD, BODY_Y + 48, [280, 340, 300, 220, 340, 280])

GX = EXPLORER_W + DOCW
s.vline("gitdiv", GX, BODY_Y, BODY_H)
s.banner("rej", GX + PAD_TIGHT, BODY_Y + 16, GIT_W - 2 * PAD_TIGHT,
         "Someone pushed 3 commits first.", MILESTONE["M2"], h=40)
s.text("rej2", GX + PAD_TIGHT + 14, BODY_Y + 62,
       "Pull them, then push again. Nothing", size=CAPTION, color=LABEL)
s.text("rej3", GX + PAD_TIGHT + 14, BODY_Y + 80,
       "you committed has been lost.", size=CAPTION, color=LABEL)
s.button("pull", GX + PAD_TIGHT, BODY_Y + 108, GIT_W - 2 * PAD_TIGHT, "Pull")

s.caption("gith", GX + PAD, BODY_Y + 178, "YOUR COMMITS")
y = BODY_Y + 206
for i in range(2):
    s.rect(f"cm{i}", GX + PAD_TIGHT + 4, y, 190, 8, stroke=SOFT)
    s.text(f"cmm{i}", GX + PAD_TIGHT + 4, y + 16, "abc1234 · you",
           size=CAPTION, color=LABEL)
    y += 52

s.status("feat/rendered-diff", "2 ahead, 3 behind")
save(s, f"{PRODUCTS}/git-workflow/push-pull/mocks/push-rejected.excalidraw")
