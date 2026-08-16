// A live codegen dashboard for `make runner`: one fixed line per package,
// showing which one build_runner is working on right now and what stage
// it's in — driven by parsing build_runner's own log lines. Seven packages
// run back to back otherwise with no sense of progress, just silence until
// each one's full build_runner log dumps out at once.
//
//   dart run tool/run_codegen.dart [--force] <target>...
//
// <target> is a bare package name — a folder under src/packages/ — or
// "desktop"/"mobile" for the Flutter apps. A target with no build_runner
// dependency in its pubspec is shown as skipped rather than silently omitted.
//
// Only packages with changes against BASE (env var, default "main" — same
// convention as `make flutter-test-diff BASE=develop`) actually run;
// everything else is skipped and shown as such. Changes are a 3-way union —
// committed on the branch, staged/modified, or untracked — same as
// tool/run_changed_tests.dart, but resolved package-by-package rather than
// file-by-file: build_runner already processes a whole package in one pass,
// so any change under a package's own tree reruns that whole package, not
// just the files that changed. `--force` skips the diff and runs every
// package regardless — what `make runner-hard` needs after deleting every
// generated file, since a clean regeneration can't depend on the branch
// having touched anything.
//
// build_runner has no JSON event stream the way package:test does (see
// tool/run_tests.dart), so progress here is coarser: which package is
// running and which named stage its log is currently on ("Running build...",
// "Succeeded after 4.2s with 63 outputs"), not a file-by-file count.
//
// No external packages — only dart:async, dart:convert, dart:io — so it
// runs with nothing but the SDK already on the machine, from any directory.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _pkgOrder = [
  'core',
  'domain',
  'application',
  'infra',
  'data',
  'presentation',
];

const _apps = ['desktop', 'mobile'];

const _spinner = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

void main(List<String> rawArgs) async {
  final force = rawArgs.contains('--force');
  final args = rawArgs.where((a) => a != '--force').toList();
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tool/run_codegen.dart [--force] <pkg>...');
    exit(64);
  }

  final root = _repoRoot();
  final src = Directory('${root.path}/src');
  final base = Platform.environment['BASE'] ?? 'main';
  final diff = force ? null : await _changedPackages(root, base);
  final changed = diff?.packages;

  final targets = args.map((a) => _resolve(src, a)).toList();
  final rows = [
    for (final t in targets) _Row(t.label, hasBuildRunner: _hasBuildRunner(t)),
  ];
  for (final row in rows) {
    if (!row.hasBuildRunner) {
      row.state = _RowState.skippedNoBuildRunner;
    } else if (changed != null && !changed.contains(row.label)) {
      row.state = _RowState.skippedNoChange;
    }
  }

  stdout.writeln(
    force
        ? '• Forcing every package'
        : '• Diffing against $base — ${diff!.fileCount} file(s) changed',
  );

  final dashboard = _Dashboard(rows, DateTime.now());
  dashboard.render();
  final ticker = Timer.periodic(
    const Duration(milliseconds: 250),
    (_) => dashboard.render(),
  );

  var overallFail = false;
  for (var i = 0; i < targets.length; i++) {
    final row = rows[i];
    if (row.state != _RowState.queued) continue;
    row.state = _RowState.running;
    row.startedAt = DateTime.now();
    dashboard.render();
    final ok = await _runOne(targets[i], row, dashboard);
    row.state = _RowState.done;
    row.elapsed = DateTime.now().difference(row.startedAt!);
    if (!ok) overallFail = true;
    dashboard.render();
  }

  ticker.cancel();
  dashboard.render();

  final failedRows = rows.where((r) => r.failed).toList();
  final totalOutputs = rows.fold(0, (a, r) => a + (r.outputs ?? 0));
  final totalElapsed = _fmtDuration(
    DateTime.now().difference(dashboard.started),
  );

  stdout.writeln();
  stdout.writeln(
    failedRows.isEmpty
        ? '  • Summary: 🟢 all packages succeeded'
        : '  • Summary: 🔴 ${failedRows.length} package(s) failed',
  );
  stdout.writeln('    • $totalOutputs file(s) written by codegen');
  stdout.writeln('    • ⏱ $totalElapsed');

  if (failedRows.isNotEmpty) {
    stdout.writeln();
    stdout.writeln('🔴 Failed:');
    for (final row in failedRows) {
      if (row.failedFiles.isEmpty) {
        stdout.writeln('  ${row.label}');
      } else {
        for (final file in row.failedFiles) {
          stdout.writeln('  ${row.label} — $file');
        }
      }
    }
  }

  exit(overallFail ? 1 : 0);
}

class _Target {
  _Target(this.label, this.dir);
  final String label;
  final Directory dir;
}

_Target _resolve(Directory src, String pkg) {
  if (_apps.contains(pkg)) {
    return _Target(pkg, Directory('${src.path}/apps/$pkg'));
  }
  if (!_pkgOrder.contains(pkg)) {
    stderr.writeln(
      "Unknown package '$pkg'. Available: ${_pkgOrder.join(', ')}, "
      "${_apps.join(', ')}",
    );
    exit(64);
  }
  return _Target(pkg, Directory('${src.path}/packages/$pkg'));
}

Directory _repoRoot() {
  // tool/run_codegen.dart -> tool/ -> repo root, regardless of cwd.
  final scriptDir = File(Platform.script.toFilePath()).parent;
  return scriptDir.parent;
}

bool _hasBuildRunner(_Target target) {
  final pubspec = File('${target.dir.path}/pubspec.yaml');
  return pubspec.existsSync() &&
      pubspec.readAsStringSync().contains('build_runner');
}

/// Which package labels ("core", ..., "desktop", "mobile") own at least one changed
/// file against `base`. Same 3-way diff union as
/// tool/run_changed_tests.dart's `_changedFiles` (committed on the branch,
/// staged/modified, or untracked), but mapped to a whole package rather than
/// individual test files — build_runner has no finer unit to run than that.
Future<({Set<String> packages, int fileCount})> _changedPackages(
  Directory root,
  String base,
) async {
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

  final packages = <String>{};
  for (final path in files) {
    final pkgMatch = RegExp(r'^src/packages/([^/]+)/').firstMatch(path);
    if (pkgMatch != null && _pkgOrder.contains(pkgMatch.group(1))) {
      packages.add(pkgMatch.group(1)!);
      continue;
    }
    for (final app in _apps) {
      if (path.startsWith('src/apps/$app/')) packages.add(app);
    }
  }
  return (packages: packages, fileCount: files.length);
}

enum _RowState { queued, skippedNoBuildRunner, skippedNoChange, running, done }

/// One line of the fixed dashboard, mutated in place as its package's
/// build_runner run progresses.
class _Row {
  _Row(this.label, {required this.hasBuildRunner});
  final String label;
  final bool hasBuildRunner;

  _RowState state = _RowState.queued;
  DateTime? startedAt;
  Duration? elapsed;

  String stage = 'starting…';
  int? outputs;
  bool failed = false;
  final Set<String> failedFiles = {};
}

// build_runner's own log lines, e.g.:
//   [INFO] Running build completed, took 2.3s
//   [INFO] Succeeded after 6.6s with 63 outputs (63 actions)
//   [SEVERE] some_builder on lib/src/foo.dart:
//   [SEVERE] Failed after 1.2s
final _logLevel = RegExp(r'^\[([A-Z]+)\]\s*');
final _stageDone = RegExp(r'^(.*?) completed, took ([\d.]+m?s)$');
// Older build_runner: "Succeeded after 6.6s with 63 outputs (63 actions)".
// 2.15+'s AOT runner: "Built with build_runner/aot in 0s; wrote 63 outputs."
final _succeeded = RegExp(
  r'(?:Succeeded after [\d.]+m?s with (\d+) outputs|wrote (\d+) outputs)',
);
final _failedLine = RegExp(r'^(Failed after|Build failed)');
final _failingFile = RegExp(r'\bon\s+(\S+\.dart)\b');

/// Runs one package's `build_runner build`, streaming its log lines into
/// `row.stage` and letting `dashboard` redraw after every line. Returns
/// false if the run failed.
Future<bool> _runOne(_Target target, _Row row, _Dashboard dashboard) async {
  // build_runner 2.15 dropped --delete-conflicting-outputs (it's the default
  // now) and warns on every run if passed — see the note by _succeeded above
  // on why its final log line changed shape too.
  final process = await Process.start('dart', [
    'run',
    'build_runner',
    'build',
  ], workingDirectory: target.dir.path);

  void handleLine(String line) {
    final text = line.trim();
    if (text.isEmpty) return;
    final level = _logLevel.firstMatch(text)?.group(1);
    final message = text.replaceFirst(_logLevel, '');

    final succeeded = _succeeded.firstMatch(message);
    if (succeeded != null) {
      row.outputs = int.tryParse(succeeded.group(1) ?? succeeded.group(2)!);
    }
    if (_failedLine.hasMatch(message) || level == 'SEVERE') {
      row.failed = true;
      final failingFile = _failingFile.firstMatch(message)?.group(1);
      if (failingFile != null) row.failedFiles.add(failingFile);
      dashboard.log('  🔴 ${target.label} — $message');
    }

    final stageDone = _stageDone.firstMatch(message);
    row.stage = stageDone != null ? '${stageDone.group(1)} done' : message;
    dashboard.render();
  }

  process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen(handleLine);
  process.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen(handleLine);

  final exitCode = await process.exitCode;
  return exitCode == 0 && !row.failed;
}

/// Redraws a fixed block — a header plus one row per package — in place,
/// making room above it for failures printed live via [log].
class _Dashboard {
  _Dashboard(this.rows, this.started)
    : _labelWidth = rows
          .map((r) => r.label.length)
          .reduce((a, b) => a > b ? a : b);

  final List<_Row> rows;
  final DateTime started;
  final int _labelWidth;
  int _paintedLines = 0;
  int _tick = 0;

  void render() {
    _tick++;
    _erase();
    final lines = [_header(), ...rows.map(_renderRow)];
    stdout.writeln(lines.join('\n'));
    _paintedLines = lines.length;
  }

  void log(String text) {
    _erase();
    stdout.writeln(text);
    render();
  }

  void _erase() {
    if (_paintedLines == 0) return;
    stdout.write('\x1B[${_paintedLines}A\x1B[J');
    _paintedLines = 0;
  }

  String _header() {
    final doneCount = rows
        .where(
          (r) =>
              r.state == _RowState.done ||
              r.state == _RowState.skippedNoBuildRunner ||
              r.state == _RowState.skippedNoChange,
        )
        .length;

    if (doneCount == rows.length) {
      return '• Running codegen — $doneCount/${rows.length} packages:';
    }

    _Row? running;
    for (final r in rows) {
      if (r.state == _RowState.running) {
        running = r;
        break;
      }
    }
    if (running == null) {
      return '• Running codegen — $doneCount/${rows.length} packages:';
    }
    return '• Running codegen — $doneCount/${rows.length} packages, '
        'now on ${running.label}:';
  }

  String _renderRow(_Row row) {
    final label = row.label.padRight(_labelWidth);
    switch (row.state) {
      case _RowState.skippedNoBuildRunner:
        return '  🟠 $label  no build_runner';
      case _RowState.skippedNoChange:
        return '  🔵 $label  skipped — no change in this branch';
      case _RowState.queued:
        return '  ⚪ $label  queued';
      case _RowState.running:
        final spin = _spinner[_tick % _spinner.length];
        final elapsed = _fmtDuration(DateTime.now().difference(row.startedAt!));
        return '  🟡 $label  $spin ${row.stage}  •  ⏱ $elapsed';
      case _RowState.done:
        final elapsed = _fmtDuration(row.elapsed ?? Duration.zero);
        final icon = row.failed ? '🔴' : '🟢';
        final outputs = row.outputs != null ? '${row.outputs} outputs  ' : '';
        return '  $icon $label  $outputs⏱ $elapsed';
    }
  }
}

String _fmtDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return m > 0 ? '${m}m${s.toString().padLeft(2, '0')}s' : '${s}s';
}
