// Maps a set of changed files to the specific *_test.dart files they should
// re-run, then hands that off to tool/run_tests.dart to execute and render.
//
//   dart run tool/src/commands/run_changed_tests.dart [--coverage] [BASE]
//   dart run tool/src/commands/run_changed_tests.dart [--coverage] --last=10
//
// Two ways to name that set, one mapping. `--last=N` takes the N most
// recently edited source files under src/ by modification time; everything
// else takes a git diff against BASE. The mapping below is the part worth not
// duplicating, which is why both live here.
//
// BASE defaults to $BASE, then "main" — `make flutter-test-diff BASE=develop`
// sets the env var Make already exports to this recipe's shell. Three diff
// sources are unioned, so a changed file counts whether it's committed on the
// branch, only staged or modified, or brand new and untracked:
//
//   git diff --name-only BASE...HEAD
//   git diff --name-only HEAD
//   git ls-files --others --exclude-standard
//
// A changed lib/ file maps to its test by filename convention alone —
// `foo.dart` -> `foo_test.dart`, wherever under that package's test/ it
// lives — because that is the one thing every test file in this project
// actually guarantees (see tool/run_tests.dart). There is no import-graph
// analysis and no package-wide fallback: touching tom_core no longer reruns
// every package that depends on it, only the tests whose own name says they
// cover the file that changed. A changed test file is simply run directly.
// `src/pubspec.yaml` and anything under `src/test/` map to `arch`, since
// that is what the architecture graph test actually asserts against.
//
// No external packages — only dart:io — so it runs with nothing but the SDK
// already on the machine, from any directory.

import 'dart:async';
import 'dart:io';

import '../repo.dart';
import '../tty.dart';
import 'process.dart';

const _pkgOrder = [
  'core',
  'domain',
  'application',
  'infra',
  'data',
  'presentation',
  'ui',
];

const _apps = ['desktop', 'mobile'];

void main(List<String> args) async {
  final coverage = args.contains('--coverage');
  final last = _lastCount(args);
  final rest = args
      .where((a) => a != '--coverage' && !a.startsWith('--last'))
      .toList();
  final base = rest.isNotEmpty
      ? rest.first
      : Platform.environment['BASE'] ?? 'main';

  // Shown here rather than left to tool/run_tests.dart, since this script's
  // own setup — the git diff, walking each package's test/ for a filename
  // match — is the part that can actually take a moment on a large diff.
  await _showCompiling();

  final root = repoRoot();
  final changed = last != null
      ? _recentFiles(root, last)
      : await _changedFiles(root, base);
  final source = last != null
      ? 'Last $last file(s) edited'
      : 'Diffing against $base — ${changed.length} file(s) changed';
  stdout.writeln('• $source');
  if (changed.isEmpty) exit(0);

  final testFiles = <String, Set<String>>{}; // package label -> relative paths
  var wantArch = false;
  var wantCli = false;
  for (final path in changed) {
    // Both folders under src/test/ hold tests for something that is not a
    // package, and they are not the same something: the layer graph, and the
    // CLI. A change under tool/ is the CLI's too — it is what those tests
    // drive, and nothing else maps it anywhere.
    if (path.startsWith('src/test/cli/') || path.startsWith('tool/')) {
      wantCli = true;
      continue;
    }
    if (path == 'src/pubspec.yaml' || path.startsWith('src/test/')) {
      wantArch = true;
      continue;
    }

    final pkgMatch = RegExp(
      r'^src/packages/([^/]+)/(lib|test)/(.+)$',
    ).firstMatch(path);
    final appMatch = RegExp(
      r'^src/apps/([^/]+)/(lib|test)/(.+)$',
    ).firstMatch(path);

    late final String label;
    late final Directory pkgDir;
    late final String kind;
    late final String sub;
    if (pkgMatch != null) {
      final pkg = pkgMatch.group(1)!;
      if (!_pkgOrder.contains(pkg)) continue;
      label = pkg;
      pkgDir = Directory('${root.path}/src/packages/$pkg');
      kind = pkgMatch.group(2)!;
      sub = pkgMatch.group(3)!;
    } else if (appMatch != null && _apps.contains(appMatch.group(1))) {
      label = appMatch.group(1)!;
      pkgDir = Directory('${root.path}/src/apps/$label');
      kind = appMatch.group(2)!;
      sub = appMatch.group(3)!;
    } else {
      continue; // docs, CI config, etc. — nothing to test
    }

    if (kind == 'test') {
      if (sub.endsWith('_test.dart')) {
        testFiles.putIfAbsent(label, () => {}).add('test/$sub');
      }
      continue;
    }

    if (!sub.endsWith('.dart')) continue;
    final name = sub.split('/').last;
    final testName =
        '${name.substring(0, name.length - '.dart'.length)}_test.dart';
    final testDir = Directory('${pkgDir.path}/test');
    final matches = testDir.existsSync()
        ? testDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.uri.pathSegments.last == testName)
        : const <File>[];

    if (matches.isEmpty) continue;
    for (final f in matches) {
      testFiles
          .putIfAbsent(label, () => {})
          .add(f.path.substring(pkgDir.path.length + 1));
    }
  }

  // A mapped path can still be gone by the time we get here — e.g. a test
  // file that itself was deleted in the diff. Drop those rather than handing
  // tool/run_tests.dart a path that doesn't exist.
  for (final label in testFiles.keys.toList()) {
    final pkgDir = _apps.contains(label)
        ? Directory('${root.path}/src/apps/$label')
        : Directory('${root.path}/src/packages/$label');
    final existing = testFiles[label]!
        .where((f) => File('${pkgDir.path}/$f').existsSync())
        .toSet();
    if (existing.isEmpty) {
      testFiles.remove(label);
    } else {
      testFiles[label] = existing;
    }
  }

  if (testFiles.isEmpty && !wantArch && !wantCli) {
    print(
      last != null
          ? 'The last $last file(s) edited map to no test.'
          : 'Changed files against $base map to no test.',
    );
    exit(0);
  }

  final specs = [
    if (wantArch) 'arch',
    if (wantCli) 'cli',
    for (final e in testFiles.entries) '${e.key}=${e.value.join(',')}',
  ];

  final process = await Process.start(
    dartExecutable,
    [
      'run',
      'tool/src/commands/run_tests.dart',
      '--no-banner',
      if (coverage) '--coverage',
      ...specs,
    ],
    workingDirectory: root.path,
    mode: ProcessStartMode.inheritStdio,
  );

  final code = await process.exitCode;

  // The `◔` the dashboard prints is the whole package's, measured by whatever
  // subset of its suite just ran — which is why a narrowed run reports a
  // package at 28% that the full run reports at 100%. The number worth having
  // after a run like this is the one for the files it was narrowed to, and
  // that is what this prints.
  if (coverage && code == 0) {
    _reportCoverageOf(_sourcesAmong(changed, root), root);
  }

  exit(code);
}

/// The production files a coverage number is about, given what changed.
///
/// Both directions of the same convention. A changed `lib/foo.dart` is itself
/// what was measured. A changed `foo_test.dart` is not — it is why something
/// ran — so what it stands for is `foo.dart`, found the same way the run
/// found the test in the first place: by name, anywhere under the package.
///
/// That second direction is what makes this useful right after writing a
/// test, which is when the question "what does it actually cover" is asked.
List<String> _sourcesAmong(List<String> changed, Directory root) {
  final sources = <String>{};

  for (final path in changed) {
    final match = RegExp(
      r'^(src/(?:packages|apps)/[^/]+)/(lib|test)/(.+\.dart)$',
    ).firstMatch(path);
    if (match == null) continue;

    final package = match.group(1)!;
    final kind = match.group(2)!;
    final sub = match.group(3)!;

    if (kind == 'lib') {
      sources.add(path);
      continue;
    }

    final name = sub.split('/').last;
    if (!name.endsWith('_test.dart')) continue;
    final sourceName =
        '${name.substring(0, name.length - '_test.dart'.length)}.dart';

    final lib = Directory('${root.path}/$package/lib');
    if (!lib.existsSync()) continue;
    for (final file in lib.listSync(recursive: true).whereType<File>()) {
      if (file.uri.pathSegments.last != sourceName) continue;
      sources.add(file.path.replaceFirst('${root.path}/', ''));
    }
  }

  return sources.toList()..sort();
}

/// Prints the line coverage of [sources], file by file, worst first.
///
/// Read out of the lcov each package just wrote rather than measured again:
/// the run that finished a moment ago is the measurement, and the only thing
/// left to do is to stop averaging it over code nobody touched.
void _reportCoverageOf(List<String> sources, Directory root) {
  if (sources.isEmpty) return;

  final measured = <String, (int found, int hit)>{};
  for (final entry in _lcovRecords(sources, root).entries) {
    measured[entry.key] = entry.value;
  }

  final found = measured.values.fold(0, (sum, e) => sum + e.$1);
  final hit = measured.values.fold(0, (sum, e) => sum + e.$2);

  stdout.writeln();
  if (found == 0) {
    stdout.writeln(
      '• No coverage data for the ${sources.length} file(s) that ran — '
      'nothing executable in them, or no test loads them.',
    );
    return;
  }

  // Least covered first: the file that needs a test is the one worth putting
  // where the eye lands, and on a long list the top is the only place read.
  final rows = measured.entries.toList()
    ..sort((a, b) {
      final rate = (a.value.$2 / a.value.$1).compareTo(b.value.$2 / b.value.$1);
      return rate != 0 ? rate : a.key.compareTo(b.key);
    });

  stdout.writeln('• Coverage of what you touched, least covered first:');
  for (final row in rows) {
    final (fileFound, fileHit) = row.value;
    final percent = (fileHit / fileFound * 100).toStringAsFixed(1).padLeft(5);
    stdout.writeln(
      '  $percent%  ${'$fileHit/$fileFound'.padLeft(9)}  ${row.key}',
    );
  }

  // Apart, with the reason, rather than as 0% or as nothing at all: a barrel
  // of exports and a bare enum declare no executable line, so counting them
  // as zero would understate and dropping them would overstate.
  final silent = sources.where((s) => !measured.containsKey(s)).toList()
    ..sort();
  if (silent.isNotEmpty) {
    stdout.writeln();
    stdout.writeln(
      '  Nothing to measure in ${silent.length} more — no executable line, '
      'or no test loads them:',
    );
    for (final path in silent) {
      stdout.writeln('    $path');
    }
  }

  final percent = (hit / found * 100).toStringAsFixed(1);
  stdout
    ..writeln()
    ..writeln(
      '  $percent% of the lines you touched ($hit of $found), '
      'across ${measured.length} of ${sources.length} file(s)',
    );
}

/// The `found`/`hit` line counts each of [sources] has in its own package's
/// lcov, for the sources that appear in one at all.
///
/// Two spellings have to be matched: `format_coverage` writes absolute paths
/// for the pure Dart packages and `flutter test --coverage` writes paths
/// relative to the package for the apps.
Map<String, (int found, int hit)> _lcovRecords(
  List<String> sources,
  Directory root,
) {
  final wanted = sources.toSet();
  final records = <String, (int, int)>{};

  for (final package in _packageDirectoriesOf(sources)) {
    final lcov = File('${root.path}/$package/coverage/lcov.info');
    if (!lcov.existsSync()) continue;

    String? current;
    for (final line in lcov.readAsLinesSync()) {
      if (line.startsWith('SF:')) {
        final path = line.substring(3).trim();
        final relative = path.startsWith('/')
            ? path.replaceFirst('${root.path}/', '')
            : '$package/$path';
        current = wanted.contains(relative) ? relative : null;
        if (current != null) records[current] ??= (0, 0);
        continue;
      }
      if (current == null || !line.startsWith('DA:')) continue;

      final hits = int.tryParse(line.substring(3).split(',').last);
      if (hits == null) continue;
      final (f, h) = records[current]!;
      records[current] = (f + 1, hits > 0 ? h + 1 : h);
    }
  }
  return records;
}

/// The package directories [sources] belong to, each once.
Set<String> _packageDirectoriesOf(List<String> sources) => {
  for (final path in sources) path.split('/').take(3).join('/'),
};

/// A brief banner shown before setup, covering it with a live "compiling"
/// ticker instead of a silent terminal. The floor delay keeps it visible for
/// a beat even when setup is instant — otherwise it would flash and vanish,
/// which reads as nothing having happened at all. Duplicated from
/// run_tests.dart rather than shared: each entry point shows its own, and
/// run_tests.dart skips it (`--no-banner`) when this one already ran.
Future<void> _showCompiling() async {
  stdout.writeln('• Running build hooks...');

  // The banner exists to fill a silence someone is watching. Nobody watches a
  // log, so in plain mode the line above is the whole banner.
  if (isPlain) return;

  stdout.writeln();
  final start = DateTime.now();
  void redraw() {
    final d = DateTime.now().difference(start);
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    stdout.write('\r\x1B[K⏳ compiling…  $mm:$ss');
  }

  redraw();
  final ticker = Timer.periodic(const Duration(seconds: 1), (_) => redraw());
  await Future<void>.delayed(const Duration(milliseconds: 300));
  ticker.cancel();
  stdout.write('\r\x1B[K');
}

/// The `--last=N` an argument list carries, or `null` when it carries none.
///
/// A bare `--last` means the default: someone typing it is asking for "the
/// ones I just touched", not for a number they have in mind.
int? _lastCount(List<String> args) {
  final argument = args.where((a) => a.startsWith('--last')).firstOrNull;
  if (argument == null) return null;
  final equals = argument.indexOf('=');
  if (equals < 0) return _defaultLastCount;
  return int.tryParse(argument.substring(equals + 1)) ?? _defaultLastCount;
}

/// How many recently edited files `--last` takes when it is not given a
/// number. Ten is about a sitting's worth of work.
const _defaultLastCount = 10;

/// The [count] most recently edited source files under `src/`, newest first,
/// as repository-relative paths.
///
/// Modification time rather than git, because the two answer different
/// questions: git says what differs from a commit, and this says what was
/// being worked on. A file edited and then edited back to what the commit
/// already holds is invisible to the first and is exactly what the second is
/// for.
///
/// Generated output is skipped for the mirror-image reason: one `tom codegen`
/// run stamps every `.freezed.dart` in the workspace at once, and without
/// this the list would be ten files nobody touched.
List<String> _recentFiles(Directory root, int count) {
  final src = Directory('${root.path}/src');
  if (!src.existsSync()) return const [];

  final files = [
    for (final file in _dartFilesUnder(src))
      (modified: file.statSync().modified, path: file.path),
  ]..sort((a, b) => b.modified.compareTo(a.modified));

  return [
    for (final file in files.take(count))
      file.path.substring(root.path.length + 1).replaceAll(r'\', '/'),
  ];
}

/// Every `.dart` file under [dir] that someone could have written.
///
/// Walked by hand rather than with `listSync(recursive: true)` so the skipped
/// directories are never descended into at all: `.dart_tool` alone holds tens
/// of megabytes of cached Dart per package, none of it edited by anyone, and
/// listing it to throw it away is the slow way to get the same answer.
Iterable<File> _dartFilesUnder(Directory dir) sync* {
  for (final entity in dir.listSync(followLinks: false)) {
    if (entity is Directory) {
      final name = entity.path.split(Platform.pathSeparator).last;
      if (name.startsWith('.') || name == 'build' || name == 'coverage') {
        continue;
      }
      yield* _dartFilesUnder(entity);
    } else if (entity is File &&
        entity.path.endsWith('.dart') &&
        !_generated.any(entity.path.endsWith)) {
      yield entity;
    }
  }
}

/// The suffixes build_runner owns — see tool/src/commands/codegen.dart, which
/// deletes by the same two.
const _generated = ['.freezed.dart', '.g.dart'];

Future<List<String>> _changedFiles(Directory root, String base) async {
  final results = await Future.wait([
    Process.run('git', [
      'diff',
      '--name-only',
      '$base...HEAD',
    ], workingDirectory: root.path),
    Process.run('git', [
      'diff',
      '--name-only',
      'HEAD',
    ], workingDirectory: root.path),
    Process.run('git', [
      'ls-files',
      '--others',
      '--exclude-standard',
    ], workingDirectory: root.path),
  ]);

  final files = <String>{};
  for (final r in results) {
    if (r.exitCode != 0) continue;
    files.addAll(
      (r.stdout as String)
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty),
    );
  }
  final sorted = files.toList()..sort();
  return sorted;
}

// The repository root is found by marker now (see ../repo.dart): counting
// levels from this file is what broke when it moved into tool/src/commands/.
