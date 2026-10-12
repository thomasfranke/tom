# The button and the popover

Where preferences are reached from, and what opening them looks like.

**Status:** Shipped · Milestone M3

## Rules

- **The button comes after the panel toggles and before [the account](../../workspace/the-account/doc.md)**, which is the bar's last control, drawn in the toggles' grammar so they read as one group. It is a gear, the one symbol nobody has to learn.
- **The bar has no theme toggle.** The theme is inside the popover — one control in the bar where two would share the same margin ([columns](../../workspace/columns/doc.md)).
- **The bar carries it on every screen, Home included.** The language the app speaks is chosen before a space is open, not after.
- **What opens is a popover, not a menu.** A menu is a list of choices in one tall row each; these are controls — a three-way choice, a select and a checkbox — and a menu would turn the language into a submenu.
- **It hangs from the button's right edge**, because a control at the right of a bar with a popover under its left edge lands off the window.
- **There is no scrim.** Dimming would say the rest of the window is blocked, and the point is to watch the app change behind it. The scrim belongs to a dialog, which asks and waits ([closing a tab](../../editor/tabs/doc.md)).
- **A preference applies when it is chosen.** There is no OK and no Cancel — press `Dark` and the window darkens behind the popover, so closing decides nothing.
- **The last row is `About TOM`**, with the running version at its right — `Update available` where a newer one is known. Pressing it shuts the popover and opens the [About dialog](../../about/doc.md).
- **A dot in `accent` sits on the gear while a newer version is known**, so the row is found without opening the popover.
- **It closes three ways, and one of them is visible.** The button stays lit while the popover is open, so pressing it again closes it; clicking outside and `Esc` do the same.

## Mocks

- **preferences** — the popover under its button, the app visible behind it. [light](../../../design/screens/desktop/preferences/preferences-light.svg) · [dark](../../../design/screens/desktop/preferences/preferences-dark.svg).
- **the preferences popover — its states** — at rest · choosing a language. [light](../../../design/screens/desktop/preferences/the-preferences-popover-states-light.svg) · [dark](../../../design/screens/desktop/preferences/the-preferences-popover-states-dark.svg).

---

*See also: [preferences/](../README.md) · [what it holds](../what-it-holds/doc.md) · [columns](../../workspace/columns/doc.md)*
