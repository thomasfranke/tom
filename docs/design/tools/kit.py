"""Shared drawing kit for TOM's wireframes.

Every screen in this folder is generated through this module so that spacing,
type scale and colour are identical across all of them. Change a token here and
rebuild — never hand-tune one screen, because that is how a set of wireframes
stops looking like one product.

    python3 docs/design/_build.py

The output is `.excalidraw` files, which open and stay editable in Excalidraw.
Conventions and the review workflow: docs/design/README.md
"""

import json
import random

# ── Colour ───────────────────────────────────────────────────────────────
# Four values, and no more. A wireframe that needs a fifth is describing
# visual design rather than structure, which is not what this folder is for.
INK = "#1e1e1e"    # structure: window, panels, controls, real labels
SOFT = "#adb5bd"   # placeholder content: text bars, block outlines, hints
LABEL = "#868e96"  # panel captions and secondary text
WHITE = "#ffffff"

# Milestone accents. Used only for the chip that dates an element, never as
# decoration — a coloured mark in a TOM wireframe always means "arrives later".
MILESTONE = {
    "M0": "#1971c2",
    "M1": "#2f9e44",
    "M2": "#f08c00",
    "M3": "#9c36b5",
}

# ── Type scale ───────────────────────────────────────────────────────────
# Excalidraw font family 1 is the hand-drawn face. It is deliberate: a
# wireframe that looks hand-drawn invites structural comment, while one that
# looks finished invites comment on colour and corner radius.
FONT = 1
TITLE = 24     # screen name, above the frame
SUBTITLE = 14  # one line under it: what this state is, and its milestone
HEADING = 17   # in-app titles (space name)
BODY = 14      # tree items, buttons, controls
CAPTION = 13   # tab labels, placeholders, chips
LABEL_SIZE = 12  # panel captions (EXPLORER, CHANGES), status bar

# ── Layout ───────────────────────────────────────────────────────────────
# Scoped to desktop. Mobile is a committed direction for Phase 3, post-1.0
# ([Decision 8](../../decisions/008-monorepo-with-pure-dart-core.md)), and it
# gets its own values here rather than a narrower version of these — that
# decision is explicit that panels do not become screens. Nothing is drawn for
# it until the roadmap's two open questions close: git without a system binary,
# and editing on touch.
CANVAS_W = 1040    # every screen is this wide; they stack vertically in review
CANVAS_H = 560
TOP_BAR = 52
STATUS_BAR = 32
EXPLORER_W = 220   # constant across screens — the explorer never moves
GIT_W = 280

PAD = 20           # panel edge to content
PAD_TIGHT = 16     # panel edge to a full-width control
ROW = 34           # tree row pitch
LIST_ROW = 42      # file-list row pitch
BAR_H = 8          # placeholder text bar
BAR_GAP = 26       # placeholder line pitch

BODY_Y = TOP_BAR
BODY_H = CANVAS_H - TOP_BAR - STATUS_BAR


class Scene:
    """One screen. Coordinates are absolute; the window sits at (0, 0)."""

    def __init__(self, seed):
        self.els = []
        self._rnd = random.Random(seed)  # fixed, so rebuilds produce no diff noise

    # ── primitives ───────────────────────────────────────────────────────
    def _base(self, **kw):
        e = dict(
            angle=0, strokeColor=INK, backgroundColor="transparent",
            fillStyle="solid", strokeWidth=1, strokeStyle="solid", roughness=1,
            opacity=100, groupIds=[], frameId=None, roundness=None,
            seed=self._rnd.randint(1, 2**31), version=1,
            versionNonce=self._rnd.randint(1, 2**31), isDeleted=False,
            boundElements=[], updated=1755000000000, link=None, locked=False,
        )
        e.update(kw)
        return e

    def rect(self, id, x, y, w, h, stroke=INK, bg="transparent", sw=1,
             dash=False, round=False):
        self.els.append(self._base(
            id=id, type="rectangle", x=x, y=y, width=w, height=h,
            strokeColor=stroke, backgroundColor=bg, strokeWidth=sw,
            strokeStyle="dashed" if dash else "solid",
            roundness={"type": 3} if round else None,
        ))

    def text(self, id, x, y, s, size=BODY, color=INK):
        self.els.append(self._base(
            id=id, type="text", x=x, y=y,
            width=max(8, len(s) * size * 0.58), height=size * 1.25,
            strokeColor=color, roundness=None, text=s, fontSize=size,
            fontFamily=FONT, textAlign="left", verticalAlign="top",
            containerId=None, originalText=s, autoResize=True, lineHeight=1.25,
        ))

    def text_centred(self, id, y, s, size=BODY, color=INK, x=0, width=CANVAS_W):
        """Centred inside a fixed-width box, so Excalidraw does the centring.

        Estimating glyph widths to place x by hand is never exact — the text
        drifts a few pixels off centre and it shows. `autoResize` stays False
        so the declared width survives loading.
        """
        self.els.append(self._base(
            id=id, type="text", x=x, y=y, width=width, height=size * 1.25,
            strokeColor=color, roundness=None, text=s, fontSize=size,
            fontFamily=FONT, textAlign="center", verticalAlign="top",
            containerId=None, originalText=s, autoResize=False, lineHeight=1.25,
        ))

    # ── components ───────────────────────────────────────────────────────
    def _line(self, id, x, y, dx, dy, color, sw):
        self.els.append(self._base(
            id=id, type="line", x=x, y=y, width=abs(dx), height=abs(dy),
            strokeColor=color, strokeWidth=sw, points=[[0, 0], [dx, dy]],
            lastCommittedPoint=None, startBinding=None, endBinding=None,
            startArrow=None, endArrow=None,
        ))

    def hline(self, id, x, y, width, color=INK, sw=1):
        self._line(id, x, y, width, 0, color, sw)

    def vline(self, id, x, y, height, color=INK, sw=1):
        self._line(id, x, y, 0, height, color, sw)

    def chip(self, id, x, y, milestone):
        """Dates an element: this part arrives in that milestone."""
        c = MILESTONE[milestone]
        self.rect(id + "-b", x, y, len(milestone) * 9 + 14, 22, stroke=c, round=True)
        self.text(id + "-t", x + 7, y + 3, milestone, size=CAPTION, color=c)

    def button(self, id, x, y, w, label, h=38, muted=False):
        c = SOFT if muted else INK
        self.rect(id + "-b", x, y, w, h, stroke=c, dash=muted, round=True)
        self.text(id + "-t", x + (w - len(label) * BODY * 0.58) / 2,
                  y + (h - BODY * 1.25) / 2, label, size=BODY, color=c)

    def field(self, id, x, y, w, placeholder, h=28):
        self.rect(id + "-b", x, y, w, h, stroke=SOFT, dash=True, round=True)
        self.text(id + "-t", x + 12, y + (h - CAPTION * 1.25) / 2,
                  placeholder, size=CAPTION, color=SOFT)

    def bars(self, id, x, y, widths, gap=BAR_GAP):
        """Placeholder text. Never real prose — a wireframe is not a mockup."""
        for i, w in enumerate(widths):
            self.rect(f"{id}{i}", x, y + i * gap, w, BAR_H, stroke=SOFT)

    def caption(self, id, x, y, s):
        self.text(id, x, y, s, size=LABEL_SIZE, color=LABEL)

    # ── frame ────────────────────────────────────────────────────────────
    def title(self, name, subtitle):
        self.text("_h", 0, -64, name, size=TITLE)
        self.text("_s", 0, -30, subtitle, size=SUBTITLE, color=LABEL)

    def window(self, space="tom / docs", height=CANVAS_H):
        """The frame, drawn exactly once.

        Bars and panels are dividing *lines*, never rectangles: a rectangle
        laid over the frame repeats the border it already has, and the repeat
        is visible because the outer frame is rounded and the inner one is not.
        """
        self.h = height
        self.rect("_win", 0, 0, CANVAS_W, height, sw=2, round=True)
        self.hline("_toprule", 0, TOP_BAR, CANVAS_W)
        self.hline("_statusrule", 0, height - STATUS_BAR, CANVAS_W)
        if space:
            self.text("_space", PAD + 4, 16, space, size=HEADING)

    def status(self, *items):
        x = PAD + 4
        for i, s in enumerate(items):
            self.caption(f"_st{i}", x, self.h - STATUS_BAR + 8, s)
            x += max(len(s) * 8, 90) + 40

    def explorer(self, tree, selected=None, search_chip=None, height=None):
        """The left panel. Present on every screen where a space is open."""
        h = (height or self.h) - TOP_BAR - STATUS_BAR
        self.vline("_expdiv", EXPLORER_W, BODY_Y, h)
        self.caption("_exph", PAD, BODY_Y + 18, "EXPLORER")
        self.field("_search", PAD_TIGHT, BODY_Y + 48, 148, "Search")
        if search_chip:
            self.chip("_searchm", PAD_TIGHT + 160, BODY_Y + 51, search_chip)
        y = BODY_Y + 108
        for i, (level, label) in enumerate(tree):
            if i == selected:
                self.rect("_hl", 12, y - 5, EXPLORER_W - 24, 26,
                          stroke=MILESTONE["M0"], round=True)
            self.text(f"_tr{i}", PAD + level * 18, y, label, size=BODY)
            y += ROW

    def save(self, path):
        json.dump({
            "type": "excalidraw", "version": 2, "source": "https://excalidraw.com",
            "elements": self.els,
            "appState": {"gridSize": None, "viewBackgroundColor": WHITE},
            "files": {},
        }, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
        print(f"{len(self.els):3d} elements  ->  {path}")
