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
/// Inside the repository and gitignored rather than in the system temporary
/// folder, so a failure can be read by opening what the test saw in the app.
const e2eDirectory = '.e2e';

/// What the tests read to find out what was prepared.
///
/// `tool/` has no pubspec and cannot share a constant with `src/`, so the
/// manifest is the seam: a scenario renamed on one side fails loudly on the
/// other.
const manifestFile = 'manifest.json';

/// Where the fixtures the environment is built from live.
///
/// Committed markdown on disk rather than string constants here, so what a
/// test looks at is reviewable in a diff and openable in the app; beside the
/// scenarios that read it, because the fixture and the flow are one change.
const mockDirectory = 'src/apps/desktop/integration_test/fixtures';

/// One situation the app can be pointed at.
///
/// A *fixture* is a situation on disk; a *scenario* is a flow through the
/// app, and several share one fixture. Everything but [name] is read from
/// the folder's `fixture.json`: the folder is the content, the file is what
/// git has and has not seen of it.
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
    required this.remote,
    required this.branches,
    required this.commits,
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
      remote: E2eRemote.read(decoded['remote']),
      branches: E2eBranch.read(decoded['branches']),
      commits: <E2eCommit>[
        for (final entry
            in (decoded['commits'] as List<Object?>? ?? const <Object?>[]))
          E2eCommit.read(entry! as Map<String, Object?>),
      ],
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

  /// Path to the tail of it that git has not seen.
  ///
  /// The file is committed without the tail and written back whole, which is
  /// what makes it *modified*: a state on disk, not a file of its own.
  final Map<String, String> uncommitted;

  /// The remote this repository tracks, or null when it tracks none.
  final E2eRemote? remote;

  /// Further commits on the fixture's own branch, oldest first — what gives a
  /// document a history.
  final List<E2eCommit> commits;

  /// Branches beside the fixture's own, each with its own commits.
  ///
  /// A branch holding the same files as `main` would let a switch that never
  /// touched the working tree pass.
  final List<E2eBranch> branches;

  /// Whether it has to be staged outside the repository.
  ///
  /// Git looks upward, so a folder with no repository above it cannot be
  /// anywhere inside this project.
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

/// Every fixture under [mockDirectory], sorted by name.
///
/// Read from disk rather than declared here: adding a situation is adding a
/// folder.
List<E2eFixture> e2eFixtures() {
  final directory = Directory('${repoRoot().path}/$mockDirectory');
  if (!directory.existsSync()) return const <E2eFixture>[];
  return <E2eFixture>[
    for (final entry in directory.listSync().whereType<Directory>())
      E2eFixture.read(entry),
  ]..sort((a, b) => a.name.compareTo(b.name));
}

/// Runs the scenario slowly enough to watch it happen: `tom e2e <name>
/// --watch`.
///
/// Declared here because both entry points take it — the menu and this
/// file's [main] — and a flag spelled twice is one eventually forgotten.
const watchFlag = '--watch';

/// Runs one of the environment commands directly, without the menu.
///
/// [watchFlag] is taken from anywhere in the line, as the menu takes it.
Future<void> main(List<String> arguments) async {
  final watch = arguments.contains(watchFlag);
  final words = arguments.where((word) => word != watchFlag).toList();
  final mode = words.isEmpty ? 'list' : words.first;
  exitCode = switch (mode) {
    'prepare' => await runE2ePrepare(),
    'clean' => await runE2eClean(),
    'list' => await runE2eList(),
    'fixtures' => await runE2eFixtures(),
    'all' => await runAllScenarios(watch: watch),
    _ => await runNamedScenario(words.join(' '), watch: watch),
  };
}

/// Runs every scenario, one at a time.
///
/// Sequential because each one launches the app, and on macOS the next launch
/// fails while the previous window is still there.
Future<int> runAllScenarios({bool watch = false}) async {
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
    // The next scenario takes the whole screen; a finished one says nothing
    // the summary will not say better.
    clearScreen();
    _freshEnvironmentFor(scenario);
    final code = await runScenario(scenario, suite: progress, watch: watch);
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

/// What the whole run came to, printed after the last screen so it survives
/// the scenario screens being cleared over each other.
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
  // Named, because "one failed" is otherwise six screens back.
  stdout.writeln('  ${palette.fail}Failed${Ansi.reset}');
  for (final name in failures) {
    stdout.writeln('    ${palette.detail}$name${Ansi.reset}');
  }
  stdout.writeln();
}

/// Runs the scenario called [name].
Future<int> runNamedScenario(String name, {bool watch = false}) async {
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
  _freshEnvironmentFor(match.first);
  return runScenario(match.first, watch: watch);
}

/// Rebuilds the environment before [scenario], when it reads one.
///
/// Scenarios write — one commits, one saves, one pushes — so the next one
/// would otherwise open a situation nobody described.
void _freshEnvironmentFor(Scenario scenario) {
  if (scenario.needsEnvironment) buildEnvironment();
}

/// The header every screen carries; a command that paints its own frame has
/// to put it back.
void _printTitle() => stdout.writeln(
  '${palette.title}${Layout.appTitle}${Ansi.reset} '
  '${palette.titleSuffix}${Layout.titleSeparator} '
  '${Layout.appSubtitle}${Ansi.reset}',
);

/// Whether `tom e2e prepare` has been run.
bool environmentIsPrepared() =>
    File('${repoRoot().path}/$e2eDirectory/$manifestFile').existsSync();

/// Lists the scenarios, with what happened the last time each ran.
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
  final groups = <String, List<Scenario>>{
    // Seeded in the declared order, so the list reads as the journey through
    // the app; empty groups are dropped, an undeclared one lands at the end.
    for (final heading in scenarioGroups) heading: <Scenario>[],
  };
  for (final scenario in scenarios) {
    groups.putIfAbsent(scenario.group, () => <Scenario>[]).add(scenario);
  }
  groups.removeWhere((_, scenarios) => scenarios.isEmpty);
  final width = scenarios
      .map((s) => s.name.length)
      .reduce((a, b) => a > b ? a : b);

  for (final entry in groups.entries) {
    stdout
      ..writeln('  ${palette.section}${entry.key}${Ansi.reset}')
      ..writeln();
    for (final scenario in entry.value) {
      final result = results[scenario.name];
      // Blocked, failed and never run read differently, and a scenario that
      // never ran is listed without a date rather than hidden.
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

/// Lists the fixtures: the situations on disk, as against the scenarios that
/// flow through them (see [E2eFixture]).
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

/// Builds the environment from scratch, and answers the fixtures it made.
///
/// It deletes what was there first: a fixture the last run left modified is
/// not the fixture, and [_freshEnvironmentFor] relies on that.
List<E2eFixture> buildEnvironment() {
  final directory = Directory('${repoRoot().path}/$e2eDirectory');
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
  return fixtures;
}

/// Builds the environment and says where it went.
Future<int> runE2ePrepare() async {
  _printTitle();
  announce('End-to-end — prepare');
  final fixtures = buildEnvironment();

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

/// A remote the fixture tracks, and how far each side has drifted from it.
///
/// A bare repository beside the working tree, never a server: to git a
/// filesystem path is as real a remote as GitHub, so fetch, push and pull
/// take the same code path with no network, no credentials and a divergence
/// built to order.
final class E2eRemote {
  const E2eRemote({required this.theirs, required this.mine});

  /// Reads the `remote` block, or answers null when there is none.
  static E2eRemote? read(Object? decoded) {
    if (decoded == null) return null;
    if (decoded is! Map<String, Object?>) {
      throw StateError('tom e2e: a fixture\'s "remote" must be an object.');
    }
    return E2eRemote(
      theirs: _commits(decoded['theirs']),
      mine: _commits(decoded['mine']),
    );
  }

  static List<E2eCommit> _commits(Object? decoded) => <E2eCommit>[
    for (final entry in (decoded as List<Object?>? ?? const <Object?>[]))
      E2eCommit.read(entry! as Map<String, Object?>),
  ];

  /// Commits only the remote has: what a fetch discovers and a push is
  /// refused for.
  ///
  /// Made after the first push and never fetched, so `behind` is zero until
  /// the app asks.
  final List<E2eCommit> theirs;

  /// Commits only the working tree has — what there is to publish.
  final List<E2eCommit> mine;
}

/// A branch to manufacture, and the commits that make it differ.
///
/// Branched off the fixture's whole history and left behind; the repository
/// ends on `main`, so a scenario starts where the user would.
final class E2eBranch {
  const E2eBranch({required this.name, required this.commits});

  /// Reads the `branches` block, which may be absent.
  static List<E2eBranch> read(Object? decoded) {
    if (decoded == null) return const <E2eBranch>[];
    if (decoded is! List<Object?>) {
      throw StateError('tom e2e: a fixture\'s "branches" must be a list.');
    }
    return <E2eBranch>[
      for (final entry in decoded)
        E2eBranch(
          name: (entry! as Map<String, Object?>)['name']! as String,
          commits: <E2eCommit>[
            for (final commit
                in ((entry as Map<String, Object?>)['commits']
                        as List<Object?>? ??
                    const <Object?>[]))
              E2eCommit.read(commit! as Map<String, Object?>),
          ],
        ),
    ];
  }

  /// What it is called, and what a scenario clicks on.
  final String name;

  /// What is on it that is not on the branch it started from.
  final List<E2eCommit> commits;
}

/// One commit to manufacture: a message, and the files it writes.
final class E2eCommit {
  const E2eCommit({required this.message, required this.write});

  /// Reads one entry of a `commits`, `theirs` or `mine` list.
  factory E2eCommit.read(Map<String, Object?> decoded) => E2eCommit(
    message: decoded['message']! as String,
    write: <String, String>{
      for (final entry
          in (decoded['write'] as Map<String, Object?>? ??
                  const <String, Object?>{})
              .entries)
        entry.key: entry.value! as String,
    },
  );

  /// What it is called in the history.
  final String message;

  /// The files it creates or replaces, by path inside the repository.
  ///
  /// The two sides of a remote write *different* files: the recovery scenario
  /// needs a pull that merges cleanly, and a conflict has no screen yet.
  final Map<String, String> write;
}

/// Stages [fixture] and returns what the manifest says about it.
///
/// The folder is copied as it is and the history is made here: *modified*
/// and *untracked* are states of the repository, not files anyone can commit.
Map<String, Object?> _build(E2eFixture fixture, Directory root) {
  // A fixture outside any repository cannot sit under `.e2e/`, which is
  // inside this one; the manifest records where it went instead.
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
    // Committed without the tails, which are written back below.
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
    // On `main` before any branch is made, so every branch starts from the
    // whole history.
    for (final commit in fixture.commits) {
      _commit(destination, commit);
    }
    // The repository comes back to `main`, so a scenario opens where a person
    // would.
    for (final branch in fixture.branches) {
      _git(destination, ['switch', '--quiet', '--create', branch.name]);
      for (final commit in branch.commits) {
        _commit(destination, commit);
      }
      _git(destination, ['switch', '--quiet', 'main']);
    }
    if (fixture.remote case final E2eRemote remote) {
      _attachRemote(destination, remote);
    }
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
    // So a scenario can ask the remote what actually arrived.
    if (fixture.remote != null) 'remoteRoot': '$destination.git',
    if (fixture.branches.isNotEmpty)
      'branches': <String>[for (final branch in fixture.branches) branch.name],
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
/// Loud, because a tail that stopped matching would commit the whole file and
/// leave nothing modified, failing a scenario far from the cause.
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

/// The markdown files under [space], relative to it and sorted; walked rather
/// than listed in the fixture, because the folder is the truth.
List<String> _documentsIn(String space) => <String>[
  for (final entry in Directory(space).listSync(recursive: true))
    if (entry is File && entry.path.endsWith('.md'))
      entry.path.substring(space.length + 1),
]..sort();

/// [paths], relative to [repository], made relative to [space]: every path a
/// test reads is relative to the folder the user opened.
List<String> _relativeTo(String space, String repository, List<String> paths) =>
    <String>[
      for (final path in paths)
        if ('$repository/$path'.startsWith('$space/'))
          '$repository/$path'.substring(space.length + 1),
    ];

/// Copies [from] onto [to], folders and all — by hand rather than through
/// `cp`, which is a platform difference waiting for someone on Windows.
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

/// Gives the repository at [path] a remote, and the drift [remote] asks for.
///
/// The order is the drift: a bare repository and a first push, so
/// `origin/main` is tracked; *their* commits through a throwaway clone, so the
/// bare moves while `origin/main` here stays put; then *my* commits, unpushed,
/// so there is something to publish and something for a push to be refused.
void _attachRemote(String path, E2eRemote remote) {
  final bare = '$path.git';
  if (Directory(bare).existsSync()) {
    Directory(bare).deleteSync(recursive: true);
  }
  Directory(bare).createSync(recursive: true);
  _git(bare, ['init', '--quiet', '--bare', '--initial-branch', 'main', '.']);
  _git(path, ['remote', 'add', 'origin', bare]);
  _git(path, ['push', '--quiet', '--set-upstream', 'origin', 'main']);

  if (remote.theirs.isNotEmpty) {
    // Through a clone, because a bare repository has no working tree to
    // commit in.
    final theirs = '${Directory.systemTemp.path}/tom-e2e-theirs';
    if (Directory(theirs).existsSync()) {
      Directory(theirs).deleteSync(recursive: true);
    }
    _git(Directory.systemTemp.path, ['clone', '--quiet', bare, theirs]);
    _configure(theirs);
    for (final commit in remote.theirs) {
      _commit(theirs, commit);
    }
    _git(theirs, ['push', '--quiet', 'origin', 'main']);
    Directory(theirs).deleteSync(recursive: true);
  }

  for (final commit in remote.mine) {
    _commit(path, commit);
  }
}

/// Writes [commit]'s files in [path] and records them.
void _commit(String path, E2eCommit commit) {
  commit.write.forEach((file, content) => _write('$path/$file', content));
  _git(path, ['add', '--', '.']);
  _git(path, ['commit', '--quiet', '--message', commit.message]);
}

/// The identity and settings every manufactured repository commits with.
void _configure(String path) {
  for (final setting in const [
    ['user.name', 'TOM E2E'],
    ['user.email', 'e2e@example.invalid'],
    ['commit.gpgsign', 'false'],
  ]) {
    _git(path, ['config', ...setting]);
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
  _configure(path);
}

/// Runs git inside [directory], failing loudly: a half-built environment
/// fails a test somewhere unrelated to what it asserted.
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
