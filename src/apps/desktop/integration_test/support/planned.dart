/// A scenario that is planned and not written: data, never a test.
///
/// `tom e2e` reads the `*_planned.dart` files under `e2e/` as text and lists
/// each call under its menu, dim and not selectable — the maintainer's way of
/// seeing what the survey found and nobody has written yet. A call does
/// nothing at run time, needs no Flutter, and is replaced by a real
/// `scenario(...)` in a `<doing_a_thing>_test.dart` file the day it is
/// written, in the same folder (the plan is deleted in the same change).
library;

/// Declares one planned scenario.
///
/// [name] is what the progress screen will show; [survey] the id in
/// `.claude/audits/2026-10-09-test-coverage/` it answers; [rule] the product
/// rule in one sentence, with its doc; [control] what it presses; [fixture]
/// the situation it runs against (an existing one, or `new: <name>`);
/// [steps] the step names, written for a dashboard.
void plannedScenario(
  String name, {
  required String group,
  required String describe,
  required String survey,
  required String rule,
  required String control,
  required String fixture,
  required List<String> steps,
  String? submenu,
}) {}
