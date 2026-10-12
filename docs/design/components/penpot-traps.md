# Penpot traps

Facts about the plugin API, each of which cost a session. The rules they serve
are [`library.md`](library.md).

- **The terminal's stand-in font is Source Code Pro** — Menlo, the face the app draws it in on macOS, is not available in Penpot; a board's terminal text is a stand-in, never a measure of the app's.
- `library.components` lists one entry per variant *set*; the rest are reached through `variants.variantComponents()`.
- The plugin draws only on the **active page**, so anything touching the library switches page and switches back. It cannot move a shape between pages at all — `appendChild` answers `Cannot modify a page that is not currently active`.
- **Count `library.local.components` before and after any page surgery.** Duplicating a page that holds main instances duplicates the components, and so does cut-pasting a variant set; a jump in the count is the whole of the damage, and undo is the only clean repair. A plain master cut and pasted in the Penpot app keeps its ids.
- `Cannot change the structure of a component copy` is Penpot refusing to add or remove a copy's children, and it is right to. Editing a master means editing its children, never replacing them.
- Colour, size and flex *are* overridable on a copy. A control wrong in one theme is usually an override never set; a label sitting outside its control is usually a flex `justifyContent` with padding, not a bad `x`.
- **Assigning a text the value it already holds writes nothing**, so a copy whose stored `characters` never became a real override keeps *drawing the master's* placeholder while the getter answers correctly. Every screen in this file read `One`/`Two` for months that way. Write a genuinely different value first, wait, then write the real one — a trailing space is trimmed and counts as no change.
- **Cloning a main instance inside a variant container makes a new variant**, named `Value N` for whichever property collided; `copy.component()` is null for a moment afterwards, so find it again through `variants.variantComponents()` rather than off the clone. Which property it renames is its choice, not yours — check `variantProps` and set both axes.
- **A variant container insets its contents by 30 on both axes.** The box is not where the drawing starts, so a row of masters laid out by their boxes comes out ragged: position each container at the place you want *minus* its first child's offset.
- **A board clips when resized; a group scales.** The `Icon` variants are boards, so an instance of one shrunk to 16 loses most of the glyph. The git glyphs came from `createShapeFromSvg`, which makes groups, and survive any size.
- **A group does not scale a board inside it** — the board is clipped all the same — and a copy that was grouped and ungrouped comes back with `scale` constraints, so the next resize of its parent stretches it. Set its constraints to `top` and `left` before resizing the parent.
- **`component()` on a child answers the whole instance's component**, so counting components by walking every shape counts a button, its icon and its icon's path as three. Count only where the parent's component differs — otherwise a census of ghosts comes out more than twice too big.

`createComponent(shapes)` and `createVariantFromComponents(shapes)` both take
**shapes**, never a `LibraryComponent` — pass each one's `mainInstance()`. A
slash in the name becomes a path, and the grouped property arrives as
`Property 1`, so read `variantProps` before switching on it.

---

*See also: [library.md](library.md) · the [`tom-design`](../../../.ai/skills/tom-design/SKILL.md) skill*
