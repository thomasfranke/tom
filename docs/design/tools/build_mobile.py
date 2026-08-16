"""Builds the mobile wireframes into the matching desktop product's mocks/.

    python3 docs/design/tools/build_mobile.py

**Exploratory, Phase 3, post-1.0.** These exist to picture where the product
is going, not to specify anything. Two questions the roadmap names are still
open and both bite here: git without a system binary, and editing on touch.

Drawn from the *job*, not from the desktop layout. Decision 8 is explicit that
mobile gets its own presentation and that panels do not become screens — so
navigation is a stack, there is no split view, and git appears as one action
on the screen it belongs to rather than as a permanent panel.

The job, per product.md: read, review and approve, and capture a small edit.
Authoring a document on a phone is not a goal.
"""

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from kit import (  # noqa: E402
    Phone, PHONE_W, PHONE_H, NAV_BAR, ACTION_BAR, PAD, SOFT, LABEL,
    CAPTION, BODY, MILESTONE,
)

PRODUCTS = os.path.join(os.path.dirname(os.path.dirname(HERE)), "products")
SUB = "Phase 3, exploratory"


def save(scene, path):
    """Write a screen, creating the destination folder (the job's mocks/) if needed."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    scene.save(path)


def blocks(s, y, heights, x=PAD, w=PHONE_W - 2 * PAD):
    for i, bh in enumerate(heights):
        s.rect(f"bk{i}", x, y, w, bh, stroke=SOFT, dash=True)
        rows = 1 if bh < 46 else 2
        for r in range(rows):
            s.rect(f"bk{i}r{r}", x + 12, y + 14 + r * 20,
                   w - (24 if r < rows - 1 else 80), 8, stroke=SOFT)
        y += bh + 14
    return y


# ── 1. documents ─────────────────────────────────────────────────────────
# No explorer sidebar: on a phone the file tree is the screen you start on,
# and opening a document pushes onto the stack.
s = Phone(21)
s.title("Documents", f"The space, as a list · {SUB}")
s.frame("tom / docs", back=False, action="Search")
s.field("f", PAD, NAV_BAR + 16, PHONE_W - 2 * PAD, "Filter")
y = NAV_BAR + 70
for i, (name, meta) in enumerate([
    ("product.md", "edited 2 days ago"),
    ("roadmap.md", "edited 5 days ago"),
    ("layers.md", "3 unpushed changes"),
    ("README.md", "edited last week"),
    ("architecture/", "8 documents"),
]):
    s.row(f"r{i}", y, name, meta)
    y += 62
s.action_bar("Sync")
save(s, f"{PRODUCTS}/navigation/file-tree/mocks/documents-mobile.excalidraw")

# ── 2. reading ───────────────────────────────────────────────────────────
# The primary job. Full bleed, no chrome competing with the text — the phone
# is where documentation gets read, not written.
s = Phone(22)
s.title("Reading", f"The primary job on a phone · {SUB}")
s.frame("roadmap.md", action="⋯")
blocks(s, NAV_BAR + 20, [34, 76, 58, 76, 44, 62])
s.action_bar("Edit", muted=True)
s.text("open", PAD, PHONE_H - ACTION_BAR - 26,
       "editing on touch is an open question", size=CAPTION, color=SOFT)
save(s, f"{PRODUCTS}/editor/markdown-preview/mocks/reading-mobile.excalidraw")

# ── 3. review ────────────────────────────────────────────────────────────
# The rendered diff, which is the product's differentiator, on the device
# where approving actually happens — roadmap.md: the people who approve
# documentation are rarely at a desk when they do it.
s = Phone(23)
s.title("Review", f"What changed, rendered · {SUB}")
s.frame("roadmap.md · 3 changes", action="⋯")
s.text("since", PAD, NAV_BAR + 16, "against main", size=CAPTION, color=LABEL)
y = blocks(s, NAV_BAR + 44, [34, 72])
# one block marked as changed — the decoration is the whole point
s.rect("chg", PAD - 6, y, 5, 72, stroke=MILESTONE["M2"], bg=MILESTONE["M2"], sw=2)
y = blocks(s, y, [72, 52])
s.text("note", PAD, y + 4, "block granularity: Spike B", size=CAPTION, color=SOFT)
s.action_bar("Approve")
save(s, f"{PRODUCTS}/diff/rendered-diff/mocks/review-mobile.excalidraw")

# ── 4. capture ───────────────────────────────────────────────────────────
# Not an editor. A decision recorded where it was taken, committed in one
# gesture — product.md's "a decision to record" persona. Anything longer
# waits for a desk.
s = Phone(24)
s.title("Capture", f"Record a decision, commit it · {SUB}")
s.frame("roadmap.md", action="Cancel")
s.rect("edit", PAD, NAV_BAR + 16, PHONE_W - 2 * PAD, 210, round=True)
s.bars("el", PAD + 14, NAV_BAR + 40, [220, 260, 190, 240, 160], gap=24)
s.text("cursor", PAD + 14, NAV_BAR + 168, "|", size=BODY)

s.text("cl", PAD, NAV_BAR + 254, "Commit message", size=CAPTION, color=LABEL)
s.rect("msg", PAD, NAV_BAR + 278, PHONE_W - 2 * PAD, 64, round=True)
s.text("msgt", PAD + 14, NAV_BAR + 292, "docs: record the ffi decision",
       size=CAPTION, color=SOFT)

s.text("br", PAD, NAV_BAR + 362, "on feat/rendered-diff", size=CAPTION, color=LABEL)
s.text("gitnote", PAD, PHONE_H - ACTION_BAR - 26,
       "git without a system binary: libgit2 via FFI", size=CAPTION, color=SOFT)
s.action_bar("Commit and push")
save(s, f"{PRODUCTS}/git-workflow/commit/mocks/capture-mobile.excalidraw")
