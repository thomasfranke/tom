// Maps changed files to the `_test.dart` files named after them, then hands
// that list to run_tests.dart (the mapping rule: `runChangedTests` in
// tests.dart). BASE defaults to `$BASE`, then `main`.
//
//   dart run tool/src/commands/run_changed_tests.dart [--coverage] [BASE]
//   dart run tool/src/commands/run_changed_tests.dart [--coverage] --last=N

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

  // Here rather than in run_tests.dart: the diff and the test/ walks below
  // are the slow part, and run_tests.dart skips its own under --no-banner.
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
    // src/test/ holds tests for two things that are not a package: the layer
    // graph, and the CLI — which a change under tool/ maps to as well.
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

  // A mapped path can be a test file the diff deleted, and run_tests.dart
  // must not be handed a path that does not exist.
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

  // The dashboard's `◔` is the whole package's, measured by whatever subset
  // just ran; the number worth having here is the one for the files the run
  // was narrowed to.
  if (coverage && code == 0) {
    _reportCoverageOf(_sourcesAmong(changed, root), root);
  }

  exit(code);
}

/// The production files a coverage number is about, given what changed.
///
/// A changed `lib/foo.dart` is itself what was measured; a changed
/// `foo_test.dart` stands for the `foo.dart` found by name under the same
/// package — the direction that matters right after writing a test.
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

/// The line coverage of [sources], printed file by file, worst first.
///
/// Read out of the lcov each package just wrote rather than measured again.
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

  // Least covered first, because on a long list the top is the only place
  // read.
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

  // Apart and with the reason: a barrel or a bare enum declares no executable
  // line, so counting it as zero would understate and dropping it overstate.
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
/// Two spellings are matched: `format_coverage` writes absolute paths for the
/// pure Dart packages, `flutter test --coverage` package-relative ones.
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

/// A live "compiling" ticker over the setup, so the terminal is not silent.
///
/// The floor delay keeps it on screen for a beat when setup is instant;
/// duplicated from run_tests.dart, which skips its own under `--no-banner`.
Future<void> _showCompiling() async {
  stdout.writeln('• Running build hooks...');

  // Nobody watches a log, so in plain mode the line above is the whole banner.
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

/// How many files `--last` takes when it is not given a number — about a
/// sitting's worth of work.
const _defaultLastCount = 10;

/// The [count] most recently edited source files under `src/`, newest first,
/// as repository-relative paths.
///
/// Modification time rather than git: git says what differs from a commit,
/// this says what was being worked on. Generated output is skipped because
/// one `tom codegen` stamps every `.freezed.dart` in the workspace at once.
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
/// Walked by hand so the skipped directories are never descended into:
/// `.dart_tool` alone holds tens of megabytes per package.
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

/// The suffixes build_runner owns, the same two codegen.dart deletes by.
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
