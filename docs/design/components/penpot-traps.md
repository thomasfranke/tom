# Penpot traps

Five facts about the plugin API, each of which cost a session. The rules they
serve are [`library.md`](library.md).

- `library.components` lists one entry per variant *set*; the rest are reached through `variants.variantComponents()`.
- The plugin draws only on the **active page**, so anything touching the library switches page and switches back. It cannot move a shape between pages at all — `appendChild` answers `Cannot modify a page that is not currently active`.
- **Count `library.local.components` before and after any page surgery.** Duplicating or cut-pasting a page that holds main instances duplicates the components; a jump in the count is the whole of the damage, and undo is the only clean repair.
- `Cannot change the structure of a component copy` is Penpot refusing to add or remove a copy's children, and it is right to. Editing a master means editing its children, never replacing them.
- Colour, size and flex *are* overridable on a copy. A control wrong in one theme is usually an override never set; a label sitting outside its control is usually a flex `justifyContent` with padding, not a bad `x`.

`createComponent(shapes)` and `createVariantFromComponents(shapes)` both take
**shapes**, never a `LibraryComponent` — pass each one's `mainInstance()`. A
slash in the name becomes a path, and the grouped property arrives as
`Property 1`, so read `variantProps` before switching on it.

---

*See also: [library.md](library.md) · the [`tom-design`](../../../.ai/skills/tom-design/SKILL.md) skill*
