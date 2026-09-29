# What it holds

Three preferences, and the rule that keeps a fourth from arriving casually.

**Status:** Planned · Milestone M3

## Rules

- **Theme** — light or dark, as a two-way control. It is the same choice the top bar used to carry; only the place changed.
- **Language** — a select, starting with English, Português, Español and Deutsch. The list is not the feature; what sits under it is, because a language means every literal the app shows becomes translatable.
- **The chosen language carries a tick**, not a highlight alone — colour is never the only signal, here as everywhere else.
- **Show the formatting bar** — a checkbox. Turning it off hides the row's seventeen buttons, undo and redo with them; what the preference hides is the tools, not half of them.
- **The row itself stays**, because it is also where the view is chosen — and with the buttons gone the modes go back to the centre of the window, under the branch control ([formatting shortcuts](../../editor/formatting-shortcuts/doc.md)).
- **A preference belongs to the machine, not to the space.** Opening another folder does not change the theme, the language or the bar; anything that should differ per space is not a preference and does not belong here.
- **Nothing here needs a restart**, which is what makes the absence of OK and Cancel honest.

The theme and the language are values written and read. The language is the one
that is not only a key: no decision records how the app's strings become
translatable, and that is work this preference implies rather than contains.

## Mocks

- **choosing a language** — the select open over the popover, the current one ticked. [light](../../../design/screens/desktop/preferences/choosing-a-language-light.svg) · [dark](../../../design/screens/desktop/preferences/choosing-a-language-dark.svg).
- **formatting bar hidden** — the preference applied, the modes centred on the pane. [light](../../../design/screens/desktop/preferences/formatting-bar-hidden-light.svg) · [dark](../../../design/screens/desktop/preferences/formatting-bar-hidden-dark.svg).

---

*See also: [preferences/](../README.md) · [the popover](../the-popover/doc.md) · [where it is stored](../where-it-is-stored/doc.md)*
