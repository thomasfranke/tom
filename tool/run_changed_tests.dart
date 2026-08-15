// Maps a git diff against BASE to the specific *_test.dart files it should
// re-run, then hands that off to tool/run_tests.dart to execute and render.
//
//   dart run tool/run_changed_tests.dart [--coverage] [BASE]
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

const _pkgOrder = [
  'core',
  'domain',
  'application',
  'infra',
  'data',
  'presentation',
];

void main(List<String> args) async {
  final coverage = args.contains('--coverage');
  final rest = args.where((a) => a != '--coverage').toList();
  final base = rest.isNotEmpty ? rest.first : Platform.environment['BASE'] ?? 'main';

  // Shown here rather than left to tool/run_tests.dart, since this script's
  // own setup — the git diff, walking each package's test/ for a filename
  // match — is the part that can actually take a moment on a large diff.
  await _showCompiling();

  final root = _repoRoot();
  final changed = await _changedFiles(root, base);
  if (changed.isEmpty) {
    print('No changes against $base.');
    exit(0);
  }

  final testFiles = <String, Set<String>>{}; // package label -> relative paths
  var wantArch = false;
  for (final path in changed) {
    if (path == 'src/pubspec.yaml' || path.startsWith('src/test/')) {
      wantArch = true;
      continue;
    }

    final pkgMatch = RegExp(
      r'^src/packages/([^/]+)/(lib|test)/(.+)$',
    ).firstMatch(path);
    final desktopMatch = RegExp(
      r'^src/apps/desktop/(lib|test)/(.+)$',
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
    } else if (desktopMatch != null) {
      label = 'desktop';
      pkgDir = Directory('${root.path}/src/apps/desktop');
      kind = desktopMatch.group(1)!;
      sub = desktopMatch.group(2)!;
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
    final testName = '${name.substring(0, name.length - '.dart'.length)}_test.dart';
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
    final pkgDir = label == 'desktop'
        ? Directory('${root.path}/src/apps/desktop')
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

  if (testFiles.isEmpty && !wantArch) {
    print('Changed files against $base map to no test.');
    exit(0);
  }

  final specs = [
    if (wantArch) 'arch',
    for (final e in testFiles.entries) '${e.key}=${e.value.join(',')}',
  ];

  stdout.writeln('Changed files: ${changed.length}');

  final process = await Process.start(
    'dart',
    [
      'run',
      'tool/run_tests.dart',
      '--no-banner',
      if (coverage) '--coverage',
      ...specs,
    ],
    workingDirectory: root.path,
    mode: ProcessStartMode.inheritStdio,
  );
  exit(await process.exitCode);
}

/// A brief banner shown before setup, covering it with a live "compiling"
/// ticker instead of a silent terminal. The floor delay keeps it visible for
/// a beat even when setup is instant — otherwise it would flash and vanish,
/// which reads as nothing having happened at all. Duplicated from
/// tool/run_tests.dart rather than shared: each entry point shows its own,
/// and tool/run_tests.dart skips it (`--no-banner`) when this one already ran.
Future<void> _showCompiling() async {
  stdout.writeln('• Running build hooks...');
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
  await Future.delayed(const Duration(milliseconds: 300));
  ticker.cancel();
  stdout.write('\r\x1B[K');
}

Future<List<String>> _changedFiles(Directory root, String base) async {
  final results = await Future.wait([
    Process.run('git', [
      'diff',
      '--name-only',
      '$base...HEAD',
    ], workingDirectory: root.path),
    Process.run('git', ['diff', '--name-only', 'HEAD'], workingDirectory: root.path),
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
      (r.stdout as String).split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty),
    );
  }
  final sorted = files.toList()..sort();
  return sorted;
}

Directory _repoRoot() {
  // tool/run_changed_tests.dart -> tool/ -> repo root, regardless of cwd.
  final scriptDir = File(Platform.script.toFilePath()).parent;
  return scriptDir.parent;
}
