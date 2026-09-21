// `tom e2e` — the environment the end-to-end tests are run against.
library;

import 'dart:convert';
import 'dart:io';

import '../repo.dart';
import '../theme/theme.dart';
import 'e2e_catalogue.dart';
import 'e2e_run.dart';
import 'process.dart';

/// Where the prepared environment lives, relative to the repository root.
///
/// Inside the repository and gitignored, rather than in the system temporary
/// directory, for one reason: **you can open it in the app**. An end-to-end
/// failure is read by looking at what the test was looking at, and a path
/// under `/var/folders/...` that is deleted on reboot is not something
/// anyone inspects.
const e2eDirectory = '.e2e';

/// What the tests read to find out what was prepared.
///
/// The CLI builds the environment and the tests assert against it, and they
/// live in different worlds — `tool/` has no pubspec and cannot share a
/// constant with `src/`. A manifest is the seam: one side writes it, the
/// other reads it, and a scenario renamed in one place fails loudly in the
/// other instead of quietly testing nothing.
const manifestFile = 'manifest.json';

/// Where the mock the environment is built from lives.
///
/// **In the repository, committed, and readable as documentation.** The
/// content used to be Dart string constants in this file, which meant the
/// only way to see what a test was looking at was to read the code that
/// wrote it. It is markdown; it belongs on disk as markdown — reviewable in
/// a diff, openable in the app, and editable by whoever is adding a case
/// without touching the CLI at all.
///
/// Beside the scenarios that read it, for the same reason they live in the
/// app rather than in a package of their own: the fixture and the flow
/// through it are one change.
const mockDirectory = 'src/apps/desktop/integration_test/fixtures';

/// One situation the app can be pointed at.
///
/// A *fixture* is a situation on disk; a *scenario* is a flow through the
/// app. Several scenarios share one fixture, and one that needed its own
/// would be describing a situation nobody has.
///
/// Everything but [name] is read from the fixture's `fixture.json`. The
/// folder is the content; the file is what git has and has not seen of it.
final class E2eFixture {
  const E2eFixture({
    required this.name,
    required this.summary,
    required this.description,
    required this.space,
    required this.commit,
    required this.untracked,
    required this.uncommitted,
    required this.outsideTheProject,
  });

  /// Reads the fixture in [directory], whose folder name is its [name].
  factory E2eFixture.read(Directory directory) {
    final name = directory.path.split('/').last;
    final file = File('${directory.path}/$fixtureFile');
    if (!file.existsSync()) {
      throw StateError(
        'tom e2e: $mockDirectory/$name has no $fixtureFile. Every fixture '
        'needs one: it is what says which of its files git has seen.',
      );
    }
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, Object?>) {
      throw StateError('tom e2e: ${file.path} is not a JSON object.');
    }
    return E2eFixture(
      name: name,
      summary: decoded['summary'] as String? ?? name,
      description: decoded['description'] as String? ?? '',
      space: decoded['space'] as String? ?? '',
      commit: decoded['commit'] as String? ?? 'fixture: the first pass',
      untracked: (decoded['untracked'] as List<Object?>? ?? const <Object?>[])
          .cast<String>(),
      uncommitted: <String, String>{
        for (final entry
            in (decoded['uncommitted'] as Map<String, Object?>? ??
                    const <String, Object?>{})
                .entries)
          entry.key: entry.value! as String,
      },
      outsideTheProject: decoded['outsideTheProject'] as bool? ?? false,
    );
  }

  /// The folder name, and how a test asks for it.
  final String name;

  /// One line, for the list.
  final String summary;

  /// What the situation is for, for whoever is deciding whether to use it.
  final String description;

  /// The folder *inside* the repository that the user opens, or empty when
  /// the space is the repository itself (rule 12).
  final String space;

  /// The message of the one commit the history holds.
  final String commit;

  /// Files that exist but git has never been told about.
  final List<String> untracked;

  /// Path to the tail of it that is not committed.
  ///
  /// The folder holds the file as the app will show it; this says how much
  /// of the end of it git has not seen. Committing the file without that
  /// tail and writing it back afterwards is what makes the file *modified*
  /// — which is a state on disk, and cannot be a file of its own.
  final Map<String, String> uncommitted;

  /// Whether it has to be staged outside the repository.
  ///
  /// True for exactly one situation — a folder with no repository above it
  /// — because git looks *upward*: anywhere in this project is inside a
  /// repository, and the app would open it correctly and uselessly.
  final bool outsideTheProject;

  /// Where the files to copy are.
  String get content =>
      '${repoRoot().path}/$mockDirectory/$name/$contentDirectory';
}

/// What a fixture's folder says about itself.
const fixtureFile = 'fixture.json';

/// The part of a fixture's folder that is copied.
///
/// A subfolder rather than the folder itself, so [fixtureFile] is not one
/// of the files the app would then show.
const contentDirectory = 'content';

/// Every fixture under [mockDirectory], in the order they are listed.
///
/// Read from disk rather than declared here: adding a situation is adding a
/// folder, and a list maintained beside it would be wrong the first time
/// somebody forgot it.
List<E2eFixture> e2eFixtures() {
  final directory = Directory('${repoRoot().path}/$mockDirectory');
  if (!directory.existsSync()) return const <E2eFixture>[];
  return <E2eFixture>[
    for (final entry in directory.listSync().whereType<Directory>())
      E2eFixture.read(entry),
  ]..sort((a, b) => a.name.compareTo(b.name));
}

/// Runs one of the environment commands directly.
///
/// `tom e2e <mode>` goes through the menu; this is the same code reachable
/// without it, which is what CI uses and what a `make` target calls.
Future<void> main(List<String> arguments) async {
  final mode = arguments.isEmpty ? 'list' : arguments.first;
  exitCode = switch (mode) {
    'prepare' => await runE2ePrepare(),
    'clean' => await runE2eClean(),
    'list' => await runE2eList(),
    'fixtures' => await runE2eFixtures(),
    'all' => await runAllScenarios(),
    _ => await runNamedScenario(arguments.join(' ')),
  };
}

/// Runs every scenario, one at a time.
///
/// Sequential, and not for tidiness: each one launches the app, and on
/// macOS the next launch fails while the previous window is still there.
Future<int> runAllScenarios() async {
  final scenarios = discoverScenarios();
  if (scenarios.isEmpty) {
    stderr.writeln('tom e2e: no scenarios found under $scenarioDirectory');
    return 1;
  }
  final progress = SuiteProgress(scenarios.length);
  final started = DateTime.now();
  final failures = <String>[];
  var worst = 0;
  for (final scenario in scenarios) {
    progress.index++;
    // The next scenario takes the whole screen. Stacking them leaves the eye
    // scrolling to find what is running now, and a finished one says nothing
    // the summary below will not say better.
    clearScreen();
    final code = await runScenario(scenario, suite: progress);
    if (code == 0) {
      progress.passed++;
    } else {
      progress.failed++;
      failures.add(scenario.name);
      worst = code;
    }
  }
  _printSuiteSummary(progress, failures, DateTime.now().difference(started));
  return worst;
}

/// What the whole run came to.
///
/// Printed after the last screen rather than painted into it: this is the
/// thing someone reads when they come back to the terminal, so it has to
/// survive the scenario screens being cleared over each other.
void _printSuiteSummary(
  SuiteProgress progress,
  List<String> failures,
  Duration elapsed,
) {
  clearScreen();
  final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
  final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
  stdout
    ..writeln(
      '${palette.title}${Layout.appTitle}${Ansi.reset} '
      '${palette.titleSuffix}${Layout.titleSeparator} '
      '${Layout.appSubtitle}${Ansi.reset}',
    )
    ..writeln()
    ..writeln('  ${palette.section}End-to-end${Ansi.reset}')
    ..writeln()
    ..writeln(
      '  ${progress.total} scenarios  ${palette.detail}·${Ansi.reset}  '
      '${palette.ok}✓ ${progress.passed}${Ansi.reset}  '
      '${progress.failed == 0 ? palette.detail : palette.fail}'
      '✘ ${progress.failed}${Ansi.reset}  '
      '${palette.detail}·  $minutes:$seconds${Ansi.reset}',
    )
    ..writeln();
  if (failures.isEmpty) {
    return;
  }
  // Named, because "one failed" sends someone back through six screens to
  // find out which.
  stdout.writeln('  ${palette.fail}Failed${Ansi.reset}');
  for (final name in failures) {
    stdout.writeln('    ${palette.detail}$name${Ansi.reset}');
  }
  stdout.writeln();
}

/// Runs the scenario called [name].
Future<int> runNamedScenario(String name) async {
  final scenarios = discoverScenarios();
  final match = scenarios.where((s) => s.name == name);
  if (match.isEmpty) {
    stderr
      ..writeln('tom e2e: no scenario called "$name". There are:')
      ..writeln();
    for (final scenario in scenarios) {
      stderr.writeln('  ${scenario.name}');
    }
    return 64; // EX_USAGE
  }
  return runScenario(match.first);
}

/// The header every screen carries.
///
/// A command that paints its own frame has to put it back: a header on most
/// screens reads as a bug on the one it is missing from.
void _printTitle() => stdout.writeln(
  '${palette.title}${Layout.appTitle}${Ansi.reset} '
  '${palette.titleSuffix}${Layout.titleSeparator} '
  '${Layout.appSubtitle}${Ansi.reset}',
);

/// Whether `tom e2e prepare` has been run.
///
/// Asked by the menu, which says so on the row that would otherwise fail
/// for want of it.
bool environmentIsPrepared() =>
    File('${repoRoot().path}/$e2eDirectory/$manifestFile').existsSync();

/// Lists the scenarios, with what happened the last time each ran.
///
/// Read from the source, not from a list someone maintains: a scenario is
/// declared by calling `scenario('…')`, and a registry kept beside that
/// would be wrong the first time somebody forgot it.
Future<int> runE2eList() async {
  final scenarios = discoverScenarios();
  final results = readResults();
  _printTitle();
  announce('End-to-end — scenarios');
  stdout.writeln();

  if (scenarios.isEmpty) {
    stdout.writeln('  None declared under $scenarioDirectory yet.');
    return 0;
  }

  final prepared = environmentIsPrepared();
  final groups = <String, List<Scenario>>{};
  for (final scenario in scenarios) {
    groups.putIfAbsent(scenario.group, () => <Scenario>[]).add(scenario);
  }
  final width = scenarios
      .map((s) => s.name.length)
      .reduce((a, b) => a > b ? a : b);

  for (final entry in groups.entries) {
    stdout
      ..writeln('  ${palette.section}${entry.key}${Ansi.reset}')
      ..writeln();
    for (final scenario in entry.value) {
      final result = results[scenario.name];
      // Blocked reads differently from failed, and both read differently
      // from never having run. A scenario that never ran is listed without
      // a date rather than hidden: absence is information.
      final detail = switch (result) {
        _ when scenario.needsEnvironment && !prepared =>
          '${palette.rowDisabled}$blockedNote${Ansi.reset}',
        null => '${palette.rowDisabled}never run${Ansi.reset}',
        _ =>
          '${result.passed ? palette.ok : palette.fail}'
              '${result.passed ? '✓' : '✘'}${Ansi.reset} '
              '${palette.detail}${describeWhen(result.when)} · '
              'v${result.version} · ${describeElapsed(result.elapsed)}'
              '${Ansi.reset}',
      };
      stdout.writeln('    ${scenario.name.padRight(width)}  $detail');
    }
    stdout.writeln();
  }

  final blocked = scenarios.where((s) => s.needsEnvironment).length;
  stdout.writeln(
    prepared
        ? '  ${palette.ok}✓${Ansi.reset} ${palette.detail}Environment ready '
              'at $e2eDirectory/ — everything above can run.${Ansi.reset}'
        : '  ${palette.rowDisabled}Environment not built — '
              '$blocked of ${scenarios.length} cannot run. '
              '`tom e2e prepare` builds it.${Ansi.reset}',
  );
  return 0;
}

/// Lists the folders the scenarios are pointed at.
///
/// Named *fixtures* and not scenarios, which is what they were called until
/// the word had to mean two things at once. A fixture is a situation on
/// disk; a scenario is a flow through the app. Several scenarios share one
/// fixture, and one that needed its own would be describing a situation
/// nobody has.
Future<int> runE2eFixtures() async {
  _printTitle();
  announce('End-to-end — fixtures');
  stdout.writeln();
  for (final fixture in e2eFixtures()) {
    stdout
      ..writeln('  ${fixture.name.padRight(18)} ${fixture.summary}')
      ..writeln('  ${' '.padRight(18)} ${_wrap(fixture.description)}')
      ..writeln();
  }
  return 0;
}

/// Builds the environment from scratch.
///
/// Destructive on purpose: it deletes what was there first. A scenario the
/// last run left modified is not a scenario, and "prepare" that sometimes
/// prepared would be the worst kind of flake — the one that depends on
/// whether the previous test passed.
Future<int> runE2ePrepare() async {
  final directory = Directory('${repoRoot().path}/$e2eDirectory');
  _printTitle();
  announce('End-to-end — prepare');
  if (directory.existsSync()) {
    directory.deleteSync(recursive: true);
  }
  directory.createSync(recursive: true);

  final manifest = <String, Object?>{
    'preparedAt': DateTime.now().toUtc().toIso8601String(),
    'scenarios': <String, Object?>{},
  };
  final scenarios = manifest['scenarios']! as Map<String, Object?>;

  final fixtures = e2eFixtures();
  for (final fixture in fixtures) {
    scenarios[fixture.name] = _build(fixture, directory);
  }

  File('${directory.path}/$manifestFile').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(manifest)}\n',
  );
  File('${directory.path}/README.md').writeAsStringSync(_readme);

  stdout
    ..writeln()
    ..writeln('  ${fixtures.length} fixtures under $e2eDirectory/')
    ..writeln('  Open one in the app to see what the tests see:')
    ..writeln('    make run   →  Choose folder…  →  $e2eDirectory/…');
  return 0;
}

/// Removes the environment.
Future<int> runE2eClean() async {
  final directory = Directory('${repoRoot().path}/$e2eDirectory');
  _printTitle();
  announce('End-to-end — clean');
  if (!directory.existsSync()) {
    stdout.writeln('  Nothing to remove.');
    return 0;
  }
  directory.deleteSync(recursive: true);
  stdout.writeln('  Removed $e2eDirectory/');
  return 0;
}

/// Stages [fixture] and returns what the manifest says about it.
///
/// The folder is copied as it is; the history is made here. What makes a
/// file *modified* or *untracked* is a state of the repository, not a file
/// anyone can commit — so the mock holds the working tree the app will
/// show, and this builds the history that tree is a change to.
Map<String, Object?> _build(E2eFixture fixture, Directory root) {
  // A fixture that is *outside* any repository cannot be staged under
  // `.e2e/`, which is inside this one. The manifest records where it went,
  // so a scenario asks for it by name and never learns it is elsewhere.
  final destination = fixture.outsideTheProject
      ? '${Directory.systemTemp.path}/tom-e2e-${fixture.name}'
      : '${root.path}/${fixture.name}';
  final directory = Directory(destination);
  if (directory.existsSync()) directory.deleteSync(recursive: true);
  _copy(Directory(fixture.content), directory);

  final space = fixture.space.isEmpty
      ? destination
      : '$destination/${fixture.space}';

  if (!fixture.outsideTheProject) {
    _initRepository(destination);
    // Committed without the tails, which are then written back: that is
    // what leaves the file modified in the working tree.
    fixture.uncommitted.forEach((path, tail) {
      _write('$destination/$path', _without(tail, at: '$destination/$path'));
    });
    _git(destination, <String>[
      'add',
      '--',
      '.',
      for (final path in fixture.untracked) ':(exclude)$path',
    ]);
    _git(destination, ['commit', '--quiet', '--message', fixture.commit]);
    fixture.uncommitted.forEach((path, tail) {
      _write(
        '$destination/$path',
        '${File('$destination/$path').readAsStringSync()}$tail',
      );
    });
  }

  return <String, Object?>{
    'root': space,
    if (!fixture.outsideTheProject) 'repositoryRoot': destination,
    'name': space.split('/').last,
    'documents': _documentsIn(space),
    if (fixture.untracked.isNotEmpty)
      'untracked': _relativeTo(space, destination, fixture.untracked),
    if (fixture.uncommitted.isNotEmpty)
      'modified': _relativeTo(
        space,
        destination,
        fixture.uncommitted.keys.toList(),
      ),
    if (fixture.outsideTheProject) 'outsideTheProject': true,
  };
}

/// The file [at] without its [tail], which it must end with.
///
/// Loudly, because a tail that stopped matching would otherwise commit the
/// whole file and leave a fixture with nothing modified in it — a scenario
/// asserting on status would then fail somewhere unrelated to the cause.
String _without(String tail, {required String at}) {
  final content = File(at).readAsStringSync();
  if (!content.endsWith(tail)) {
    throw StateError(
      'tom e2e: $at does not end with the uncommitted tail its '
      '$fixtureFile declares. Either the file changed or the tail did.',
    );
  }
  return content.substring(0, content.length - tail.length);
}

/// The markdown files under [space], relative to it and sorted.
///
/// Walked rather than listed in the fixture: the folder is the truth, and a
/// list beside it is one more thing to forget.
List<String> _documentsIn(String space) => <String>[
  for (final entry in Directory(space).listSync(recursive: true))
    if (entry is File && entry.path.endsWith('.md'))
      entry.path.substring(space.length + 1),
]..sort();

/// [paths], which are relative to [repository], relative to [space] instead.
///
/// The manifest speaks the app's language: every path a test reads is
/// relative to the folder the user opened.
List<String> _relativeTo(String space, String repository, List<String> paths) =>
    <String>[
      for (final path in paths)
        if ('$repository/$path'.startsWith('$space/'))
          '$repository/$path'.substring(space.length + 1),
    ];

/// Copies [from] onto [to], folders and all.
///
/// By hand rather than through `cp`: the CLI runs on whatever the
/// contributor has, and a shell out for something `dart:io` does is a
/// platform difference waiting to be found by someone on Windows.
void _copy(Directory from, Directory to) {
  if (!from.existsSync()) {
    throw StateError('tom e2e: ${from.path} does not exist.');
  }
  to.createSync(recursive: true);
  for (final entry in from.listSync(recursive: true)) {
    final target = '${to.path}/${entry.path.substring(from.path.length + 1)}';
    if (entry is Directory) {
      Directory(target).createSync(recursive: true);
    } else if (entry is File) {
      Directory(target).parent.createSync(recursive: true);
      entry.copySync(target);
    }
  }
}

/// Creates a repository at [path] with an identity and a `main` branch.
///
/// `symbolic-ref` rather than `init --initial-branch`, which needs git 2.28:
/// the environment must not be stricter about git than the app is.
void _initRepository(String path) {
  Directory(path).createSync(recursive: true);
  _git(path, ['init', '--quiet', '.']);
  _git(path, ['symbolic-ref', 'HEAD', 'refs/heads/main']);
  for (final setting in const [
    ['user.name', 'TOM E2E'],
    ['user.email', 'e2e@example.invalid'],
    ['commit.gpgsign', 'false'],
  ]) {
    _git(path, ['config', ...setting]);
  }
}

/// Runs git inside [directory], failing loudly.
///
/// A half-built environment is worse than none: a test against it fails
/// somewhere unrelated to what it was asserting.
void _git(String directory, List<String> arguments) {
  final result = Process.runSync(
    'git',
    arguments,
    workingDirectory: directory,
    environment: const {'LC_ALL': 'C'},
  );
  if (result.exitCode != 0) {
    throw StateError(
      'tom e2e: git ${arguments.join(' ')} in $directory failed:\n'
      '${result.stderr}',
    );
  }
}

/// Writes [content] to [path], creating the folders it needs.
void _write(String path, String content) {
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(content);
}

/// Folds [text] onto continuation lines for the list.
String _wrap(String text, {int width = 58}) {
  final words = text.split(' ');
  final lines = <String>[];
  var line = StringBuffer();
  for (final word in words) {
    if (line.length + word.length + 1 > width) {
      lines.add(line.toString());
      line = StringBuffer();
    }
    if (line.isNotEmpty) line.write(' ');
    line.write(word);
  }
  if (line.isNotEmpty) lines.add(line.toString());
  return lines.join('\n  ${' '.padRight(18)} ');
}

const _readme = '''
# The end-to-end environment

Built by `tom e2e prepare`, deleted by `tom e2e clean`, and gitignored.
Nothing here is edited by hand: the next prepare throws it away.

Open one of the folders in the app — `make run`, then *Choose folder…* —
to see exactly what the end-to-end tests are looking at.
''';
