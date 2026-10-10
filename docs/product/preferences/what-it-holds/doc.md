# What it holds

Three preferences, and the rule that keeps a fourth from arriving casually.

**Status:** Shipped · Milestone M3

## Rules

- **Theme** — ~~light or dark, as a two-way control~~ **System, Light or Dark**, a three-way control (revised 2026-10-08). `System` follows the machine's appearance and is the default; the lit segment is the one chosen, not the colour that choice happens to land on.
- **Language** — a select of ~~English, Português, Español and Deutsch~~ **System, English and Português** (revised 2026-10-08): only a language the whole interface is translated into is offered.
- **`System` is the default** — the app speaks the machine's language, and English where that is neither of the two.
- **Each language names itself** — `English`, `Português` — so a reader finds theirs whatever the window speaks; only `System` is in the window's language.
- **A language no longer offered falls back to `System`, silently** — a file that says Español or Deutsch opens in the machine's language.
- **Choosing applies at once**, the popover included: its own words change under the pointer.
- **The chosen language carries a tick**, not a highlight alone — colour is never the only signal, here as everywhere else.
- **Show the formatting bar** — a checkbox. Turning it off hides the row's seventeen buttons, undo and redo with them; what the preference hides is the tools, not half of them.
- **The row itself stays**, because it ~~is also where the view is chosen — and with the buttons gone the modes go back to the centre of the window, under the branch control~~ also carries `Unsaved` and the `Diff` chip; the modes live in the top bar since 2026-10-07 and do not move (revised 2026-10-08) ([formatting shortcuts](../../editor/formatting-shortcuts/doc.md)).
- **Drawn, not built (2026-10-09)** — two more: **`Check for updates when TOM opens`**, a checkbox that is off until ticked ([about](../../about/doc.md)), and **`Git commands`**, `Automatic · Semi · Manual` ([approvals](../../git-workflow/approvals/doc.md)). The popover's last row is `About TOM`.
- **A preference belongs to the machine, not to the space.** Opening another folder does not change the theme, the language or the bar; anything that should differ per space is not a preference and does not belong here.
- **Nothing here needs a restart**, which is what makes the absence of OK and Cancel honest.

How the strings became translatable is [Decision 34](../../../technical/decisions/034-the-interface-is-localised-with-gen-l10n.md).

## Mocks

- **choosing a language** — the select open over the popover, the current one ticked. [light](../../../design/screens/desktop/preferences/choosing-a-language-light.svg) · [dark](../../../design/screens/desktop/preferences/choosing-a-language-dark.svg).
- **formatting bar hidden** — the preference applied, the modes centred on the pane. [light](../../../design/screens/desktop/preferences/formatting-bar-hidden-light.svg) · [dark](../../../design/screens/desktop/preferences/formatting-bar-hidden-dark.svg).

---

*See also: [preferences/](../README.md) · [the popover](../the-popover/doc.md) · [where it is stored](../where-it-is-stored/doc.md)*
