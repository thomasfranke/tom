// The shared kit for TOM's high-fidelity screens in Penpot.
//
// Same contract as kit.py has for the wireframes: every screen is composed
// from these components, so spacing, type and colour are identical across all
// of them. Nothing below writes a literal colour or dimension — they arrive in
// TOKENS, emitted by penpot_build.py from palette.py and kit.py.
//
// Two Penpot behaviours this file exists to encapsulate, because both are easy
// to get wrong and invisible until a board renders empty:
//
//   1. `board.appendChild(shape)` preserves the shape's ABSOLUTE position. A
//      board at x=3080 with a child placed at x=500 puts that child outside
//      the board, where clipping hides it. So a Scene is always built at the
//      origin and `place()` moves the finished board — moving a board does
//      carry its children.
//   2. Text auto-sizing is asynchronous. Reading `.height` right after setting
//      the characters returns the pre-layout value, so anything that stacks
//      paragraphs has to wait for the layout — `renderedDoc` does it once.
//
// The plugin runs inside the Penpot browser tab, so it is subject to that
// tab's timer throttling: a `setTimeout` that returns in 40ms with the tab in
// front can take a second with it in the background. Everything here is built
// to wait as FEW times as possible rather than as briefly as possible, and
// `main()` builds one screen per call so a throttled run degrades into more
// calls instead of a half-drawn board.

const P = TOKENS.light;          // screens are composed in light, then darkified
const L = TOKENS.layout;
const TY = TOKENS.type;

const FONTS = {
  sans: penpot.fonts.findByName(TY.family.sans),
  mono: penpot.fonts.findByName(TY.family.mono),
  serif: penpot.fonts.findByName(TY.family.serif),
};

function applyFont(txt, kind, weight) {
  const f = FONTS[kind];
  const v = f.variants.find(
    (v) => v.fontWeight === String(weight) && (v.fontStyle || "normal") === "normal",
  ) || f.variants[0];
  f.applyToText(txt, v);
}

const settle = (ms = 260) => new Promise((r) => setTimeout(r, ms));


class Scene {
  // One screen. Built at the origin; `place()` moves it into the review grid.
  constructor(name) {
    const b = penpot.createBoard();
    b.name = name;
    b.x = 0;
    b.y = 0;
    b.resize(L.windowW, L.windowH);
    b.fills = [{ fillColor: P.surface, fillOpacity: 1 }];
    b.borderRadius = 12;
    b.strokes = [{ strokeColor: P.border, strokeWidth: 1, strokeAlignment: "inner" }];
    try { b.clipContent = true; } catch (e) { /* older plugin runtimes */ }
    this.board = b;
  }

  // ── primitives ─────────────────────────────────────────────────────────
  rect(name, x, y, w, h, o = {}) {
    const s = penpot.createRectangle();
    this.board.appendChild(s);
    s.name = name;
    s.x = x; s.y = y;
    s.resize(w, h);
    s.fills = o.fill ? [{ fillColor: o.fill, fillOpacity: o.opacity ?? 1 }] : [];
    s.strokes = o.stroke
      ? [{ strokeColor: o.stroke, strokeWidth: o.sw ?? 1, strokeAlignment: "inner" }]
      : [];
    if (o.r) s.borderRadius = o.r;
    return s;
  }

  text(name, x, y, str, o = {}) {
    const s = penpot.createText(str);
    this.board.appendChild(s);
    s.name = name;
    applyFont(s, o.font || "sans", o.weight || 400);
    s.fontSize = String(o.size || TY.ui);
    s.lineHeight = String(o.lh || 1.4);
    if (o.ls) s.letterSpacing = String(o.ls);
    s.fills = [{ fillColor: o.color || P.text_primary, fillOpacity: 1 }];
    s.growType = "auto-width";
    s.x = x; s.y = y;
    return s;
  }

  // Centred by Penpot inside a fixed box — never by estimating glyph widths,
  // which is always a few pixels out and shows.
  textCentred(name, x, y, w, str, o = {}) {
    const s = penpot.createText(str);
    this.board.appendChild(s);
    s.name = name;
    applyFont(s, o.font || "sans", o.weight || 400);
    s.fontSize = String(o.size || TY.caption);
    s.lineHeight = String(o.lh || 1.4);
    s.fills = [{ fillColor: o.color || P.text_primary, fillOpacity: 1 }];
    s.growType = "fixed";
    s.resize(w, o.h || Math.round((o.size || TY.caption) * (o.lh || 1.4)));
    s.align = o.align || "center";
    s.x = x; s.y = y;
    return s;
  }

  // A wrapping paragraph. Height is only correct after `settle()`.
  para(name, x, y, w, str, o = {}) {
    const s = penpot.createText(str);
    this.board.appendChild(s);
    s.name = name;
    applyFont(s, o.font || "serif", o.weight || 400);
    s.fontSize = String(o.size || TY.bodySplit);
    s.lineHeight = String(o.lh || 1.7);
    s.fills = [{ fillColor: o.color || P.text_primary, fillOpacity: 1 }];
    s.growType = "fixed";
    s.resize(w, o.h || 120);
    s.align = o.align || "left";
    s.x = x; s.y = y;
    s.growType = "auto-height";
    return s;
  }

  // Style one span inside a paragraph — a link, an inline code run, a lead-in.
  range(shape, sub, o = {}) {
    const i = shape.characters.indexOf(sub);
    if (i < 0) return null;
    const rg = shape.getRange(i, i + sub.length);
    if (o.font) {
      const f = FONTS[o.font];
      f.applyToRange(rg, f.variants.find((v) => v.fontWeight === String(o.weight || 400)));
    } else if (o.weight) {
      rg.fontWeight = String(o.weight);
    }
    if (o.color) rg.fills = [{ fillColor: o.color, fillOpacity: 1 }];
    if (o.size) rg.fontSize = String(o.size);
    return rg;
  }

  // ── components ─────────────────────────────────────────────────────────
  // The window: top bar, status bar, and the rules between them. Identical on
  // every screen — if one of them needs it different, the token changes and
  // they all follow.
  chrome(space, statusItems) {
    const top = this.rect("top bar", 0, 0, L.windowW, L.topBar, { fill: P.surface_raised });
    top.borderRadiusTopLeft = 12;
    top.borderRadiusTopRight = 12;
    this.rect("top bar / rule", 0, L.topBar - 1, L.windowW, 1, { fill: P.border });

    const st = this.rect("status bar", 0, L.windowH - L.statusBar, L.windowW, L.statusBar,
      { fill: P.surface_raised });
    st.borderRadiusBottomLeft = 12;
    st.borderRadiusBottomRight = 12;
    this.rect("status bar / rule", 0, L.windowH - L.statusBar, L.windowW, 1, { fill: P.border });

    if (space) {
      this.text("top bar / space", L.pad + 4, 17, "tom",
        { size: 14, weight: 600, color: P.text_secondary });
      this.text("top bar / sep", 54, 17, "/", { size: 14, color: P.text_muted });
      this.text("top bar / folder", 66, 17, space, { size: 14, weight: 600, color: P.text_primary });
    }
    let x = L.pad + 4;
    statusItems.forEach((s, i) => {
      this.text(`status / ${i}`, x, L.windowH - L.statusBar + 10, s,
        { size: TY.status, color: P.text_muted });
      x += Math.max(s.length * 6.2, 80) + 32;
    });
  }

  // The left panel. Present on every screen where a space is open, and always
  // the same width — a panel narrower on one screen than another is a bug.
  explorer(tree, { selected = null, searchChip = null, dirty = null } = {}) {
    this.rect("explorer / rule", L.explorerW - 1, L.topBar, 1,
      L.windowH - L.topBar - L.statusBar, { fill: P.border });
    this.text("explorer / caption", L.pad, L.topBar + 18, "EXPLORER",
      { size: TY.label, weight: 600, ls: 1.2, color: P.text_muted });

    this.rect("explorer / search", L.padTight, L.topBar + 48, 148, 28,
      { fill: P.surface_sunken, stroke: P.border, r: 6 });
    this.text("explorer / search placeholder", L.padTight + 12, L.topBar + 55, "Search",
      { size: TY.caption, color: P.text_muted });
    if (searchChip) this.chip("explorer / search chip", L.padTight + 158, L.topBar + 51, searchChip);

    const y0 = L.topBar + 108;
    tree.forEach(([lvl, label, folder], i) => {
      const y = y0 + i * L.row;
      const x = L.pad + lvl * 16;
      const sel = i === selected;
      if (sel) {
        this.rect("explorer / selected row", 12, y - 4, L.explorerW - 24, 26,
          { fill: P.accent_soft, r: 6 });
      }
      if (folder) {
        this.text(`explorer / chevron ${label}`, x - 12, y + 1, folder === "open" ? "▾" : "▸",
          { size: 9, color: P.text_muted });
      }
      this.text(`explorer / ${label}`, x, y, label, {
        size: TY.ui,
        weight: sel ? 600 : (folder ? 500 : 400),
        color: sel ? P.accent : (folder ? P.text_primary : P.text_secondary),
      });
      if (dirty === i) this.dot(`explorer / dirty ${label}`, L.explorerW - 30, y + 5);
    });
  }

  // Source · Split · Preview. `mark` is the unsaved indicator, on the right.
  modeBar(active, { docX = L.explorerW, docW = L.windowW - L.explorerW, mark = null } = {}) {
    this.rect("mode bar / rule", docX, L.topBar + L.modeBar - 1, docW, 1, { fill: P.border });
    const segX = docX + 24;
    const segW = 74;
    this.rect("mode bar / segmented", segX, L.topBar + 5, segW * 3, 26,
      { fill: P.surface_sunken, stroke: P.border, r: 7 });
    this.rect("mode bar / active", segX + active * segW + 2, L.topBar + 7, segW - 4, 22,
      { fill: P.surface_raised, stroke: P.border_strong, r: 5 });
    ["Source", "Split", "Preview"].forEach((label, i) => {
      this.textCentred(`mode bar / ${label}`, segX + i * segW, L.topBar + 12, segW, label, {
        size: TY.caption,
        weight: i === active ? 600 : 400,
        color: i === active ? P.text_primary : P.text_secondary,
      });
    });
    if (mark) {
      const w = mark.length * 6.4 + 30;
      this.dot("mode bar / mark dot", docX + docW - 12 - w, L.topBar + 14);
      this.text("mode bar / mark", docX + docW - 12 - w + 14, L.topBar + 10, mark,
        { size: TY.caption, weight: 500, color: P.text_secondary });
    }
  }

  // Dates a control: it is in the layout, it arrives in that milestone. The
  // one thing carried over from the wireframes, because it still means the
  // same thing here.
  chip(name, x, y, label) {
    this.rect(`${name}`, x, y, 30, 20, { stroke: P.border_strong, r: 10 });
    this.text(`${name} label`, x + 7, y + 4, label,
      { size: TY.label, weight: 600, color: P.text_muted });
  }

  dot(name, x, y, color = P.accent) {
    return this.rect(name, x, y, 7, 7, { fill: color, r: 4 });
  }

  button(name, x, y, w, label, { primary = false, h = 48, size = 15 } = {}) {
    this.rect(name, x, y, w, h, primary
      ? { fill: P.accent, r: 8 }
      : { stroke: P.border_strong, r: 8 });
    this.textCentred(`${name} label`, x, y + (h - size * 1.4) / 2 + 1, w, label, {
      size,
      weight: primary ? 600 : 500,
      color: primary ? P.surface_raised : P.text_muted,
    });
  }

  // ── the rendered document ──────────────────────────────────────────────
  // Shared by every screen that shows a preview, so the reading rhythm cannot
  // drift between reading mode, the split view and the commit screen.
  //
  // Laid out in two passes with ONE wait between them, rather than measuring
  // each paragraph as it is created. The plugin runs in a browser tab, and a
  // tab that loses focus gets its timers throttled — so the cost that matters
  // is the NUMBER of waits, not their length. Twelve paragraphs measured one
  // by one is twelve chances to be throttled past the call budget; this is one.
  // Returns the y it finished at.
  async renderedDoc(doc, { x, w, y, size = TY.bodySplit, prefix = "preview" }) {
    const S = size;
    const TW = w - 26;
    const plan = [];
    let cur = y;

    // Rough line count. Only used for the provisional placement in pass one —
    // pass two replaces it with the height Penpot actually laid out.
    const guess = (str, width, fs) =>
      Math.max(fs * 1.7, Math.ceil((str.length * fs * 0.5) / width) * fs * 1.7);

    // advance: a fixed slot height. null means "measure this one afterwards".
    const add = (shape, { box = null, advance = null, gap = 0 } = {}) => {
      plan.push({ shape, box, advance, gap });
      cur += (advance ?? guess(shape.characters, w, S)) + gap;
      return shape;
    };

    add(this.text(`${prefix} / h2`, x, cur, doc.title,
      { size: S + 9, weight: 600, color: P.text_primary, lh: 1.3 }), { advance: S + 32 });

    for (const node of doc.body) {
      if (node.p) {
        const s = this.para(`${prefix} / ${node.name}`, x, cur, w, node.p,
          { size: S, lh: 1.7, color: P.text_primary });
        for (const [sub, o] of node.spans || []) {
          this.range(s, sub, o.code
            ? { font: "mono", weight: 400, size: S - 1.5 }
            : (o.link ? { color: P.accent } : { weight: 600 }));
        }
        add(s, { gap: 26 });
      } else if (node.h3) {
        add(this.text(`${prefix} / h3 ${node.h3}`, x, cur, node.h3,
          { size: S + 2, weight: 600, color: P.text_primary, lh: 1.35 }), { advance: S + 25 });
      } else if (node.items) {
        for (const [link, text, codes] of node.items) {
          const box = this.rect(`${prefix} / box ${link}`, x, cur + 4, 15, 15,
            { fill: P.surface_raised, stroke: P.border_strong, r: 4 });
          const s = this.para(`${prefix} / item ${link}`, x + 26, cur, TW, text,
            { size: S - 0.5, lh: 1.65, color: P.text_primary });
          this.range(s, link, { color: P.accent, weight: 600 });
          for (const c of codes || []) {
            this.range(s, c, { font: "mono", weight: 400, size: S - 2 });
          }
          add(s, { box, gap: 10 });
        }
        cur += 16;
        plan.push({ spacer: 16 });
      }
    }

    await settle(450);   // the one wait: every text lays out in parallel

    let ey = y;
    for (const step of plan) {
      if (step.spacer) { ey += step.spacer; continue; }
      step.shape.y = ey;
      if (step.box) step.box.y = ey + 4;
      ey += (step.advance ?? step.shape.height) + step.gap;
    }
    return ey;
  }

  place(col, row) {
    this.board.x = col * (L.windowW + TOKENS.grid.gapX);
    this.board.y = row * (L.windowH + TOKENS.grid.gapY);
    return this.board;
  }
}

// ── Dark mode is derived, never drawn ────────────────────────────────────
// visual-language.md: a colour added in one mode without its counterpart is a
// bug. Building the map from the two role tables makes that structural — a new
// role appears in both or in neither.
const ROLE_MAP = Object.fromEntries(
  Object.keys(TOKENS.light).map((k) => [TOKENS.light[k].toUpperCase(), TOKENS.dark[k]]),
);

async function darkify(lightBoard, name, col, row) {
  const swap = (c) => ROLE_MAP[(c || "").toUpperCase()] || c;
  const remap = (sh) => {
    if (Array.isArray(sh.strokes) && sh.strokes.length) {
      sh.strokes = sh.strokes.map((s) => ({ ...s, strokeColor: swap(s.strokeColor) }));
    }
    if (sh.fills !== "mixed" && Array.isArray(sh.fills) && sh.fills.length) {
      sh.fills = sh.fills.map((f) => ({ fillColor: swap(f.fillColor), fillOpacity: f.fillOpacity }));
    }
  };

  const dark = lightBoard.clone();
  dark.name = name;
  remap(dark);

  // A text whose spans carry their own colour reports `fills === "mixed"`, and
  // a bulk assignment would flatten the spans away. Those get the base colour
  // and then their one accent span back; the shape name says which span it is.
  const mixed = [];
  penpotUtils.analyzeDescendants(dark, (root, sh) => {
    if (sh.type === "text" && sh.fills === "mixed") { mixed.push(sh); return null; }
    remap(sh);
    return null;
  });
  for (const sh of mixed) {
    const n = sh.name;
    const sub = n.endsWith("/ lead") ? "product/"
      : n.endsWith("/ m1 lead") ? "Decision 2"
        : (n.match(/\/ item (.+)$/) || [])[1];
    sh.fills = [{ fillColor: TOKENS.dark.text_primary, fillOpacity: 1 }];
    if (sub) {
      const i = sh.characters.indexOf(sub);
      if (i >= 0) {
        sh.getRange(i, i + sub.length).fills = [{ fillColor: TOKENS.dark.accent, fillOpacity: 1 }];
      }
    }
  }

  dark.x = col * (L.windowW + TOKENS.grid.gapX);
  dark.y = row * (L.windowH + TOKENS.grid.gapY);
  await settle(350);
  return dark;
}
