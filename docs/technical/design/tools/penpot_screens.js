// The screens themselves, composed from penpot_kit.js.
//
// One board per state the app is actually in, in the order the app reaches
// them — the same rule the wireframes follow. Each is built in light and then
// derived into dark, so the two modes cannot disagree.
//
// Every screen here has a counterpart wireframe next to its product's doc.md.
// The wireframe answers what is on the screen and where; this answers what it
// looks like. When they disagree about the layout, the wireframe is right.

const TREE = [
  [0, "docs", "open"],
  [1, "about.md", null],
  [1, "product", "closed"],
  [1, "technical", "closed"],
  [1, "tasks", "open"],
  [2, "roadmap.md", null],
  [0, "README.md", null],
];
const SELECTED = 5;   // roadmap.md — the open document on every space screen

// The document every preview renders. Real content from docs/tasks/roadmap.md,
// not placeholder bars: the reading measure and the type scale can only be
// judged against prose that actually exists.
const DOC = {
  title: "Phase 1 — MVP",
  body: [
    {
      name: "lead",
      p: "Goal: publicly demonstrate that “rendered diff + a comfortable Git workflow” "
        + "solves a real pain — the minimum slice a developer can try on a real repo in "
        + "five minutes. Each item is a product: what it must do lives in its doc.md "
        + "under product/.",
      spans: [["Goal:", {}], ["doc.md", { code: true }], ["product/", { link: true }]],
    },
    { h3: "M0 — Foundation" },
    {
      items: [
        ["Workspace", "Workspace — the panel layout: runTom(modules: []), panels via PanelDescriptor",
          ["runTom(modules: [])", "PanelDescriptor"]],
        ["Home", "Home — open a folder, recent spaces, the not-a-repository error", []],
        ["File tree", "File tree — dart:io directory listing + path, no new package",
          ["dart:io", "path"]],
        ["Markdown preview", "Markdown preview — markdown (AST), flutter_markdown_plus, re_highlight",
          ["markdown", "flutter_markdown_plus", "re_highlight"]],
        ["Source-mode editing", "Source-mode editing — includes saving to disk; re_editor (Spike A)",
          ["re_editor"]],
      ],
    },
    { h3: "M1 — Essential Git" },
    {
      name: "m1 lead",
      p: "All four run Git through the system binary via dart:io Process behind a "
        + "GitClient contract (Decision 2) — no new package.",
      spans: [["dart:io Process", { code: true }], ["GitClient", { code: true }],
        ["Decision 2", { link: true }]],
    },
    {
      items: [
        ["Commit", "Commit", []],
        ["Push / pull", "Push / pull", []],
        ["Branch switch", "Branch switch", []],
        ["File history", "File history", []],
      ],
    },
  ],
};

// The same document as raw markdown, for the source pane. Line numbers are
// real: the cursor in the status bar points at one of them.
const SOURCE_FROM = 28;
const SOURCE = [
  "### Phase 1 — MVP",
  "",
  "**Goal:** publicly demonstrate that \"rendered diff +",
  "a comfortable Git workflow\" solves a real pain — the",
  "minimum slice a developer can try on a real repo in",
  "five minutes. Each item is a product: what it must",
  "do lives in its `doc.md` under [product/](../product/).",
  "",
  "**M0 — Foundation**",
  "",
  "- [ ] [Workspace](../product/workspace/doc.md) — the",
  "      panel layout: `runTom(modules: [])`, panels via",
  "      `PanelDescriptor`",
  "- [ ] [Home](../product/home/doc.md) — open a folder,",
  "      recent spaces, the not-a-repository error",
  "- [ ] [File tree](../product/navigation/file-tree/)",
  "      — `dart:io` directory listing + `path`",
  "- [ ] [Markdown preview](../product/editor/markdown-",
  "      preview/doc.md) — `markdown` (AST)",
  "- [ ] [Source-mode editing](../product/editor/source-",
  "      mode/doc.md) — includes saving to disk",
  "",
  "**M1 — Essential Git**",
  "",
  "All four run Git through the system binary via",
  "`dart:io Process` behind a `GitClient` contract",
  "([Decision 2](../technical/decisions/002-git-via-",
  "system-binary.md)) — no new package.",
  "",
  "- [ ] [Commit](../product/git-workflow/commit/doc.md)",
  "- [ ] [Push / pull](../product/git-workflow/push-pull/)",
];
const CURSOR_LINE = 34;

// ── the design tokens in the Penpot file ─────────────────────────────────
// The same roles as palette.py, so anyone editing a board by hand picks from
// the system instead of typing a hex. Idempotent: re-running replaces nothing
// that already matches.
function ensureTokens() {
  const cat = penpot.library.local.tokens;
  if (cat.sets.find((s) => s.name === "light")) return "tokens already present";

  const light = cat.addSet({ name: "light" });
  const dark = cat.addSet({ name: "dark" });
  for (const role of Object.keys(TOKENS.light)) {
    const name = "color." + role.replace(/_/g, "-");
    light.addToken({ type: "color", name, value: TOKENS.light[role] });
    dark.addToken({ type: "color", name, value: TOKENS.dark[role] });
  }
  // Layout is mode-independent, so it lives with the light set and both
  // themes activate it.
  const L = TOKENS.layout;
  const sizing = {
    "size.top-bar": L.topBar, "size.status-bar": L.statusBar,
    "size.explorer": L.explorerW, "size.git-panel": L.gitW,
    "size.mode-bar": L.modeBar, "size.row": L.row, "size.list-row": L.listRow,
  };
  for (const [n, v] of Object.entries(sizing)) {
    light.addToken({ type: "sizing", name: n, value: String(v) });
  }
  for (const [n, v] of Object.entries({ "space.pad": L.pad, "space.pad-tight": L.padTight })) {
    light.addToken({ type: "spacing", name: n, value: String(v) });
  }
  for (const [n, v] of Object.entries({ "radius.md": 6, "radius.lg": 8, "radius.window": 12 })) {
    light.addToken({ type: "borderRadius", name: n, value: String(v) });
  }
  if (!light.active) light.toggleActive();

  const tLight = cat.addTheme({ group: "mode", name: "Light" });
  const tDark = cat.addTheme({ group: "mode", name: "Dark" });
  tLight.addSet(light);
  tDark.addSet(light);
  tDark.addSet(dark);
  if (!tLight.active) tLight.toggleActive();
  return "tokens created";
}

// ── shared pieces ────────────────────────────────────────────────────────
function sourcePane(s, { x, w, cursor = CURSOR_LINE }) {
  const P = TOKENS.light;
  const L = TOKENS.layout;
  const bodyY = L.topBar + L.modeBar;
  const bodyH = L.windowH - L.statusBar - bodyY;

  s.rect("source pane", x, bodyY, w, bodyH, { fill: P.surface_sunken });
  s.text("source / caption", x + L.pad, bodyY + 18, "SOURCE",
    { size: TOKENS.type.label, weight: 600, ls: 1.2, color: P.text_muted });
  s.text("source / file", x + w - L.pad - 74, bodyY + 18, "roadmap.md",
    { size: TOKENS.type.label, weight: 500, ls: 0.6, color: P.text_muted });

  const y0 = bodyY + 46;
  const pitch = 22;
  const gutter = x + 20;
  const code = x + 52;
  const ci = cursor - SOURCE_FROM;
  const cy = y0 + ci * pitch - 3;
  s.rect("source / active line", x, cy, w, pitch, { fill: P.accent_soft, opacity: 0.55 });

  SOURCE.forEach((line, i) => {
    const n = SOURCE_FROM + i;
    const y = y0 + i * pitch;
    s.textCentred(`source / ln ${n}`, gutter, y + 1, 22, String(n),
      { font: "mono", size: 11, color: P.text_muted, align: "right" });
    if (line) {
      s.text(`source / line ${n}`, code, y, line,
        { font: "mono", size: TOKENS.type.code, color: P.text_secondary });
    }
  });
  s.rect("source / caret", code + 90, cy + 2, 1.5, 16, { fill: P.accent });
}

// ── screens ──────────────────────────────────────────────────────────────

// 1. no space open. The first thing anyone sees; wording is the README's,
//    verbatim, because a second description of the product is a bug.
function homeEmpty() {
  const P = TOKENS.light;
  const L = TOKENS.layout;
  const s = new Scene("Home — empty state · Light");
  s.chrome(null, ["no space open"]);

  s.textCentred("brand / name", 0, 180, L.windowW, "TOM",
    { size: TOKENS.type.brand, weight: 600, color: P.text_primary, lh: 1.2 });
  s.textCentred("brand / expansion", 0, 250, L.windowW, "Team-Oriented Markdown",
    { size: 16, weight: 500, color: P.text_secondary });
  s.textCentred("brand / tagline", 0, 278, L.windowW,
    "A Git client built for documentation, not code.",
    { size: 15, font: "serif", color: P.text_muted, lh: 1.5 });

  // Three ways in, in the order the product ranks them.
  const cx = 500;
  const cw = 440;
  s.button("action / choose folder", cx, 352, cw, "Choose folder…", { primary: true });
  s.button("action / clone", cx, 412, cw, "Clone from URL");
  s.chip("action / clone chip", cx + cw + 16, 428, "M3");

  s.text("recent / caption", cx, 498, "RECENT",
    { size: TOKENS.type.label, weight: 600, ls: 1.2, color: P.text_muted });
  const recent = [
    ["docs", "~/dev/tom/docs", "main"],
    ["handbook", "~/work/acme/handbook", "feat/onboarding"],
    ["notes", "~/Documents/notes", "main"],
  ];
  const ry = 520;
  const rowH = 60;
  s.rect("recent / card", cx, ry, cw, rowH * recent.length + 2,
    { fill: P.surface_raised, stroke: P.border, r: 10 });
  recent.forEach(([name, path, branch], i) => {
    const y = ry + 1 + i * rowH;
    if (i) s.rect(`recent / rule ${i}`, cx + 16, y, cw - 32, 1, { fill: P.border });
    s.text(`recent / name ${name}`, cx + 20, y + 14, name,
      { size: 14, weight: 500, color: P.text_primary });
    s.text(`recent / path ${name}`, cx + 20, y + 33, path,
      { size: TOKENS.type.caption, color: P.text_muted });
    const bw = branch.length * 6.6 + 20;
    s.rect(`recent / branch box ${name}`, cx + cw - 20 - bw, y + 20, bw, 20,
      { fill: P.surface_sunken, r: 10 });
    s.textCentred(`recent / branch ${name}`, cx + cw - 20 - bw, y + 24, bw, branch,
      { size: 11, color: P.text_secondary });
  });
  return s;
}

// 2. the one way opening a folder fails. Drawn because the wording is the
//    design: it has to say what is wrong without implying TOM will fix it by
//    creating a repository, which is not something TOM does.
//
//    Deliberately colourless. The palette has no failure role, and `removed`
//    belongs to the diff — borrowing it here would make a red that means two
//    different things. The accent appears only on the way out, which is what
//    the accent is for.
function homeNotARepo() {
  const P = TOKENS.light;
  const L = TOKENS.layout;
  const s = new Scene("Home — not a Git repository · Light");
  s.chrome(null, ["no space open"]);

  s.textCentred("fail / heading", 0, 300, L.windowW,
    "That folder is not inside a Git repository",
    { size: 22, weight: 600, color: P.text_primary, lh: 1.35 });

  const path = "~/Documents/notes";
  const pw = path.length * 8.4 + 32;
  s.rect("fail / path box", (L.windowW - pw) / 2, 348, pw, 30, { fill: P.surface_sunken, r: 8 });
  s.textCentred("fail / path", (L.windowW - pw) / 2, 355, pw, path,
    { font: "mono", size: 13.5, color: P.text_secondary });

  s.para("fail / body", 440, 404, 560,
    "TOM works on documentation that is already versioned. Open a folder inside a "
    + "repository — the repository root, or any folder within it.",
    { font: "sans", size: 15, lh: 1.65, color: P.text_secondary, align: "center" });

  s.button("fail / retry", 580, 492, 280, "Choose another folder…", { primary: true });
  s.textCentred("fail / hint", 0, 560, L.windowW,
    "Creating a repository is not something TOM does.",
    { size: TOKENS.type.ui, color: P.text_muted, lh: 1.5 });
  return s;
}

// 3 and 5. The split view, and the same screen once the buffer has moved ahead
//    of the file on disk. One builder, because they are one layout: the unsaved
//    state is three marks, not a different screen.
async function shell({ unsaved = false } = {}) {
  const P = TOKENS.light;
  const L = TOKENS.layout;
  const s = new Scene(unsaved ? "Unsaved changes · Light" : "Shell — reading and editing · Light");
  s.chrome("docs", unsaved
    ? ["~/dev/tom/docs", "roadmap.md — unsaved", "⌘S to save"]
    : ["~/dev/tom/docs", "roadmap.md", "main"]);
  s.explorer(TREE, { selected: SELECTED, searchChip: "M2", dirty: unsaved ? SELECTED : null });
  s.modeBar(1, { mark: unsaved ? "Unsaved" : null });

  const docX = L.explorerW;
  const docW = L.windowW - L.explorerW;
  const split = docX + Math.round(docW / 2);
  const bodyY = L.topBar + L.modeBar;

  sourcePane(s, { x: docX, w: split - docX });
  s.rect("split rule", split - 1, bodyY, 1, L.windowH - L.statusBar - bodyY, { fill: P.border });
  s.text("preview / caption", split + L.pad, bodyY + 18, "PREVIEW",
    { size: TOKENS.type.label, weight: 600, ls: 1.2, color: P.text_muted });

  await s.renderedDoc(DOC, {
    x: split + L.pad, w: TOKENS.measure.split, y: bodyY + 42, size: TOKENS.type.bodySplit,
  });

  s.text("status / ln", L.windowW - 96, L.windowH - L.statusBar + 10, `Ln ${CURSOR_LINE}, Col 12`,
    { size: TOKENS.type.status, color: P.text_muted });
  return s;
}

// 4. preview only. Not the split with a pane hidden: about.md is explicit that
//    reading is not a lesser mode, so it gets a wider measure and a larger
//    body size than the split view can afford.
async function reading() {
  const L = TOKENS.layout;
  const s = new Scene("Reading — preview only · Light");
  s.chrome("docs", ["~/dev/tom/docs", "roadmap.md", "read-only"]);
  s.explorer(TREE, { selected: SELECTED, searchChip: "M2" });
  s.modeBar(2);

  const docW = L.windowW - L.explorerW;
  const rw = TOKENS.measure.read;
  const rx = L.explorerW + Math.round((docW - rw) / 2);
  await s.renderedDoc(DOC, {
    x: rx, w: rw, y: L.topBar + L.modeBar + 44, size: TOKENS.type.bodyRead, prefix: "reading",
  });
  return s;
}

// 6. stage, describe, commit. The first screen where the diff roles appear —
//    and each one carries a letter as well as a colour, because roughly one in
//    twelve men cannot separate the red from the green.
async function committing() {
  const P = TOKENS.light;
  const L = TOKENS.layout;
  const s = new Scene("Committing · Light");
  const gx = L.windowW - L.gitW;

  s.chrome("docs", ["feat/rendered-diff", "3 changes", "in sync"]);
  s.explorer(TREE, { selected: SELECTED });
  s.modeBar(2, { docX: L.explorerW, docW: gx - L.explorerW });

  // The branch is a control, not a label — switching is one of the four M1
  // products and it starts here.
  s.rect("top bar / branch", 560, 11, 210, 30,
    { fill: P.surface_raised, stroke: P.border_strong, r: 8 });
  s.text("top bar / branch name", 576, 18, "feat/rendered-diff",
    { size: TOKENS.type.ui, weight: 500, color: P.text_primary });
  s.text("top bar / branch chevron", 750, 20, "▾", { size: 9, color: P.text_muted });
  s.text("top bar / sync", 790, 18, "↑ 2   ↓ 0",
    { size: TOKENS.type.caption + 0.5, color: P.text_muted });
  s.rect("top bar / push", L.windowW - 120, 11, 96, 30,
    { fill: P.surface_raised, stroke: P.border_strong, r: 8 });
  s.textCentred("top bar / push label", L.windowW - 120, 19, 96, "Push",
    { size: TOKENS.type.ui, weight: 500, color: P.text_primary });

  const rw = TOKENS.measure.commit;
  const rx = L.explorerW + Math.round((gx - L.explorerW - rw) / 2);
  await s.renderedDoc(DOC, {
    x: rx, w: rw, y: L.topBar + L.modeBar + 40, size: TOKENS.type.bodySplit, prefix: "doc",
  });

  s.rect("git / rule", gx - 1, L.topBar, 1, L.windowH - L.topBar - L.statusBar, { fill: P.border });
  s.text("git / caption", gx + L.pad, L.topBar + 18, "CHANGES",
    { size: TOKENS.type.label, weight: 600, ls: 1.2, color: P.text_muted });

  const cx = gx + L.padTight;
  const changes = [
    ["M", "modified", "roadmap.md", "docs/tasks", true],
    ["A", "added", "rendered-diff/doc.md", "docs/product/diff", true],
    ["D", "removed", "016-freezed.md", "docs/technical/decisions", false],
  ];
  changes.forEach(([letter, role, file, path, staged], i) => {
    const y = L.topBar + 46 + i * 48;
    s.rect(`git / stage ${file}`, cx, y + 8, 15, 15, staged
      ? { fill: P.accent, stroke: P.accent, r: 4 }
      : { fill: P.surface_raised, stroke: P.border_strong, r: 4 });
    if (staged) {
      s.textCentred(`git / check ${file}`, cx, y + 9, 15, "✓",
        { size: TOKENS.type.label, weight: 700, color: P.surface_raised });
    }
    s.rect(`git / mark bg ${file}`, cx + 24, y + 6, 19, 19, { fill: P[`${role}_soft`], r: 4 });
    s.textCentred(`git / mark ${file}`, cx + 24, y + 10, 19, letter,
      { size: 11, weight: 700, color: P[role] });
    s.text(`git / file ${file}`, cx + 52, y + 5, file,
      { size: TOKENS.type.caption + 0.5, weight: 500, color: P.text_primary });
    s.text(`git / path ${file}`, cx + 52, y + 22, path, { size: 10.5, color: P.text_muted });
  });

  // The message field teaches the commit format the project already requires
  // (the tom-git-workflow skill), rather than rejecting it after the fact.
  const my = L.topBar + 214;
  const mw = L.gitW - 2 * L.padTight;
  s.rect("git / summary", cx, my, mw, 84, { fill: P.surface_sunken, stroke: P.border, r: 8 });
  s.text("git / summary text", cx + 12, my + 12, "docs(product): add the rendered-diff doc",
    { size: TOKENS.type.caption, color: P.text_primary, lh: 1.45 });
  s.rect("git / caret", cx + 12, my + 44, 1.5, 15, { fill: P.accent });
  s.text("git / summary hint", cx + 12, my + 92, "Conventional Commits · scope = the package",
    { size: TOKENS.type.label, color: P.text_muted });

  // The destination branch belongs in the action, not somewhere else on screen.
  s.button("git / commit", cx, my + 118, mw, "Commit to feat/rendered-diff",
    { primary: true, h: 40, size: TOKENS.type.caption + 0.5 });
  s.text("git / commit note", cx, my + 172, "2 of 3 staged",
    { size: TOKENS.type.status, color: P.text_muted });
  return s;
}


// 7. the branch switcher. The first non-modal surface in the app: Decision 6
//    keeps `Navigator` for dialogs only, so anything that is not modal is a
//    surface anchored to its trigger — and this one sets the pattern every
//    later popover follows.
async function branchSwitcher() {
  const P = TOKENS.light;
  const L = TOKENS.layout;
  const s = new Scene("Branch switcher · Light");
  s.chrome("docs", ["feat/rendered-diff", "3 changes", "in sync"]);
  s.explorer(TREE, { selected: SELECTED });
  s.modeBar(2);

  // The trigger reads as open: accent border, and the popover starts at its
  // left edge so the two are visibly one control.
  const bx = 560;
  const bw = 210;
  s.rect("top bar / branch", bx, 11, bw, 30, { fill: P.surface_raised, stroke: P.accent, sw: 1.5, r: 8 });
  s.text("top bar / branch name", bx + 16, 18, "feat/rendered-diff",
    { size: TOKENS.type.ui, weight: 500, color: P.text_primary });
  s.text("top bar / branch chevron", bx + 190, 20, "▾", { size: 9, color: P.accent });
  s.text("top bar / sync", bx + 230, 18, "↑ 2   ↓ 0",
    { size: TOKENS.type.caption + 0.5, color: P.text_muted });

  const rw = TOKENS.measure.split;
  await s.renderedDoc(DOC, {
    x: L.explorerW + 60, w: rw, y: L.topBar + L.modeBar + 40,
    size: TOKENS.type.bodySplit, prefix: "doc",
  });

  // ── the popover ────────────────────────────────────────────────────────
  const pw = 300;
  const py = 48;
  const pop = s.rect("branches / surface", bx, py, pw, 306,
    { fill: P.surface_raised, stroke: P.border, r: 10 });
  // Elevation is what separates a popover from a panel; `surface_raised` alone
  // is not enough over a warm surface.
  pop.shadows = [{
    style: "drop-shadow", offsetX: 0, offsetY: 8, blur: 24, spread: 0,
    color: P.text_primary, opacity: 0.12,
  }];
  s.rect("branches / filter", bx + L.padTight, py + 16, pw - 2 * L.padTight, 30,
    { fill: P.surface_sunken, stroke: P.border, r: 6 });
  s.text("branches / filter placeholder", bx + L.padTight + 12, py + 24, "Filter branches",
    { size: TOKENS.type.caption, color: P.text_muted });

  const branches = [
    ["feat/rendered-diff", "you · 2 hours ago", true],
    ["main", "3 days ago", false],
    ["feat/space-session", "you · last week", false],
    ["fix/watcher-echo", "2 weeks ago", false],
  ];
  branches.forEach(([name, meta, current], i) => {
    const y = py + 62 + i * 44;
    if (current) {
      s.rect("branches / current row", bx + 8, y - 4, pw - 16, 38, { fill: P.accent_soft, r: 6 });
      s.textCentred("branches / current tick", bx + pw - 34, y + 6, 14, "✓",
        { size: 11, weight: 700, color: P.accent });
    }
    s.text(`branches / ${name}`, bx + L.padTight + 8, y, name, {
      size: TOKENS.type.ui, weight: current ? 600 : 400,
      color: current ? P.accent : P.text_primary,
    });
    s.text(`branches / meta ${name}`, bx + L.padTight + 8, y + 17, meta,
      { size: TOKENS.type.label + 0.5, color: P.text_muted });
  });

  const sepY = py + 62 + branches.length * 44 + 2;
  s.rect("branches / rule", bx + L.padTight, sepY, pw - 2 * L.padTight, 1, { fill: P.border });
  s.text("branches / create", bx + L.padTight + 8, sepY + 14, "Create branch…",
    { size: TOKENS.type.ui, weight: 500, color: P.text_primary });
  return s;
}

// 8. file history. Scoped to the open document rather than the repository —
//    which is what makes it useful for documentation, and what the M1 line
//    actually says. The panel states that scope by naming the file under the
//    caption, rather than by carrying a note explaining itself.
async function fileHistory() {
  const P = TOKENS.light;
  const L = TOKENS.layout;
  const s = new Scene("File history · Light");
  const gx = L.windowW - L.gitW;

  s.chrome("docs", ["feat/rendered-diff", "roadmap.md", "in sync"]);
  s.explorer(TREE, { selected: SELECTED });
  s.modeBar(2, { docX: L.explorerW, docW: gx - L.explorerW });

  const rw = TOKENS.measure.commit;
  const rx = L.explorerW + Math.round((gx - L.explorerW - rw) / 2);
  await s.renderedDoc(DOC, {
    x: rx, w: rw, y: L.topBar + L.modeBar + 40, size: TOKENS.type.bodySplit, prefix: "doc",
  });

  s.rect("history / rule", gx - 1, L.topBar, 1, L.windowH - L.topBar - L.statusBar, { fill: P.border });
  s.text("history / caption", gx + L.pad, L.topBar + 18, "HISTORY",
    { size: TOKENS.type.label, weight: 600, ls: 1.2, color: P.text_muted });
  s.text("history / scope", gx + L.pad, L.topBar + 34, "roadmap.md",
    { size: TOKENS.type.caption, weight: 500, color: P.text_secondary });

  const cx = gx + L.padTight;
  const commits = [
    ["Split phase 1 into milestones", "a3f9c21", "you", "2 hours ago"],
    ["Name the two spikes and timebox them", "7b2e5d4", "you", "yesterday"],
    ["Move the roadmap next to the queue", "c81a0f6", "Ana", "3 days ago"],
    ["Drop the user-research phase", "1d4e7b9", "you", "last week"],
    ["First pass at the MVP scope", "5f0c3a2", "you", "2 weeks ago"],
  ];
  commits.forEach(([subject, sha, who, when], i) => {
    const y = L.topBar + 64 + i * 62;
    if (i) s.rect(`history / rule ${i}`, cx, y - 14, L.gitW - 2 * L.padTight, 1, { fill: P.border });
    s.para(`history / subject ${i}`, cx, y, L.gitW - 2 * L.padTight - 8, subject,
      { font: "sans", size: TOKENS.type.caption + 0.5, weight: 500, lh: 1.4, color: P.text_primary });
    s.text(`history / meta ${i}`, cx, y + 22, `${sha} · ${who} · ${when}`,
      { font: "mono", size: TOKENS.type.label + 0.5, color: P.text_muted });
  });
  return s;
}

// 9. push rejected. The interesting half of push/pull, and named as a state
//    because the wording decides whether a non-developer understands what to
//    do next — the whole point of not hiding Git behind a Sync button.
//
//    Colourless, like the not-a-repository screen and for the same reason: the
//    palette has no failure role, and `removed` belongs to the diff. The
//    condition is carried by position, weight, a disabled Push and a sync
//    counter that reads ↓ 3 — never by a colour that means something else.
async function pushRejected() {
  const P = TOKENS.light;
  const L = TOKENS.layout;
  const s = new Scene("Push rejected · Light");
  const gx = L.windowW - L.gitW;

  s.chrome("docs", ["feat/rendered-diff", "2 ahead, 3 behind"]);
  s.explorer(TREE, { selected: SELECTED });
  s.modeBar(2, { docX: L.explorerW, docW: gx - L.explorerW });

  s.rect("top bar / branch", 560, 11, 210, 30,
    { fill: P.surface_raised, stroke: P.border_strong, r: 8 });
  s.text("top bar / branch name", 576, 18, "feat/rendered-diff",
    { size: TOKENS.type.ui, weight: 500, color: P.text_primary });
  s.text("top bar / branch chevron", 750, 20, "▾", { size: 9, color: P.text_muted });
  // The counter is the first place the condition shows: 3 commits arrived.
  s.text("top bar / sync", 790, 18, "↑ 2   ↓ 3",
    { size: TOKENS.type.caption + 0.5, weight: 600, color: P.text_primary });
  s.rect("top bar / push", L.windowW - 120, 11, 96, 30, { stroke: P.border, r: 8 });
  s.textCentred("top bar / push label", L.windowW - 120, 19, 96, "Push",
    { size: TOKENS.type.ui, weight: 500, color: P.text_muted });

  const rw = TOKENS.measure.commit;
  const rx = L.explorerW + Math.round((gx - L.explorerW - rw) / 2);
  await s.renderedDoc(DOC, {
    x: rx, w: rw, y: L.topBar + L.modeBar + 40, size: TOKENS.type.bodySplit, prefix: "doc",
  });

  s.rect("git / rule", gx - 1, L.topBar, 1, L.windowH - L.topBar - L.statusBar, { fill: P.border });
  const cx = gx + L.padTight;
  const mw = L.gitW - 2 * L.padTight;

  s.text("reject / heading", cx, L.topBar + 26, "Someone pushed first",
    { size: 15, weight: 600, color: P.text_primary });
  s.para("reject / body", cx, L.topBar + 52, mw,
    "Three commits arrived on feat/rendered-diff while you were working. Pull them, then push again — nothing you committed has been lost.",
    { font: "sans", size: TOKENS.type.caption + 0.5, lh: 1.55, color: P.text_secondary });
  s.button("reject / pull", cx, L.topBar + 152, mw, "Pull", { primary: true, h: 40, size: TOKENS.type.ui });

  s.text("yours / caption", gx + L.pad, L.topBar + 226, "YOUR COMMITS",
    { size: TOKENS.type.label, weight: 600, ls: 1.2, color: P.text_muted });
  const mine = [
    ["Split phase 1 into milestones", "a3f9c21", "10 minutes ago"],
    ["Name the two spikes and timebox them", "7b2e5d4", "an hour ago"],
  ];
  mine.forEach(([subject, sha, when], i) => {
    const y = L.topBar + 254 + i * 62;
    if (i) s.rect(`yours / rule ${i}`, cx, y - 14, mw, 1, { fill: P.border });
    s.para(`yours / subject ${i}`, cx, y, mw - 8, subject,
      { font: "sans", size: TOKENS.type.caption + 0.5, weight: 500, lh: 1.4, color: P.text_primary });
    s.text(`yours / meta ${i}`, cx, y + 22, `${sha} · ${when}`,
      { font: "mono", size: TOKENS.type.label + 0.5, color: P.text_muted });
  });
  return s;
}

// ── build ────────────────────────────────────────────────────────────────
// Screens run in the order the app reaches them, one row each: dark left,
// light right, so the two modes are compared side by side and the flow reads
// top to bottom.
const SCREENS = [
  ["Home — empty state", () => homeEmpty()],
  ["Shell — reading and editing", () => shell()],
  ["Home — not a Git repository", () => homeNotARepo()],
  ["Reading — preview only", () => reading()],
  ["Unsaved changes", () => shell({ unsaved: true })],
  ["Committing", () => committing()],
  ["Branch switcher", () => branchSwitcher()],
  ["File history", () => fileHistory()],
  ["Push rejected", () => pushRejected()],
];

// ── the runner ───────────────────────────────────────────────────────────
// One screen per call, and resumable. Not because a screen is too big — with a
// single layout wait it is not — but because the plugin lives in a browser tab
// whose timers get throttled the moment that tab goes to the background. A
// throttled run should cost another call, never a half-drawn board.
//
// Run it repeatedly until it returns `done: true`. State lives in `storage`,
// which persists between calls; `PENPOT_ONLY = ["Committing"]` restricts the
// run to those screens, so one can be iterated on without rebuilding the set.
const STATE = (typeof storage !== "undefined" ? storage : globalThis);

async function main() {
  const tokens = ensureTokens();

  let job = STATE.__tomBuild;
  if (!job) {
    const only = globalThis.PENPOT_ONLY;
    const todo = SCREENS
      .map(([name, build], row) => ({ name, build, row }))
      .filter((x) => !only || only.includes(x.name));

    // Rebuilding replaces: a stale board left next to a new one is how a set
    // of screens starts disagreeing with itself.
    const wanted = new Set(todo.flatMap((x) => [`${x.name} · Light`, `${x.name} · Dark`]));
    penpot.currentPage.root.children
      .filter((b) => b.type === "board" && wanted.has(b.name))
      .forEach((b) => b.remove());

    job = STATE.__tomBuild = { todo, done: [], cursor: 0 };
  }

  // Dark sits in the left column, light in the right. The screens are still
  // composed in light and derived — ROLE_MAP runs light → dark — so the build
  // order and the review order are deliberately not the same thing.
  const step = job.todo[job.cursor];
  const scene = await step.build();
  await darkify(scene.board, `${step.name} · Dark`, 0, step.row);
  scene.place(1, step.row);
  job.done.push(step.name);
  job.cursor += 1;

  if (job.cursor < job.todo.length) {
    return { done: false, built: step.name, next: job.todo[job.cursor].name, tokens };
  }
  const built = job.done;
  delete STATE.__tomBuild;
  return { done: true, tokens, screens: built };
}
