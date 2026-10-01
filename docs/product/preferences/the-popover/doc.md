# The button and the popover

Where preferences are reached from, and what opening them looks like.

**Status:** Shipped · Milestone M3

## Rules

- **The button is the last control in the top bar**, after the two column toggles, drawn in their grammar so the three read as one group. It is a gear, the one symbol nobody has to learn.
- **It replaces the light/dark toggle, which is gone from the bar.** ~~A control beside the two column toggles switches the theme~~ — the theme moved inside, and the bar trades one control for another instead of squeezing a fourth into the same margin ([columns](../../workspace/columns/doc.md)).
- **The bar carries it on every screen, Home included.** The language the app speaks is chosen before a space is open, not after, so a screen with nothing else in its bar still has this.
- **What opens is a popover, not a menu.** A menu is a list of choices in one tall row each; these are controls — a two-way choice, a select and a checkbox — and a menu would turn the language into a submenu.
- **It hangs from the button's right edge**, because a control at the right of a bar with a popover under its left edge lands off the window.
- **There is no scrim.** Dimming would say the rest of the window is blocked, and the point is to watch the app change behind it. The scrim belongs to the [dialog](../../workspace/leaving-a-space/doc.md), which asks and waits.
- **A preference applies when it is chosen.** There is no OK and no Cancel — press `Dark` and the window darkens behind the popover, so closing decides nothing.
- **It closes three ways, and one of them is visible.** The button stays lit while the popover is open, so pressing it again closes it; clicking outside and `Esc` do the same.

## Mocks

- **preferences** — the popover under its button, the app visible behind it. [light](../../../design/screens/desktop/preferences/preferences-light.svg) · [dark](../../../design/screens/desktop/preferences/preferences-dark.svg).

---

*See also: [preferences/](../README.md) · [what it holds](../what-it-holds/doc.md) · [columns](../../workspace/columns/doc.md)*
