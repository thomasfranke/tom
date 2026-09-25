// `tom test` — the suite, or one kind of it, over one package or all.
library;

import 'process.dart';

/// The dashboard that runs the tests and renders them.
const _runner = 'tool/src/commands/run_tests.dart';

/// The architecture assertions in `src/test/integrity/`, which are not a
/// package and belong to no kind: a run narrowed to unit tests is not asking
/// about the graph.
const arch = 'arch';

/// The folder each kind of test lives in, under a package's `test/`.
///
/// A kind is a path, not a naming convention, which keeps the menu and the
/// filesystem from drifting apart. End-to-end is not one: it drives the app
/// on a device, and is its own command (`tom e2e`).
const testKinds = {'unit', 'integration'};

/// Runs the suite, or one [kind] of it: a target without that folder is
/// reported as skipped rather than dropped, so "no e2e tests yet" is visible.
///
/// [coverage] is on by default because the dashboard reports it with no
/// second run; turn it off when iterating on one failing test.
Future<int> runTests({
  String? kind,
  List<String> targets = allTargets,
  bool coverage = true,
}) {
  final arguments = [
    'run',
    _runner,
    if (coverage) '--coverage',
    if (kind == null && targets.length == allTargets.length) arch,
    for (final target in targets)
      if (kind == null) target else '$target=test/$kind',
  ];
  return dart(arguments);
}

/// Runs only the architecture assertions: the fastest answer to "did I just
/// break a layer boundary".
Future<int> runArchTests({bool coverage = true}) =>
    dart(['run', _runner, if (coverage) '--coverage', arch]);

/// The argument that selects the diff-driven run.
const changed = 'diff';

/// Runs only the tests this branch's diff maps to, by name: a changed
/// `lib/foo.dart` runs `foo_test.dart` wherever it lives under that
/// package's `test/`, and a changed test file runs directly.
///
/// No import graph and no package-wide fallback: this proves the part you
/// touched is green, where the full run proves the workspace is. [base] is
/// what counts as changed — `HEAD` for uncommitted work only.
Future<int> runChangedTests({String base = 'main', bool coverage = true}) =>
    dart([
      'run',
      'tool/src/commands/run_changed_tests.dart',
      if (coverage) '--coverage',
      base,
    ]);

/// The argument that selects the recency-driven run.
const last = 'last';

/// Runs the tests the most recently edited files map to — the mapping of
/// [runChangedTests] over what the filesystem says was touched last.
///
/// The case the diff cannot serve: a branch two hundred files wide no longer
/// describes the last hour, and a file edited back to what the commit holds
/// is invisible to git. [count] defaults to ten, about a sitting's worth.
Future<int> runLastTests({int? count, bool coverage = true}) => dart([
  'run',
  'tool/src/commands/run_changed_tests.dart',
  if (coverage) '--coverage',
  count == null ? '--last' : '--last=$count',
]);

/// The argument that selects the CLI's own tests.
const cli = 'cli';

/// Runs the tests for `tom` itself.
///
/// They live in `src/test/cli/`, because `tool/` holds no pubspec: a tool
/// that resolves the workspace cannot depend on it being resolved, so it can
/// take no dependency on `package:test`.
Future<int> runCliTests({bool coverage = false}) =>
    dart(['run', _runner, if (coverage) '--coverage', cli]);
