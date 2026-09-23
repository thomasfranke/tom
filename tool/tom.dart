#!/usr/bin/env dart

// The CLI entry point: `dart run tool/tom.dart`.
//
// Two faces, one engine. With no arguments it opens a navigable menu; with a
// subcommand it runs the same code path non-interactively, which is what CI
// and other agents call. The menu never does work the subcommand cannot do —
// it prints the command it is about to run, so the two can never drift apart
// without the divergence showing on screen.
//
// It lives in `tool/` at the repository root, outside the Dart workspace in
// `src/`, and imports nothing but `dart:*` on purpose: a tool that resolves
// the workspace cannot require the workspace to be resolved before it runs.
library;

import 'dart:io';

import 'src/cli/menu.dart';
import 'src/cli/terminal.dart';
import 'src/commands/app.dart';
import 'src/commands/codegen.dart';
import 'src/commands/coverage.dart';
import 'src/commands/doctor.dart';
import 'src/commands/e2e.dart';
import 'src/commands/e2e_catalogue.dart';
import 'src/commands/process.dart';
import 'src/commands/quality.dart';
import 'src/commands/rules.dart';
import 'src/commands/tests.dart';
import 'src/commands/updates.dart';
import 'src/commands/workspace.dart';

import 'src/theme/theme.dart';

const _title = Layout.appTitle;
const _subtitle = Layout.appSubtitle;

/// Everything the CLI can do, in the order the menu and `--help` list it.
///
/// Alphabetical, not by importance: the list is read by someone looking for a
/// name they already have in mind, and any other order makes them scan the
/// whole thing. The test kinds are ordered by cost instead — see [_testKinds],
/// where the reader is choosing rather than looking something up.
const _commands = <_Command>[
  // Hidden from the root screen, not from the CLI: `verify` already runs both,
  // and a menu row for each would offer two steps of a sequence nobody runs
  // one at a time. A script, and the Makefile, still call them directly.
  _Command('analyze', 'Static analysis across every package', hidden: true),
  _Command(
    'build',
    'Compile check for a desktop platform',
    description:
        'Compiles the desktop app in release mode, to prove the repository '
        'builds on its own. This is the community build — the distributed '
        'artifact is produced elsewhere.',
  ),
  _Command(
    'clean',
    "Clear a package's build artifacts and resolve again",
    description:
        'Removes the build output and the build_runner cache — from all eight '
        'packages, or from one — keeping the measured coverage, then resolves '
        'the workspace again. The resolve is not optional, since cleaning '
        'also removes .dart_tool and nothing would build without it.',
  ),
  _Command(
    'codegen',
    'build_runner where a package declares it',
    description:
        'Runs build_runner over the workspace. Normal regenerates what this '
        'branch touched; Hard deletes every .freezed.dart and .g.dart first — '
        'both suffixes, whether or not a package has produced one yet — and '
        'rebuilds the lot.',
  ),
  // Not "run coverage": measuring is already part of every test run, and the
  // threshold is already part of `verify`. Building the report and opening it
  // is the only thing left that nothing else does, so that is the command.
  _Command(
    'coverage',
    'Build the coverage report and open it',
    description:
        'Runs the suite with coverage on — the same run, and the same '
        'progress bar, as Tests — then builds one HTML report out of every '
        'package measured and opens it. Needs genhtml, which ships with lcov.',
  ),
  // Hidden for the same reason as format and analyze: it is a step of
  // `verify`, not something anyone sets out to run on its own.
  _Command(
    'codegen-gate',
    'Regenerate from scratch and fail if the result drifted',
    hidden: true,
  ),
  _Command(
    'coverage-gate',
    'Fail if a package is under the coverage threshold',
    hidden: true,
  ),
  _Command(
    'doctor',
    'Check this machine has what the repository needs',
    description:
        'Reports the toolchain this repository asks for — git, the Dart the '
        'pubspecs declare, the Flutter src/.fvmrc pins — and fails if any of '
        'it is missing. The platform toolchains stay flutter doctor\'s '
        'question.',
  ),
  _Command(
    'format',
    'Format, failing if anything was not formatted',
    description:
        'Formats every Dart file under src/ and tool/, and fails if any of '
        'them was not already formatted — in a gate, "I fixed it for you" and '
        '"it was wrong" are the same event.',
  ),
  // The label is spelled out because the derivation would give `Fvm`, and a
  // tool's name is not a word to capitalize.
  _Command(
    'fvm',
    'Pin the Flutter version declared in src/.fvmrc',
    label: 'FVM',
    description:
        'Installs FVM and pins this workspace to the version in src/.fvmrc — '
        'the same file CI and the editor read, so everyone builds against one '
        'Flutter.',
  ),
  _Command(
    'run',
    'Open the desktop app',
    description: 'Builds and launches the desktop app on this machine.',
  ),
  // Labelled for what it does rather than for what it is called: `setup` is
  // the token scripts and the Makefile commit to, but on a screen it says
  // nothing, and the thing it runs has a name everyone already knows.
  _Command(
    'setup',
    'Resolve every package in the workspace',
    label: 'Pub get',
    description:
        'One pub get for all eight packages, against the single lockfile that '
        'keeps two layers off different versions of a shared dependency. The '
        'first thing to run after a clone, and after pulling a pubspec change.',
  ),
  _Command('test', 'The architecture assertions, the packages, the apps'),
  // Spelled out for the same reason as FVM: the derivation would give
  // `Updates`, which reads as a noun — a list of them — rather than as the
  // question the command asks.
  _Command(
    'updates',
    'Compare the pinned Flutter and Dart against the latest stable',
    label: 'Check for updates',
    description:
        'Puts what src/.fvmrc pins and what this machine runs beside the '
        'current stable release. It reports and changes nothing: moving the '
        'pin moves it for CI too, so it stays a decision.',
  ),
  _Command(
    'e2e',
    'Drive the assembled app, one scenario at a time',
    label: 'End-to-end',
    description:
        'Opens the app for real and walks it through a named flow, showing '
        'which step it is on. Prepare builds the folders the scenarios run '
        'against; the list remembers when each last passed, and on which '
        'version of the app.',
  ),
  _Command(
    'rules',
    "The project's naming and shape rules, against the tree",
    description:
        'Checks what the analyzer cannot: that an implementation says so in '
        'its class and its file, that a capability is a complete folder, '
        'that the infrastructure barrel is its whole lib/src, that no '
        'repository holds a capability, and that no comment has run away. '
        'Reports every break in one pass, because each one is a rename.',
  ),
  _Command(
    'verify',
    'Everything CI runs, in one pass',
    description:
        'Format, analyze, the codegen gate, the whole suite and the coverage '
        'gate — in that order, stopping at the first failure. Green here '
        'means green on the PR.',
  ),
];

/// The kinds of test the suite is split into, alphabetically — the same order
/// the commands are in, and for the same reason: the row is found by name.
///
/// They match the folders under each package's `test/` — `unit/`,
/// `integration/` — so a row maps to a path, not to a naming convention that
/// has to be maintained separately.
const _testKinds = <_TestKind>[
  _TestKind(
    'integration',
    'Integration',
    description:
        'Everything under each package\'s test/integration — the ones that '
        'touch real files, real repositories and real processes, and are '
        'slower for it.',
  ),
  _TestKind(
    'unit',
    'Unit',
    description:
        'Everything under each package\'s test/unit — the fast ones, with no '
        'filesystem, no process and no clock behind them.',
  ),
];

/// How `codegen` can be run.
///
/// Ordered by blast radius, mildest first: `normal` regenerates what this
/// branch touched, `hard` deletes every generated file and rebuilds the lot.
const _codegenModes = <_CodegenMode>[
  _CodegenMode(
    'normal',
    'Normal',
    null,
    description:
        'Runs build_runner only where this branch changed something. Packages '
        'with no change are reported as skipped, with the reason.',
  ),
  _CodegenMode(
    'hard',
    'Hard',
    'deletes and regenerates all',
    description:
        'Deletes every .freezed.dart and .g.dart first, then regenerates '
        'regardless of the diff. This is what answers whether what is '
        'committed is what the annotations actually produce.',
  ),
];

/// The desktop platforms `build` targets, in the order the submenu lists them.
///
/// There is deliberately no "all of them" row: a macOS bundle cannot be
/// produced on Linux and vice versa, so the only honest offer is one platform
/// at a time — the host by default, the others when a cross build is set up.
const _platforms = <_Platform>[
  _Platform('macos', 'macOS'),
  _Platform('linux', 'Linux'),
  _Platform('windows', 'Windows'),
];

/// The mobile targets `src/apps/mobile` will build for, once it does.
///
/// Listed with no `name`: there is no argument to pass yet, and inventing one
/// now would be a promise about a command line that does not exist.
const _mobilePlatforms = <_Platform>[
  _Platform('', 'Android'),
  _Platform('', 'iOS'),
];

/// Runs the CLI and hands its exit code to the process.
///
/// The code has to be *assigned*, not returned: Dart discards whatever `main`
/// answers, so a `Future<int> main` reports success for every failure it ever
/// finds — which is the quiet version of a broken gate, because CI goes green
/// on a tree that does not analyze.
///
/// [exitCode] rather than [exit]: `exit` terminates the isolate where it
/// stands, skipping the `finally` in [_browse] that puts the terminal back.
/// A menu session that failed would leave the user in the alternate buffer
/// with no echo. Assigning lets the isolate finish and flush on its own.
Future<void> main(List<String> args) async {
  exitCode = await _run(args);
}

/// The CLI proper: dispatches [args] and answers the code the process should
/// exit with.
Future<int> _run(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    _printUsage();
    return 0;
  }

  // Renders the root screen once, as static text, and exits. The redraw loop
  // needs a terminal; this does not, which is what makes the look reviewable
  // from a pipe, a diff or a test.
  if (args.contains('--preview')) {
    stdout.writeln(_rootFrame(columns: 96).join('\n'));
    return 0;
  }

  if (args.isNotEmpty) return _dispatch(args.first, args.skip(1).toList());

  // No arguments and nowhere to draw: a menu would hang waiting for a key
  // that is never coming, so say what to type instead.
  if (Terminal.isPlain) {
    stderr.writeln('tom: no terminal attached — pass a command.');
    _printUsage();
    return 64; // EX_USAGE
  }

  return _browse();
}

/// The interactive loop: pick a command, run it, come back to where it was
/// picked.
///
/// Everything happens full screen, the work included, so a run looks like the
/// menu that started it rather than like output arriving from somewhere else.
/// The cost is that the alternate buffer discards what it held on the way
/// out, which is why a finished run waits for a keystroke: that pause is the
/// only chance to read it.
///
/// After that keystroke the loop returns to the command's own screen, not to
/// the root — running codegen twice in a row is one keystroke, not four.
Future<int> _browse() async {
  final terminal = Terminal.attach();
  try {
    while (true) {
      terminal.enterFullScreen();
      final chosen = await showMenu<String>(
        terminal,
        title: _title,
        titleSuffix: _subtitle,
        prompt: _prompt,
        items: _rootItems,
      );
      if (chosen == null) {
        terminal.leaveFullScreen();
        return 0;
      }

      // A row's value is the invocation it stands for, so `Unit` arrives here
      // as `test unit`: the kind is already decided and only the scope is
      // still open.
      final invocation = chosen.split(' ');
      final name = invocation.first;
      final carried = invocation.skip(1).toList();

      await _runUntilBack(terminal, name, carried);
    }
  } finally {
    terminal.restore();
  }
}

/// Runs [name] as many times as asked, returning when the user backs out.
///
/// A command with a screen of its own returns to that screen after each run.
/// One without — `verify` — has nothing to return to, so it runs once and the
/// loop above takes over.
Future<void> _runUntilBack(
  Terminal terminal,
  String name,
  List<String> carried,
) async {
  var context = carried;
  while (true) {
    final arguments = await _promptFor(terminal, name, context);
    if (arguments == null) return;

    // What the first screen decided is kept for the next round, so a run
    // returns to the screen it was started from rather than to the one
    // before it. Answering "which app?" again after every scenario would be
    // a keystroke spent re-deciding something nobody changed.
    context = _contextAfter(name, arguments, context);

    terminal.beginScreen();
    _printHeader(name, arguments);

    // Cooked mode for the duration of the work, so a Ctrl-C reaches the child
    // rather than arriving as a byte nobody is reading.
    //
    // The exit code is dropped on purpose — the only place in the CLI where
    // that is true. A failed command inside a session is something to read
    // and try again, not a reason to throw the user out of the menu; it has
    // already printed its own failure, and the keystroke below is what gives
    // them time to see it. The subcommand face is where a code has to
    // survive, and it does, through `main`.
    terminal.suspend();
    await _dispatch(name, arguments);
    terminal.resume();

    await _waitForKey(terminal);
    if (!_hasOwnScreen(name, carried)) return;
  }
}

/// What the next round of [name]'s screen should already know.
///
/// Only end-to-end has two screens deep enough for this to matter: the app
/// is chosen once and the scenarios are chosen many times.
List<String> _contextAfter(
  String name,
  List<String> arguments,
  List<String> context,
) => switch (name) {
  'e2e' when context.isEmpty && !_environmentWords.contains(arguments.first) =>
    const <String>['desktop'],
  _ => context,
};

/// The e2e arguments that are not a scenario name.
const _environmentWords = <String>{'prepare', 'clean', 'list', 'fixtures'};

/// Whether [name] shows a screen of its own — and so has one to return to
/// after a run, and one to ask on before it.
///
/// The same predicate answers both, which is what keeps them from disagreeing:
/// a command that returns to a screen it never showed would loop forever.
bool _hasOwnScreen(String name, List<String> carried) => switch (name) {
  'build' || 'clean' || 'codegen' => true,
  // Two screens of its own, so it always has one to return to.
  'e2e' => true,
  // The list of rules is the screen — a run goes back to it, because
  // reading one break and checking the next is the normal way through.
  'rules' => true,
  // Only the per-package form asks anything; `coverage last` and
  // `coverage diff` already know what they are about.
  'coverage' => carried.isEmpty,
  // `test` asks about scope only once a kind is chosen. The whole suite has
  // nothing to ask, and neither do the architecture assertions — they are not
  // split per package.
  'test' =>
    carried.isNotEmpty &&
        carried.first != arch &&
        carried.first != cli &&
        carried.first != changed &&
        carried.first != last,
  _ => false,
};

/// Draws the same title and section a menu would, above a run's output, so
/// the work reads as part of the screen that started it.
void _printHeader(String name, List<String> arguments) {
  stdout
    ..writeln(
      '${palette.title}$_title${Ansi.reset} ${palette.titleSuffix}'
      '${Layout.titleSeparator} $_subtitle${Ansi.reset}',
    )
    ..writeln()
    ..writeln('${palette.section}${_labelFor(name)}${Ansi.reset}')
    ..writeln()
    ..writeln(
      '${' ' * Layout.promptColumn}${palette.prompt}→ dart run tool/tom.dart '
      '${[name, ...arguments].join(' ')}${Ansi.reset}',
    );
}

/// Holds the finished output on screen until a key is pressed.
///
/// Without it the alternate buffer would be cleared by the next screen and
/// the run would have produced nothing anyone could read.
Future<void> _waitForKey(Terminal terminal) async {
  stdout
    ..writeln()
    ..write(
      '${' ' * Layout.promptColumn}${palette.prompt}'
      'Press any key to continue${Ansi.reset}',
    );
  await terminal.keys.first;
}

/// The root screen has no section heading: there is only one group of
/// commands above `Tests`, and a heading over the only thing on screen names
/// nothing the title has not already said.
const _prompt = 'What do you want to run?';

/// Commands the root screen lists under `Tests` rather than in the first
/// group.
///
/// `test` itself is here because the screen offers its kinds rather than the
/// command; `coverage` because someone looking for it is thinking about
/// tests, not about the browser it happens to open.
const _testGroup = {'test', 'coverage', 'e2e', 'rules'};

/// Commands the root screen lists under `Dev Tools`.
///
/// What they have in common is that they act on the repository rather than on
/// the product: they resolve it, regenerate it, tidy it, pin its toolchain,
/// check it before a PR. The first group is left with the two things that
/// produce the app itself — build it, run it.
const _devToolsGroup = {'clean', 'codegen', 'format', 'verify'};

/// Commands the root screen lists under `Setup`: getting a machine ready.
const _setupGroup = {'doctor', 'fvm', 'setup', 'updates'};

/// The root screen's rows.
///
/// Labels only. The right-hand slot is for metadata a row carries — when it
/// last ran, whether it is stale — not for descriptions; filling it on every
/// row turns the list into a ragged second column. The summaries live in
/// `--help`, where there is room for them.
///
/// The test kinds are a group on this screen rather than a submenu behind
/// `Test`: they are the rows reached most often, and a whole screen to choose
/// between three of them is a keystroke spent on nothing. A row's value is the
/// invocation it stands for, which is what keeps `Unit` and `tom test unit`
/// the same thing.
List<MenuItem<String>> get _rootItems => [
  for (final command in _commands)
    if (!command.hidden &&
        !_testGroup.contains(command.name) &&
        !_setupGroup.contains(command.name) &&
        !_devToolsGroup.contains(command.name))
      MenuItem(command.label, command.name, description: command.description),
  const MenuItem.rule(),
  const MenuItem.section('Setup'),
  ..._setupRows,
  const MenuItem.rule(),
  const MenuItem.section('Dev Tools'),
  for (final command in _commands)
    if (_devToolsGroup.contains(command.name))
      MenuItem(command.label, command.name, description: command.description),
  const MenuItem.rule(),
  const MenuItem.section('Tests'),
  // Alphabetical, like the first group and for the same reason. The rule
  // below separates what runs a body of tests from what asks a question
  // about the repository — different things, even though both are `test`.
  const MenuItem(
    'Coverage (Unit + Integration)',
    'coverage',
    description:
        'Measures one package, builds the HTML report and opens it. Needs '
        'genhtml, which ships with lcov. The threshold itself is checked by '
        'Verify, not here.',
  ),
  for (final kind in _testKinds)
    MenuItem(kind.label, 'test ${kind.name}', description: kind.description),
  // A command rather than a fourth kind: the others run a folder of Dart
  // files, and this opens the app on a device and walks it through a flow.
  // Same section, because it is where someone looks for it.
  for (final command in _commands)
    if (command.name == 'e2e')
      MenuItem(command.label, command.name, description: command.description),
  const MenuItem.rule(),
  const MenuItem(
    'Architecture',
    'test $arch',
    description:
        'Reads every pubspec and asserts the layer graph: each package may '
        'depend only on the ones below it, and exactly one knows Flutter '
        'exists. The fastest answer to "did I just break a boundary".',
  ),
  const MenuItem(
    'Rules',
    'rules',
    description:
        'The naming and shape rules the analyzer cannot see — an '
        'implementation that says so, a capability as a complete folder, a '
        'repository that holds no capability. Architecture answers who may '
        'depend on whom; this answers how things are named and shaped.',
  ),
  const MenuItem(
    'CLI',
    'test $cli',
    description:
        'Drives `tom` itself — every command --help lists, the exit codes a '
        'script depends on, and the pure functions behind them. Black box: '
        'the CLI has no pubspec, so its tests live on the workspace side.',
  ),
  const MenuItem(
    'Diff — only what changed on this branch',
    'test $changed',
    description:
        'Runs only the tests this branch\'s diff maps to, by filename: a '
        'changed lib/foo.dart runs foo_test.dart. Proves the part you touched '
        'is green — the full run is what proves the workspace is.',
  ),
  const MenuItem(
    'Last — the 10 files edited most recently',
    'test $last',
    description:
        'Same mapping as Diff, over what the filesystem says you touched last '
        'rather than what git says differs from main. The one that still '
        'answers "run what I was just working on" on a branch whose diff has '
        'grown too large to mean that.',
  ),
  const MenuItem(
    'Last coverage',
    'coverage $last',
    description:
        'Runs the test the file you just changed maps to, and reports the '
        'coverage of that file — here, in the terminal. Seconds, because the '
        'rest of the suite never runs.',
  ),
  const MenuItem.rule(),
  const MenuItem.back(
    label: Layout.quitLabel,
    description: 'Leaves the CLI and restores the terminal as it was.',
  ),
];

/// The `Setup` section's rows, alphabetically.
///
/// By label rather than by command name, which is the one section where the
/// two disagree: `setup` reads as `Pub get` and `updates` as `Check for
/// updates`, so ordering by name would put `FVM` first and produce a list
/// that is alphabetical only to whoever wrote it. Every other group takes the
/// order [_commands] declares, where label and name agree.
///
/// Sorted here rather than stored in order, so relabelling a row cannot leave
/// the section out of order behind it.
List<MenuItem<String>> get _setupRows =>
    [for (final name in _setupGroup) _rowFor(name)]
      ..sort((a, b) => a.label.compareTo(b.label));

/// The root-screen row for the command called [name].
///
/// Read off the command rather than restated, so a row and its `--help` line
/// cannot drift apart. Used by the sections that list their rows in an order
/// of their own instead of taking them in the order [_commands] declares.
MenuItem<String> _rowFor(String name) {
  final command = _commands.firstWhere((command) => command.name == name);
  return MenuItem(
    command.label,
    command.name,
    description: command.description,
  );
}

List<String> _rootFrame({required int columns}) => composeFrame<String>(
  title: _title,
  titleSuffix: _subtitle,
  prompt: _prompt,
  items: _rootItems,
  selected: 0,
  columns: columns,
);

/// Collects the arguments [command] needs, on a screen of its own.
///
/// Returns an empty list for a command that takes none, and `null` when the
/// user backed out — which is a return to the root menu, not a run with
/// defaults filled in behind their back.
/// [carried] is what the chosen row already decided — `Unit` arrives as
/// `test unit`. A command can still ask for the rest.
Future<List<String>?> _promptFor(
  Terminal terminal,
  String command,
  List<String> carried,
) async => switch (command) {
  'build' => await _askPlatform(terminal),
  'clean' => await _askCleanTarget(terminal),
  'codegen' => await _askCodegen(terminal),
  'coverage' => carried.isEmpty ? await _askCoverageTarget(terminal) : carried,
  'e2e' => await _askE2e(terminal, carried),
  'rules' => await _askRule(terminal),
  'test' => await _askTestTarget(terminal, carried),
  _ => carried,
};

/// Asks which rule file to check, with running all of them as the first row.
///
/// A row is a file in `tool/src/rules/`, so a break names what to open, and
/// the description under it is what that file checks — which makes the
/// screen a map of the folder rather than a second list to keep in step
/// with it.
///
/// Each row carries what it last said, the way the scenario list does:
/// "checked since?" is the question this screen is opened to answer, and a
/// tick against an older version is not the same claim as one against this.
Future<List<String>?> _askRule(Terminal terminal) async {
  final results = readRuleResults();
  final chosen = await showMenu<String>(
    terminal,
    title: _title,
    titleSuffix: _subtitle,
    section: 'Rules',
    prompt: 'Which rule file?',
    items: <MenuItem<String>>[
      const MenuItem<String>(
        'All of them',
        '',
        emphasized: true,
        description:
            'Every file below, in one pass, reporting all the breaks rather '
            'than stopping at the first.',
      ),
      const MenuItem<String>.rule(),
      const MenuItem<String>.section('Files'),
      for (final entry in catalogue)
        MenuItem<String>(
          entry.label,
          entry.name,
          detail: describeRuleResult(results[entry.name]),
          // Green for a pass, red for a break, grey for never run: "it
          // passed" and "it ran" are different claims.
          detailColor: switch (results[entry.name]) {
            null => palette.rowDisabled,
            final result when result.passed => palette.ok,
            _ => palette.fail,
          },
          description: entry.description,
        ),
      const MenuItem<String>.rule(),
      const MenuItem<String>.back(),
    ],
  );
  if (chosen == null) return null;
  return chosen.isEmpty ? const <String>[] : <String>[chosen];
}

/// Asks which app to drive, and then what to do with it.
///
/// Two screens, and each asks one thing. The first is only ever *which app*
/// — the environment does not belong here, because a screen that asked
/// which app and also offered two things that are not apps would be asking
/// two questions at once.
///
/// Mobile is listed and disabled for the same reason the build screen lists
/// it: `src/apps/mobile` exists, and a screen that hid it would read as a
/// bug rather than a plan.
Future<List<String>?> _askE2e(Terminal terminal, List<String> carried) async {
  const section = 'End-to-end';
  // Already on an app: go straight back to its scenarios. This is what
  // makes a finished run return to the list it was chosen from.
  if (carried.isNotEmpty) {
    return _askScenario(terminal, section: section);
  }
  final app = await showMenu<String>(
    terminal,
    title: _title,
    titleSuffix: _subtitle,
    section: section,
    prompt: 'Which app?',
    items: <MenuItem<String>>[
      const MenuItem<String>(
        'Desktop',
        'desktop',
        description:
            'Drives the desktop app — the only one that exists today, and '
            'the one the product is.',
      ),
      const MenuItem<String>.disabled(
        'Mobile',
        detail: 'coming soon',
        description:
            'src/apps/mobile is a placeholder in the workspace; there is '
            'nothing to drive yet.',
      ),
      const MenuItem<String>.rule(),
      const MenuItem<String>.back(),
    ],
  );
  if (app == null) return null;
  return _askScenario(terminal, section: section);
}

/// Asks which scenario to run, or what to do with the environment.
///
/// Every scenario the source declares, grouped as it declares itself, each
/// row carrying when it last passed and on which version of the app — which
/// is what the list is read for: *has this been checked since?*
///
/// A scenario that has never run is listed without a date rather than
/// hidden. Absence is information.
///
/// The environment lives at the bottom of this screen and not the one
/// before it: preparing it only matters once someone is about to run
/// something, and this is where they are when that becomes true. The header
/// says whether it is there, so a row that would fail for want of it says
/// so before it is chosen.
Future<List<String>?> _askScenario(
  Terminal terminal, {
  required String section,
}) async {
  final scenarios = discoverScenarios();
  if (scenarios.isEmpty) {
    stdout.writeln('No scenarios under $scenarioDirectory yet.');
    return null;
  }
  final results = readResults();
  final prepared = environmentIsPrepared();
  final groups = <String, List<Scenario>>{};
  for (final scenario in scenarios) {
    groups.putIfAbsent(scenario.group, () => <Scenario>[]).add(scenario);
  }

  // Nothing that reads the environment can run without one, so those rows
  // are shown and not selectable rather than hidden — the list is also how
  // someone learns what exists.
  final blocked = scenarios.where((s) => s.needsEnvironment).length;
  final runnable = !prepared ? scenarios.length - blocked : scenarios.length;

  final items = <MenuItem<String>>[
    if (runnable == 0)
      MenuItem<String>.disabled(
        'All of them',
        detail: blockedNote,
        detailColor: palette.rowDisabled,
        description:
            'Nothing can run until the environment is built — Prepare, at '
            'the bottom of this screen.',
      )
    else
      MenuItem<String>(
        'All of them',
        _allTargets,
        emphasized: true,
        description: prepared
            ? 'Runs every scenario, one at a time — each launches the app, '
                  'and the next cannot start while the last window is still '
                  'there.'
            : 'Runs the $runnable that do not need the environment.',
      ),
    const MenuItem<String>.rule(),
  ];
  for (final entry in groups.entries) {
    items.add(MenuItem<String>.section(entry.key));
    for (final scenario in entry.value) {
      final result = results[scenario.name];
      final result_ = result == null
          ? 'never run'
          : '${result.passed ? '\u2713' : '\u2718'} '
                '${describeWhen(result.when)} \u00b7 v${result.version} '
                '\u00b7 ${describeElapsed(result.elapsed)}';
      // Green for a pass, red for a failure, grey for everything else. The
      // colour is the first thing read on this screen, and "it passed" and
      // "it ran" are different claims.
      final resultColor = result == null
          ? palette.rowDisabled
          : (result.passed ? palette.ok : palette.fail);
      if (scenario.needsEnvironment && !prepared) {
        items.add(
          MenuItem<String>.disabled(
            scenario.name,
            detail: blockedNote,
            detailColor: palette.rowDisabled,
            description:
                '${scenario.describe} — it reads the prepared folders, so '
                'build them first with Prepare.',
          ),
        );
      } else {
        items.add(
          MenuItem<String>(
            scenario.name,
            scenario.name,
            detail: result_,
            detailColor: resultColor,
            description: scenario.describe,
          ),
        );
      }
    }
  }
  items
    ..add(const MenuItem<String>.rule())
    ..add(
      MenuItem<String>.section(
        prepared
            ? 'Environment'
            : 'Environment \u00b7 not built \u2014 $blocked '
                  '${blocked == 1 ? 'scenario needs' : 'scenarios need'} it',
      ),
    )
    ..add(
      MenuItem<String>(
        'Prepare',
        'prepare',
        emphasized: !prepared,
        detail: prepared ? '\u2713 ready' : 'not built',
        detailColor: prepared ? palette.ok : palette.rowDisabled,
        description:
            'Builds the folders the scenarios run against: real repositories '
            'with real markdown in them. Destructive — it throws away what '
            'was there, so a run cannot inherit the last one.',
      ),
    )
    ..add(
      const MenuItem<String>(
        'Remove',
        'clean',
        description:
            'Deletes the prepared folders. What ran, and when, is kept — '
            'that is a record, not test data.',
      ),
    )
    ..add(const MenuItem<String>.rule())
    ..add(const MenuItem<String>.back());

  final chosen = await showMenu<String>(
    terminal,
    title: _title,
    titleSuffix: _subtitle,
    section: section,
    prompt: 'Which one?',
    items: items,
  );
  return chosen == null ? null : <String>[chosen];
}

/// Asks which package to clear.
///
/// The same package screen as codegen's and coverage's, because it is the
/// same question. `All of them` leads it, as it does there, and here it is
/// also what most runs want: a clean is usually reached for precisely when
/// nothing on disk is trusted any more.
Future<List<String>?> _askCleanTarget(Terminal terminal) async {
  final target = await _askPackage(terminal, section: 'Clean');
  return target == null ? null : [target];
}

/// Asks which package to measure and report on.
///
/// Coverage is a property of one package's `lib/`, so the same package screen
/// applies — and unlike the test kinds, there is nothing above it to choose
/// first.
Future<List<String>?> _askCoverageTarget(Terminal terminal) async {
  final target = await _askPackage(terminal, section: 'Coverage');
  return target == null ? null : [target];
}

/// Asks which package to run a kind of test over.
///
/// Same screen as codegen's, because it is the same question: the kind was
/// already chosen on the root screen, and what is left is scope.
///
Future<List<String>?> _askTestTarget(
  Terminal terminal,
  List<String> carried,
) async {
  // The whole suite and the architecture assertions have nothing to narrow.
  if (!_hasOwnScreen('test', carried)) return carried;

  final kind = _testKinds.firstWhere((k) => k.name == carried.first);
  final section = 'Tests ${Layout.crumbSeparator} ${kind.label}';

  // Every kind left is split per package. The one that was not — end to
  // end — is a command of its own now, with two screens of its own.
  final target = await _askPackage(terminal, section: section);
  return target == null ? null : [kind.name, target];
}

/// Asks how thoroughly to regenerate, then over which package.
///
/// Two screens rather than one list of sixteen combinations: the questions
/// are independent, and backing out of the second returns to the first rather
/// than to the root, which is what makes a wrong turn cost one keystroke.
///
/// `Hard` carries its consequence in the annotation rather than behind a
/// confirmation prompt: it is destructive only to files that are generated by
/// definition, so the cost of picking it by accident is time, not work.
Future<List<String>?> _askCodegen(Terminal terminal) async {
  while (true) {
    final mode = await showMenu<String>(
      terminal,
      title: _title,
      titleSuffix: _subtitle,
      section: 'Codegen',
      prompt: 'How much to regenerate?',
      items: [
        for (final option in _codegenModes)
          MenuItem(
            option.label,
            option.name,
            detail: option.caveat,
            description: option.description,
          ),
        const MenuItem.rule(),
        const MenuItem.back(description: _backDescription),
      ],
    );
    if (mode == null) return null;

    final target = await _askPackage(
      terminal,
      section:
          'Codegen ${Layout.crumbSeparator} '
          '${_codegenModes.firstWhere((m) => m.name == mode).label}',
    );
    if (target == null) continue;

    return [mode, target];
  }
}

/// Asks which package to work on, with the whole workspace first.
///
/// `All of them` leads because it is what most runs want; the individual rows
/// are for the case where the whole point is not waiting on the other seven.
/// Grouped into packages and apps because that split decides where a target
/// resolves — `src/packages/` or `src/apps/` — not merely how it reads.
Future<String?> _askPackage(Terminal terminal, {required String section}) =>
    showMenu(
      terminal,
      title: _title,
      titleSuffix: _subtitle,
      section: section,
      prompt: 'Which package?',
      items: [
        const MenuItem(
          'All of them',
          _allTargets,
          description:
              'Every package and both apps, in dependency order — what the '
              'command does when nothing narrows it.',
        ),
        const MenuItem.rule(),
        const MenuItem.section('Packages'),
        for (final target in allTargets)
          if (!apps.contains(target))
            MenuItem(
              _labelFor(target),
              target,
              description: _packageDescriptions[target],
            ),
        const MenuItem.rule(),
        const MenuItem.section('Apps'),
        for (final target in allTargets)
          if (apps.contains(target))
            MenuItem(
              _labelFor(target),
              target,
              description: _packageDescriptions[target],
            ),
        const MenuItem.rule(),
        const MenuItem.back(description: _backDescription),
      ],
    );

/// What `← Back` says in the footer, on every screen that has one.
const _backDescription =
    'Returns to the previous screen without running anything. Esc and q do '
    'the same.';

/// The argument that stands for the whole workspace.
const _allTargets = 'all';

/// A package name as the menu shows it: capitalized, except where the package
/// spells itself.
String _labelFor(String target) =>
    '${target[0].toUpperCase()}${target.substring(1)}';

/// What each package is, for the footer.
///
/// Taken from `docs/technical/layers.md`, which is the source of truth for
/// the graph — a row that described a layer differently from the document
/// enforcing it would be worse than a row that said nothing.
const _packageDescriptions = <String, String>{
  'core':
      'Result, the AppFailure marker and the ports every layer needs. '
      'Mechanism, never product vocabulary — nothing above it can be '
      'described by what is in here.',
  'domain':
      'Entities, value objects, the sealed failure hierarchies and the '
      'repository contracts. Depends on core alone, and on no framework.',
  'application':
      'The use cases: one per thing the product does, each with its own '
      'inline try/catch and an exhaustive switch over the failures it can '
      'produce.',
  'infra':
      'Capability contracts and their implementations, one folder per '
      'capability with the implementation named after how it is done — '
      'git_client/dart_io, filesystem/dart_io.',
  'data':
      'Parsers and repository implementations. Text crosses the capability '
      'contracts; this is where it becomes a domain type.',
  'presentation':
      'The space session and the notifiers. Pure Dart, deliberately — it '
      'cannot reach a widget, and the architecture test is what proves it.',
  'desktop':
      'The composition root and the widgets. The only package in the '
      'workspace whose pubspec knows Flutter exists.',
  'mobile': 'The mobile app. A placeholder in the workspace for now.',
};

/// Asks which platform to build for.
///
/// The host is drawn brighter and annotated, because it is the one row that
/// needs no toolchain set up first — everything else is a cross build.
///
/// Mobile is listed and disabled rather than omitted: `src/apps/mobile` is a
/// real package in the workspace, so a build screen that showed only desktop
/// would read as a bug rather than as a plan.
Future<List<String>?> _askPlatform(Terminal terminal) async {
  final host = hostPlatform;
  final items = <MenuItem<String>>[
    const MenuItem.section('Desktop'),
    for (final platform in _platforms)
      MenuItem(
        platform.label,
        platform.name,
        emphasized: platform.name == host,
        detail: platform.name == host ? 'this machine' : null,
        description: platform.name == host
            ? 'Builds a release bundle for ${platform.label}. This is the '
                  'host, so it needs no toolchain set up beyond Flutter.'
            : 'Builds a release bundle for ${platform.label} — a cross build '
                  'from ${Platform.operatingSystem}, which needs that '
                  "platform's toolchain available.",
      ),
    const MenuItem.rule(),
    const MenuItem.section('Mobile'),
    for (final platform in _mobilePlatforms)
      MenuItem.disabled(
        platform.label,
        detail: 'coming soon',
        description:
            'src/apps/mobile exists in the workspace but builds nothing yet. '
            'Listed so its absence is a plan rather than a mystery.',
      ),
    const MenuItem.rule(),
    const MenuItem.back(description: _backDescription),
  ];

  final chosen = await showMenu<String>(
    terminal,
    title: _title,
    titleSuffix: _subtitle,
    section: 'Build',
    prompt: 'Which platform?',
    items: items,
    initialIndex: items.indexWhere((item) => item.value == host),
  );
  return chosen == null ? null : [chosen];
}

/// Runs [name] with [rest], or explains why it cannot.
///
/// Every command does its own work here. Nothing shells out to `make`: the
/// Makefile is a thin face over this, not the other way round, so a CLI that
/// called it would be a circle.
Future<int> _dispatch(String name, List<String> rest) async {
  final command = _commands.where((c) => c.name == name).firstOrNull;
  if (command == null) {
    stderr.writeln('tom: unknown command "$name"');
    _printUsage();
    return 64;
  }

  // Before anything runs. `_targetsFrom` ignores what it does not recognise,
  // which is right for the modes and kinds travelling in the same list and
  // wrong for everything else: it turns a typo into "none named", and none
  // named means all of them. `tom clean cor` cleaned all eight packages.
  final unrecognized = _unrecognized(command.name, rest);
  if (unrecognized.isNotEmpty) {
    stderr.writeln(
      'tom: ${command.name} does not take "${unrecognized.first}"',
    );
    return 66; // EX_NOINPUT
  }

  return switch (command.name) {
    'analyze' => await runAnalyze(),
    'build' => await runBuild(platform: _firstOf(rest, _platformNames)),
    'clean' => await runClean(targets: _targetsFrom(rest)),
    'doctor' => await runDoctor(),
    'updates' => await runUpdates(),
    'format' => await runFormat(),
    'fvm' => await runFvm(),
    'setup' => await runSetup(),
    'codegen' => await runCodegen(
      hard: rest.contains('hard'),
      targets: _targetsFrom(rest),
    ),
    'coverage' => switch (rest) {
      // Narrowed to what was just touched, which is the case where the point
      // is the suite that does not run.
      _ when rest.contains(last) => await runLastCoverage(
        count: _countFrom(rest),
      ),
      _ when rest.contains(changed) => await runDiffCoverage(
        base: _baseFrom(rest),
      ),
      _ => await runCoverageReport(targets: _targetsFrom(rest)),
    },
    'coverage-gate' => await runCoverageGate(threshold: _thresholdFrom(rest)),
    'codegen-gate' => await runCodegenGate(),
    'run' => await runApp(device: _firstOf(rest, _platformNames)),
    'test' => switch (rest) {
      _ when rest.contains(arch) => await runArchTests(),
      _ when rest.contains(cli) => await runCliTests(),
      _ when rest.contains(last) => await runLastTests(count: _countFrom(rest)),
      _ when rest.contains(changed) => await runChangedTests(
        base: _baseFrom(rest) ?? 'main',
      ),
      _ => await runTests(
        kind: _firstOf(rest, testKinds),
        targets: _targetsFrom(rest),
      ),
    },
    'e2e' => switch (rest) {
      _ when rest.contains('prepare') => await runE2ePrepare(),
      _ when rest.contains('clean') => await runE2eClean(),
      _ when rest.contains('fixtures') => await runE2eFixtures(),
      _ when rest.contains('list') => await runE2eList(),
      _ when rest.contains(_allTargets) => await runAllScenarios(),
      [] => await runE2eList(),
      // Anything else is a scenario name, in prose.
      _ => await runNamedScenario(rest.join(' ')),
    },
    'rules' => await runRules(rest.isEmpty ? null : rest.first),
    'verify' => await runVerify(),
    _ => 64,
  };
}

/// The arguments [command] does not understand.
///
/// Every command that takes any reads them out of one flat list, so the list
/// is the only place that can tell a word it was given from a word it knows.
List<String> _unrecognized(String command, List<String> arguments) {
  // `e2e` is the exception, and it has to be: a scenario is named in prose
  // — "Opens a docs folder inside a repository" — so there is no set of
  // words to check it against. It validates the name itself, against what
  // the source declares, and lists them all when it does not match.
  if (command == 'e2e') return const <String>[];
  final words = _wordsFor(command);
  final flags = _flagsFor(command);
  return [
    for (final argument in arguments)
      if (argument.startsWith('--')
          ? !flags.any(argument.startsWith)
          : !words.contains(argument))
        argument,
  ];
}

/// The bare words [command] accepts.
Set<String> _wordsFor(String command) => switch (command) {
  'build' || 'run' => const {..._platformNames},
  // The catalogue is the list, so a rule added there is accepted here
  // without a second copy to forget.
  'rules' => <String>{for (final entry in catalogue) entry.name},
  'clean' => const {_allTargets, ...allTargets},
  'coverage' => const {_allTargets, ...allTargets, changed, last},
  'e2e' => const {_allTargets, 'prepare', 'clean', 'list', 'fixtures'},
  'codegen' => const {_allTargets, ...allTargets, ..._codegenModeNames},
  'test' => const {
    _allTargets,
    ...allTargets,
    ...testKinds,
    arch,
    cli,
    changed,
    last,
  },
  _ => const {},
};

/// The flags [command] reads, by prefix — each one is `--name=value`.
Set<String> _flagsFor(String command) => switch (command) {
  'test' || 'coverage' => const {'--base=', '--count='},
  'coverage-gate' => const {'--threshold='},
  _ => const {},
};

/// The packages named in [rest], or all of them.
///
/// Anything that is not a known package is ignored rather than rejected: the
/// modes and kinds travel in the same argument list, and `all` is spelled out
/// precisely so it lands here as "none named".
List<String> _targetsFrom(List<String> rest) {
  final named = rest.where(allTargets.contains).toList();
  return named.isEmpty ? allTargets : named;
}

/// The `--base=REF` an argument list carries, if any.
///
/// A flag rather than a bare argument: a git ref can be spelled anything at
/// all, so a positional one would be indistinguishable from a typo'd package
/// name.
String? _baseFrom(List<String> arguments) {
  const flag = '--base=';
  final argument = arguments.where((a) => a.startsWith(flag)).firstOrNull;
  return argument?.substring(flag.length);
}

/// The `--count=N` an argument list carries, if any.
///
/// A flag rather than a bare argument, for the same reason as `--base`: a
/// positional number in the same list as the kinds and the package names
/// would be indistinguishable from a typo.
int? _countFrom(List<String> arguments) {
  const flag = '--count=';
  final argument = arguments.where((a) => a.startsWith(flag)).firstOrNull;
  return argument == null
      ? null
      : int.tryParse(argument.substring(flag.length));
}

/// The `--threshold=N` an argument list carries, if any.
int? _thresholdFrom(List<String> arguments) {
  const flag = '--threshold=';
  final argument = arguments.where((a) => a.startsWith(flag)).firstOrNull;
  return argument == null
      ? null
      : int.tryParse(argument.substring(flag.length));
}

/// The first argument that is one of [known], or `null`.
String? _firstOf(List<String> arguments, Iterable<String> known) =>
    arguments.where(known.contains).firstOrNull;

/// The desktop platform names, as both `build` and `run` accept them.
const _platformNames = ['macos', 'linux', 'windows'];

/// How `codegen` can be run, as the command line spells it.
const _codegenModeNames = ['normal', 'hard'];

void _printUsage() {
  stdout
    ..writeln()
    ..writeln('  $_title ${Layout.titleSeparator} $_subtitle')
    ..writeln()
    ..writeln('  dart run tool/tom.dart           Open the menu')
    ..writeln('  dart run tool/tom.dart <command> Run it directly')
    ..writeln();
  // Width from the longest name rather than a constant, so adding a command
  // cannot quietly break the column.
  final width = _commands
      .map((c) => c.name.length)
      .reduce((a, b) => a > b ? a : b);
  for (final command in _commands) {
    stdout.writeln('    ${command.name.padRight(width)}  ${command.summary}');
  }
  stdout.writeln();
}

final class _Command {
  const _Command(
    this.name,
    this.summary, {
    this.hidden = false,
    this.description,
    String? label,
  }) : _label = label;

  final String? _label;

  /// What the footer says while this command's row is selected.
  ///
  /// Longer than [summary], which has one line in `--help` to work with.
  /// Hidden commands have none: they are never a row.
  final String? description;

  /// Kept out of the root screen's rows, but still a command: reachable by
  /// name, listed in `--help`.
  final bool hidden;

  /// What the command is called on the command line: lowercase, one word,
  /// the token a user types and a script commits to.
  final String name;

  /// What the menu reads as: [name] capitalized, unless the command spells
  /// itself differently.
  ///
  /// Derived rather than stored so the two cannot drift — a row that says
  /// `Verify` always runs `verify`. The override exists for names that are
  /// not words, like `FVM`.
  String get label => _label ?? '${name[0].toUpperCase()}${name.substring(1)}';

  final String summary;
}

/// A desktop platform `build` and `run` can target.
final class _Platform {
  const _Platform(this.name, this.label);

  /// The argument, which is also the Flutter device name.
  final String name;

  /// How the platform spells itself — `macOS`, not `Macos`.
  final String label;
}

/// One way of running `codegen`.
final class _CodegenMode {
  const _CodegenMode(
    this.name,
    this.label,
    this.caveat, {
    required this.description,
  });

  final String name;
  final String label;

  /// What the footer says while this row is selected.
  final String description;

  /// What the row has to warn about, or `null` when it has nothing to say.
  /// Shown as the row's right-hand annotation.
  final String? caveat;
}

/// A kind of test, matching a folder under each package's `test/`.
final class _TestKind {
  const _TestKind(this.name, this.label, {required this.description});

  final String name;

  /// What the footer says while this row is selected.
  final String description;

  /// What the row says.
  ///
  /// Every kind left is split per package — they belong to one and live
  /// under its `test/`. The one that was not, end to end, became a command
  /// of its own: it opens the app on a device rather than running a folder.
  final String label;
}
