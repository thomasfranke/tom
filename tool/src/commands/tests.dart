// `tom test` — the suite, or one kind of it, over one package or all.
library;

import 'process.dart';

/// The dashboard that runs the tests and renders them.
const _runner = 'tool/src/commands/run_tests.dart';

/// The architecture assertions, which are not a package.
///
/// They live in `src/test/integrity/` and prove the layer graph matches what
/// the pubspecs declare, so they run first in a full pass and belong to no
/// kind: a run narrowed to unit tests is not asking about the graph.
const arch = 'arch';

/// The folder each kind of test lives in, under a package's `test/`.
///
/// A kind is a path, not a naming convention — which is what keeps the menu
/// and the filesystem from drifting apart.
const testKinds = {'unit', 'integration', 'e2e'};

/// Runs tests.
///
/// With no [kind], the whole suite: the architecture assertions, then every
/// package in dependency order, then the apps. With a [kind], only that
/// folder of each target — a target that has no such folder is reported as
/// skipped rather than silently dropped, so "no e2e tests yet" is visible
/// instead of looking like a pass.
///
/// [coverage] is on by default because the dashboard reports line coverage
/// beside each package's pass/fail with no second run needed. Turn it off
/// when iterating on one failing test and the instrumentation is not worth
/// the wait.
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

/// Runs only the architecture assertions.
///
/// They read every `pubspec.yaml` and assert the dependency graph, including
/// that exactly one package knows Flutter exists. Worth running alone because
/// they are the fastest answer to "did I just break a layer boundary", and
/// because adding a dependency between layers is where the intent gets
/// declared — deliberately, since the graph is a decision.
Future<int> runArchTests({bool coverage = true}) =>
    dart(['run', _runner, if (coverage) '--coverage', arch]);

/// The argument that selects the diff-driven run.
const changed = 'diff';

/// Runs only the tests this branch's diff maps to, by filename convention.
///
/// A changed `lib/foo.dart` runs `foo_test.dart`, wherever it lives under
/// that package's `test/`; a changed test file runs directly. No import
/// graph and no package-wide fallback — touching `tom_core` does not rerun
/// every package that depends on it, only the tests whose name says they
/// cover what changed.
///
/// So this is not a cheaper `test`: it proves the part you touched is green,
/// where the full run proves the workspace is. [base] narrows what counts as
/// changed — `HEAD` for uncommitted work only.
Future<int> runChangedTests({String base = 'main', bool coverage = true}) =>
    dart([
      'run',
      'tool/src/commands/run_changed_tests.dart',
      if (coverage) '--coverage',
      base,
    ]);

/// The argument that selects the recency-driven run.
const last = 'last';

/// Runs the tests that the most recently edited files map to.
///
/// The same mapping as [runChangedTests] — a changed `lib/foo.dart` runs
/// `foo_test.dart` — over a different set of files: what the filesystem says
/// was touched last, rather than what git says differs from a commit.
///
/// That is the case the diff run cannot serve. A branch whose diff has grown
/// to two hundred files no longer describes the last hour of work on it, and
/// a file edited and then edited back to what the commit already holds is
/// invisible to git and is exactly what someone means by "run what I was just
/// working on". [count] defaults to ten, about a sitting's worth.
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
/// They live in `src/test/cli/`, not beside the CLI, because `tool/` holds no
/// pubspec — a tool that resolves the workspace cannot require the workspace
/// to be resolved before it runs, so it can take no dependency on
/// `package:test`. The workspace side has that dependency already and drives
/// the CLI as a process.
Future<int> runCliTests({bool coverage = false}) =>
    dart(['run', _runner, if (coverage) '--coverage', cli]);
