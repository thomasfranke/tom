// What end-to-end scenarios exist, and what happened last time each ran.
library;

import 'dart:convert';
import 'dart:io';

import '../repo.dart';

/// Where the scenarios live: inside the desktop app, because an end-to-end
/// run happens in the app's own native runner with its entitlements and its
/// Podfile, and a second runner would drift.
const scenarioDirectory = 'src/apps/desktop/integration_test';

/// The folder under [scenarioDirectory] that mirrors the CLI's menus: one
/// folder per group, a subfolder per submenu, one file per scenario or a few
/// of one menu. `fixtures/` and `support/` stay beside it.
const scenarioRoot = 'e2e';

/// The most entries any one menu may hold, submenus and scenarios alike.
const menuLimit = 25;

/// A menu's own words as a folder or file name: `Pull request` is
/// `pull_request`.
String menuSlug(String menu) => menu
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

/// One scenario the CLI can list and run.
final class Scenario {
  const Scenario({
    required this.name,
    required this.group,
    required this.describe,
    required this.file,
    required this.needsEnvironment,
    this.survey,
    this.submenu,
  });

  /// The submenu of its group it is listed under, or null for a group whose
  /// scenarios are listed directly.
  final String? submenu;

  /// The folder, relative to the app's `integration_test/`, its file must
  /// sit in: the menu it is listed under, in the menu's own words.
  String get folder => <String>[
    scenarioRoot,
    menuSlug(group),
    if (submenu != null) menuSlug(submenu!),
  ].join('/');

  /// The survey id a planned scenario answers (`E-A7`, `G-R02`…); null for
  /// one that is written. A scenario with a survey id is **planned**: its
  /// file holds data and no body, so it is listed and never run.
  final String? survey;

  /// Whether this is a plan: counted and shown, not selectable, not run.
  bool get isPlanned => survey != null;

  /// What it is called — the string in the source, and the key a result is
  /// stored under.
  final String name;

  /// The heading it is listed under.
  final String group;

  /// What it is for, shown while it runs.
  final String describe;

  /// The file that declares it, relative to the app package.
  final String file;

  /// Whether it reads the prepared environment, and so cannot run without one.
  ///
  /// Read from the source rather than flagged: a scenario needs the
  /// environment exactly when its file asks for a fixture.
  final bool needsEnvironment;
}

/// How a scenario's run ended.
enum ScenarioOutcome {
  passed('passed', '✓'),
  failed('failed', '✘'),
  cancelled('cancelled', '✘ cancelled ·'),
  didNotRun('did-not-run', '✘ did not run ·');

  const ScenarioOutcome(this.label, this.mark);

  /// The word a file of the run is named with, and the one kept on record.
  final String label;

  /// What a row of the list opens with.
  final String mark;

  /// The outcome of a process that answered [exitCode] after a scenario
  /// declared [declared] steps.
  ///
  /// **No steps declared is never a pass, whatever the code**: the app did
  /// not start — the build failed, or the run was killed — and a killed
  /// `flutter test` has been seen answering 0. Negative is a signal.
  static ScenarioOutcome of({required int exitCode, required int declared}) =>
      switch (exitCode) {
        < 0 => cancelled,
        _ when declared == 0 => didNotRun,
        0 => passed,
        _ => failed,
      };

  /// What the CLI exits with after a run that ended this way and whose
  /// process answered [exitCode]: the process's own code, except that a
  /// run which did not pass never answers 0.
  int exitCodeAfter(int exitCode) => switch (this) {
    passed => 0,
    _ => exitCode == 0 ? 1 : exitCode,
  };

  /// What [value] names, or null — a record written before outcomes were.
  static ScenarioOutcome? named(Object? value) {
    for (final outcome in values) {
      if (outcome.label == value) return outcome;
    }
    return null;
  }
}

/// What a finished scenario says in a log, where nothing is repainted.
///
/// `0/0 steps` alone reads as a count, so a run that never started says so
/// in words beside it.
String scenarioLine(
  String name,
  ScenarioOutcome outcome, {
  required int done,
  required int total,
}) => switch (outcome) {
  ScenarioOutcome.passed => '  ✓ $name — $done/$total steps',
  ScenarioOutcome.didNotRun =>
    '  ✘ $name — $done/$total steps · did not run: '
        'the build failed or the run was killed',
  ScenarioOutcome.cancelled => '  ✘ $name — $done/$total steps · cancelled',
  ScenarioOutcome.failed => '  ✘ $name — $done/$total steps',
};

/// What happened the last time a scenario ran.
final class ScenarioResult {
  const ScenarioResult({
    required this.outcome,
    required this.when,
    required this.version,
    required this.steps,
    required this.elapsed,
  });

  /// How it ended.
  final ScenarioOutcome outcome;

  /// Whether it ran to its end and every step held.
  bool get passed => outcome == ScenarioOutcome.passed;

  /// When it ran, in UTC.
  final DateTime when;

  /// The app version that ran it: a green tick against an old version is not
  /// the same claim as one against this.
  final String version;

  /// How many steps it got through.
  final int steps;

  /// How long it took.
  final Duration elapsed;

  Map<String, Object?> toJson() => <String, Object?>{
    'passed': passed,
    'outcome': outcome.label,
    'when': when.toIso8601String(),
    'version': version,
    'steps': steps,
    'elapsedMs': elapsed.inMilliseconds,
  };

  /// The record [value] holds, or null when it is not one.
  ///
  /// A record from before outcomes were kept says only `passed` and a count,
  /// and a pass with no steps among them is the killed run that was written
  /// down green — read here as what it was.
  static ScenarioResult? fromJson(Object? value) {
    if (value is! Map<String, Object?>) return null;
    final when = DateTime.tryParse(value['when'] as String? ?? '');
    if (when == null) return null;
    final steps = value['steps'] as int? ?? 0;
    final passed = value['passed'] as bool? ?? false;
    return ScenarioResult(
      outcome:
          ScenarioOutcome.named(value['outcome']) ??
          switch (passed) {
            true when steps == 0 => ScenarioOutcome.didNotRun,
            true => ScenarioOutcome.passed,
            false => ScenarioOutcome.failed,
          },
      when: when.toUtc(),
      version: value['version'] as String? ?? '?',
      steps: steps,
      elapsed: Duration(milliseconds: value['elapsedMs'] as int? ?? 0),
    );
  }
}

/// The headings the menu lists, in the order somebody walks through the app.
///
/// Declared rather than discovered, so the order is a decision; a group a
/// scenario names but this list does not is listed last rather than hidden,
/// so a typo is visible.
const scenarioGroups = <String>[
  'Diff',
  'Editor',
  'Git',
  'Home',
  'Search',
  'Workspace',
];

/// The scenarios by group, in [scenarioGroups]' order; an empty group is
/// dropped and an undeclared one lands at the end.
Map<String, List<Scenario>> scenariosByGroup(List<Scenario> scenarios) {
  final groups = <String, List<Scenario>>{
    for (final heading in scenarioGroups) heading: <Scenario>[],
  };
  for (final scenario in scenarios) {
    groups.putIfAbsent(scenario.group, () => <Scenario>[]).add(scenario);
  }
  groups.removeWhere((_, scenarios) => scenarios.isEmpty);
  return groups;
}

/// A group's scenarios by submenu, alphabetical; empty for a group whose
/// scenarios are listed directly.
Map<String, List<Scenario>> scenariosBySubmenu(List<Scenario> group) {
  final names = <String>{
    for (final scenario in group)
      if (scenario.submenu != null) scenario.submenu!,
  }.toList()..sort();
  return <String, List<Scenario>>{
    for (final name in names)
      name: <Scenario>[
        for (final scenario in group)
          if (scenario.submenu == name) scenario,
      ],
  };
}

/// Every scenario declared under [scenarioDirectory], sorted by name.
///
/// Read from the source, since a registry kept beside `scenario('…')` would
/// be wrong the first time somebody forgot it.
///
/// The ones still to be written follow, from the `*_planned.dart` files
/// (`plannedScenario('…', survey: '…')`): listed after every written one, so
/// the maintainer sees what is missing. [includePlanned] false is for what
/// has to run.
///
/// [repository] is the repository root to read, for a caller that is not
/// started from the repository's own script (a test); null finds it.
List<Scenario> discoverScenarios({
  bool includePlanned = true,
  Directory? repository,
}) {
  final base = (repository ?? repoRoot()).path;
  final written = _discoverWritten(base);
  if (!includePlanned) return written;
  return <Scenario>[...written, ..._discoverPlanned(base)];
}

/// How many scenarios of [all] are written, and how many only planned.
({int written, int planned}) countScenarios(List<Scenario> all) => (
  written: all.where((s) => !s.isPlanned).length,
  planned: all.where((s) => s.isPlanned).length,
);

/// `62 written · 140 planned`, the header of the menu and the list.
String describeCounts(({int written, int planned}) counts) =>
    '${counts.written} written · ${counts.planned} planned';

/// What running a plan says: it is not written, and which survey item it
/// answers.
String plannedRefusal(Scenario scenario) =>
    'planned — not written yet (${scenario.survey})';

/// The exit code of asking to run a plan: a usage error that is not 64, so a
/// script can tell "no such scenario" from "not written yet".
const plannedExitCode = 65;

/// The files under [scenarioRoot] whose names end in [suffix], sorted by
/// path, as paths relative to [scenarioDirectory].
List<File> _filesEndingIn(String base, String suffix) {
  final directory = Directory('$base/$scenarioDirectory');
  final root = Directory('${directory.path}/$scenarioRoot');
  if (!root.existsSync()) return const [];
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith(suffix))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

/// [file]'s path relative to [scenarioDirectory].
String _relativeToScenarios(String base, File file) {
  final prefix = '$base/$scenarioDirectory/';
  return file.path.substring(prefix.length);
}

/// Plans live in `*_planned.dart` files beside the written ones: data, one
/// call each, never a test.
List<Scenario> _discoverPlanned(String base) {
  final found = <Scenario>[];
  for (final file in _filesEndingIn(base, '_planned.dart')) {
    final source = file.readAsStringSync();
    for (final match in _plannedDeclaration.allMatches(source)) {
      found.add(
        Scenario(
          name: match.group(1)!,
          group:
              _valueOf(_group, source, match.start, _plannedDeclaration) ??
              'Home',
          submenu: _valueOf(_submenu, source, match.start, _plannedDeclaration),
          describe:
              _valueOf(_describe, source, match.start, _plannedDeclaration) ??
              '',
          file: _relativeToScenarios(base, file),
          needsEnvironment: false,
          survey:
              _valueOf(_survey, source, match.start, _plannedDeclaration) ??
              '?',
        ),
      );
    }
  }
  return found..sort((a, b) => a.name.compareTo(b.name));
}

/// `plannedScenario('The name'`.
final _plannedDeclaration = RegExp(
  r"""\bplannedScenario\(\s*'([^']+)'""",
  multiLine: true,
);

final _survey = RegExp(r"""survey:\s*'([^']+)'""");

List<Scenario> _discoverWritten(String base) {
  final found = <Scenario>[];
  for (final file in _filesEndingIn(base, '_test.dart')) {
    final source = file.readAsStringSync();
    final needsEnvironment = source.contains('E2eFixtures');
    for (final match in _declaration.allMatches(source)) {
      found.add(
        Scenario(
          name: match.group(1)!,
          group: _valueOf(_group, source, match.start) ?? 'Home',
          submenu: _valueOf(_submenu, source, match.start),
          describe: _valueOf(_describe, source, match.start) ?? '',
          file: _relativeToScenarios(base, file),
          needsEnvironment: needsEnvironment,
        ),
      );
    }
  }
  return found..sort((a, b) => a.name.compareTo(b.name));
}

/// `scenario('The name'`, which is how one is declared.
final _declaration = RegExp(r"""\bscenario\(\s*'([^']+)'""", multiLine: true);

/// The named argument [pattern], in the call that starts at [from].
///
/// Bounded to the next declaration so a scenario cannot read the group of
/// the one after it.
String? _valueOf(
  RegExp pattern,
  String source,
  int from, [
  RegExp? declaration,
]) {
  final next = (declaration ?? _declaration).allMatches(source, from + 1);
  final end = next.isEmpty ? source.length : next.first.start;
  final match = pattern.firstMatch(source.substring(from, end));
  return match?.group(1);
}

final _group = RegExp(r"""group:\s*'([^']+)'""");
final _submenu = RegExp(r"""submenu:\s*'([^']+)'""");
final _describe = RegExp(r"""describe:\s*\n?\s*'([^']*)'""");

/// Where the record of what ran is kept: beside the environment and **not
/// inside it**, because `prepare` throws the environment away by design and
/// this is a record nothing rebuilds.
const resultsFile = '.e2e-results.json';

/// The results of the last run of each scenario, by name.
Map<String, ScenarioResult> readResults() {
  final file = File('${repoRoot().path}/$resultsFile');
  if (!file.existsSync()) return const {};
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, Object?>) return const {};
    return <String, ScenarioResult>{
      for (final entry in decoded.entries)
        if (ScenarioResult.fromJson(entry.value) case final result?)
          entry.key: result,
    };
  } on FormatException {
    // A results file nobody can read is a results file with nothing in it.
    return const {};
  }
}

/// Records what [name] did, keeping every other scenario's result.
void writeResult(String name, ScenarioResult result) {
  final file = File('${repoRoot().path}/$resultsFile');
  final all = <String, Object?>{
    for (final entry in readResults().entries) entry.key: entry.value.toJson(),
    name: result.toJson(),
  };
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(all)}\n',
  );
}

/// The version of the app being tested, from the desktop pubspec: every
/// package moves in lockstep with it.
String appVersion() {
  final file = File('${repoRoot().path}/src/apps/desktop/pubspec.yaml');
  final match = RegExp(
    r'^version:\s*(\S+)',
    multiLine: true,
  ).firstMatch(file.readAsStringSync());
  return match?.group(1) ?? '?';
}

/// What a row says when it cannot be run — words and no glyph, because
/// "blocked" is not "failed" and a third mark would compete with ✓ and ✘.
const blockedNote = 'needs the environment';

/// `01:23`, the way a stopwatch reads, measuring the whole wait from the
/// moment the row was chosen: the build, the app opening and the flow, since
/// Flutter compiling is part of what a run costs.
String describeElapsed(Duration elapsed) =>
    '${elapsed.inMinutes.toString().padLeft(2, '0')}:'
    '${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

/// `today · 2026-09-21`: the relative half answers "has anyone checked this
/// recently", the absolute half is what compares to a release.
///
/// The relative word comes first and is padded to [relativeWidth] (see
/// [relativeWidthOf]), so the date, version and duration after it line up in
/// columns however long `yesterday` and `2 days ago` are.
String describeWhen(DateTime when, {int relativeWidth = 0}) {
  final local = when.toLocal();
  final date = '${local.year}-${_two(local.month)}-${_two(local.day)}';
  return '${relativeWord(when).padRight(relativeWidth)} · $date';
}

/// `today`, `yesterday`, `3 days ago`… how long ago [when] was.
String relativeWord(DateTime when) {
  final days = DateTime.now().difference(when.toLocal()).inDays;
  return switch (days) {
    <= 0 => 'today',
    1 => 'yesterday',
    < 7 => '$days days ago',
    < 14 => 'last week',
    < 60 => '${days ~/ 7} weeks ago',
    _ => '${days ~/ 30} months ago',
  };
}

/// The width of the longest relative word among [results], to pad each to.
int relativeWidthOf(Iterable<ScenarioResult> results) =>
    results.fold(0, (widest, result) {
      final width = relativeWord(result.when).length;
      return width > widest ? width : widest;
    });

String _two(int value) => value.toString().padLeft(2, '0');
