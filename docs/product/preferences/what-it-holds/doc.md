# What it holds

What a preference is here, and the rule that keeps a fourth from arriving casually.

**Status:** Shipped · Milestone M3

## Rules

- **Theme** — **System, Light or Dark**, a three-way control. `System` follows the machine's appearance and is the default; the lit segment is the one chosen, not the colour that choice happens to land on.
- **Language** — a select of **System, English and Português**: only a language the whole interface is translated into is offered.
- **`System` is the default** — the app speaks the machine's language, and English where that is neither of the two.
- **Each language names itself** — `English`, `Português` — so a reader finds theirs whatever the window speaks; only `System` is in the window's language.
- **A language no longer offered falls back to `System`, silently** — a file that says Español or Deutsch opens in the machine's language.
- **Choosing applies at once**, the popover included: its own words change under the pointer.
- **The chosen language carries a tick**, not a highlight alone — colour is never the only signal, here as everywhere else.
- **Show the formatting bar** — a checkbox. Turning it off hides the row's seventeen buttons, undo and redo with them; what the preference hides is the tools, not half of them.
- **Check for updates when TOM opens** — a checkbox, **on until it is unticked**, stored under `checkingForUpdates`; ticked, the app asks GitHub for the latest release once when it opens and says so quietly ([about](../../about/doc.md)). Nothing is asked while it is off.
- **The row itself stays**, because it also carries the `Diff` chip and is where a refused save says `Not saved`; the modes live in the top bar and do not move ([formatting shortcuts](../../editor/formatting-shortcuts/doc.md)).
- **A preference belongs to the machine, not to the space.** Opening another folder does not change the theme, the language or the bar; anything that should differ per space is not a preference and does not belong here.
- **Nothing here needs a restart**, which is what makes the absence of OK and Cancel honest.

How the strings became translatable is [Decision 34](../../../technical/decisions/034-the-interface-is-localised-with-gen-l10n.md).

## Mocks

- **the preferences popover — its states** — at rest, the three themes and `System` chosen; choosing a language, the select open with the current one ticked. [light](../../../design/screens/desktop/preferences/the-preferences-popover-states-light.svg) · [dark](../../../design/screens/desktop/preferences/the-preferences-popover-states-dark.svg).
- **formatting bar hidden** — the preference applied: the row above the document without its buttons, the modes where they were. [light](../../../design/screens/desktop/preferences/formatting-bar-hidden-light.svg) · [dark](../../../design/screens/desktop/preferences/formatting-bar-hidden-dark.svg).

---

*See also: [preferences/](../README.md) · [the popover](../the-popover/doc.md) · [where it is stored](../where-it-is-stored/doc.md)*
