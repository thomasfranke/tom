// What end-to-end scenarios exist, and what happened last time each ran.
library;

import 'dart:convert';
import 'dart:io';

import '../repo.dart';

/// Where the scenarios live.
///
/// Inside the desktop app rather than in a package of their own, because an
/// end-to-end run happens in the app's *own* native runner, with the app's
/// entitlements and its Podfile. A second runner would drift, and the tests
/// would then be proving something about a configuration nobody ships.
const scenarioDirectory = 'src/apps/desktop/integration_test';

/// One scenario the CLI can list and run.
final class Scenario {
  const Scenario({
    required this.name,
    required this.group,
    required this.describe,
    required this.file,
    required this.needsEnvironment,
  });

  /// What it is called — the string in the source, and the key a result is
  /// stored under.
  final String name;

  /// The heading it is listed under.
  final String group;

  /// What it is for, shown while it runs.
  final String describe;

  /// The file that declares it, relative to the app package.
  final String file;

  /// Whether it reads the prepared environment, and so cannot run without
  /// one.
  ///
  /// Read from the source rather than assumed: a scenario needs the
  /// environment exactly when its file asks for a fixture, and a flag
  /// someone had to remember to set would be wrong the first time they
  /// forgot. Today every scenario needs it; the day one does not, this
  /// answers correctly without anyone noticing it had to.
  final bool needsEnvironment;
}

/// What happened the last time a scenario ran.
final class ScenarioResult {
  const ScenarioResult({
    required this.passed,
    required this.when,
    required this.version,
    required this.steps,
    required this.elapsed,
  });

  /// Whether it finished.
  final bool passed;

  /// When it ran, in UTC.
  final DateTime when;

  /// The app version that ran it.
  ///
  /// Stored because a green tick against an old version is not the same
  /// claim as a green tick against this one — and the list is read to
  /// answer "has this been checked since?".
  final String version;

  /// How many steps it got through.
  final int steps;

  /// How long it took.
  final Duration elapsed;

  Map<String, Object?> toJson() => <String, Object?>{
    'passed': passed,
    'when': when.toIso8601String(),
    'version': version,
    'steps': steps,
    'elapsedMs': elapsed.inMilliseconds,
  };

  static ScenarioResult? fromJson(Object? value) {
    if (value is! Map<String, Object?>) return null;
    final when = DateTime.tryParse(value['when'] as String? ?? '');
    if (when == null) return null;
    return ScenarioResult(
      passed: value['passed'] as bool? ?? false,
      when: when.toUtc(),
      version: value['version'] as String? ?? '?',
      steps: value['steps'] as int? ?? 0,
      elapsed: Duration(milliseconds: value['elapsedMs'] as int? ?? 0),
    );
  }
}

/// The headings the menu lists, in the order somebody walks through the app.
///
/// **Declared, not discovered.** Groups used to come out in whatever order
/// the first scenario of each happened to be read in — alphabetical by name
/// — which put `Editor` above `Home` and read as no journey at all.
///
/// A group a scenario names but this list does not is listed last rather
/// than hidden: a typo should be visible, not silently dropped.
const scenarioGroups = <String>[
  'Home',
  'Workspace',
  'Editor',
  'Git — local',
  'Git — branches',
  'Git — history',
  'Git — remote',
];

/// Every scenario declared under [scenarioDirectory], sorted by name.
///
/// Read from the source rather than from a registry someone has to keep up
/// to date: a scenario is declared by calling `scenario('…')`, and a list
/// maintained beside that would be wrong the first time somebody forgot it.
List<Scenario> discoverScenarios() {
  final directory = Directory('${repoRoot().path}/$scenarioDirectory');
  if (!directory.existsSync()) return const [];
  final found = <Scenario>[];
  for (final file in directory.listSync().whereType<File>()) {
    if (!file.path.endsWith('_test.dart')) continue;
    final source = file.readAsStringSync();
    final needsEnvironment = source.contains('E2eFixtures');
    for (final match in _declaration.allMatches(source)) {
      found.add(
        Scenario(
          name: match.group(1)!,
          group: _valueOf(_group, source, match.start) ?? 'Home',
          describe: _valueOf(_describe, source, match.start) ?? '',
          file: file.path.split('/').last,
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
String? _valueOf(RegExp pattern, String source, int from) {
  final next = _declaration.allMatches(source, from + 1);
  final end = next.isEmpty ? source.length : next.first.start;
  final match = pattern.firstMatch(source.substring(from, end));
  return match?.group(1);
}

final _group = RegExp(r"""group:\s*'([^']+)'""");
final _describe = RegExp(r"""describe:\s*\n?\s*'([^']*)'""");

/// Where the record of what ran is kept.
///
/// Beside the environment and **not inside it**. The two have different
/// lifetimes and it cost a history to learn it: `prepare` throws the
/// environment away by design, and a results file living in there went with
/// it — every scenario back to "never run" on a screen that is read to
/// answer *has this been checked?*.
///
/// The environment is disposable test data. This is a record of what
/// happened, and nothing rebuilds it.
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
    // It is a record of what happened, not something anything depends on.
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

/// The version of the app being tested.
///
/// Read from the desktop pubspec, which is the product version: every
/// package moves in lockstep with it, so it is the one number that says
/// what was running.
String appVersion() {
  final file = File('${repoRoot().path}/src/apps/desktop/pubspec.yaml');
  final match = RegExp(
    r'^version:\s*(\S+)',
    multiLine: true,
  ).firstMatch(file.readAsStringSync());
  return match?.group(1) ?? '?';
}

/// What a row says when it cannot be run.
///
/// Words and no glyph. "Blocked" is a different thing from "failed", and a
/// mark of its own would compete with the ✓ and ✘ that carry the result —
/// on a screen where the eye is looking for green, a third symbol is noise.
const blockedNote = 'needs the environment';

/// `01:23`, the way a stopwatch reads.
///
/// **What it measures is the whole wait**, from the moment the row was
/// chosen: the build, the app opening, and the flow itself. That is the
/// number someone is deciding against when they wonder whether to run the
/// suite now or after lunch — the part that is Flutter compiling is still
/// part of what it costs.
String describeElapsed(Duration elapsed) =>
    '${elapsed.inMinutes.toString().padLeft(2, '0')}:'
    '${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

/// `2026-09-21 · today`, or nothing at all.
///
/// The relative half is what the list is actually read for — "has anyone
/// checked this recently" — and the absolute half is what makes it
/// comparable to a release.
String describeWhen(DateTime when) {
  final local = when.toLocal();
  final date = '${local.year}-${_two(local.month)}-${_two(local.day)}';
  final days = DateTime.now().difference(local).inDays;
  final relative = switch (days) {
    <= 0 => 'today',
    1 => 'yesterday',
    < 7 => '$days days ago',
    < 14 => 'last week',
    < 60 => '${days ~/ 7} weeks ago',
    _ => '${days ~/ 30} months ago',
  };
  return '$date · $relative';
}

String _two(int value) => value.toString().padLeft(2, '0');
