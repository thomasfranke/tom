/// The plan an opening started, handed to the first reading of the space.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_presentation/src/commands/command_scope.dart';

part 'opening_plan_notifier.g.dart';

/// Carries the opening's [CommandScope] from Home or the breadcrumb, which
/// ran the commands that open a folder, to `GitReadingNotifier`, which runs
/// the first reading once the window has changed — so the two are one plan
/// in the Commands panel, `Reading the repository`, and not a plan per read
/// (`docs/product/git-workflow/approvals/doc.md`).
///
/// Kept alive: it is written by a screen on its way out.
@Riverpod(keepAlive: true)
class OpeningPlanNotifier extends _$OpeningPlanNotifier {
  @override
  CommandScope? build() => null;

  /// The scope waiting for the next reading, if one was handed over.
  CommandScope? get handed => state;

  /// Keeps the scope for the next reading, replacing one nobody took.
  set handed(CommandScope? scope) => state = scope;

  /// The plan handed over, once: a later refresh is a plan of its own.
  CommandScope? take() {
    final CommandScope? handed = state;
    state = null;
    return handed;
  }
}
