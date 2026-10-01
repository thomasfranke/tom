// A live codegen dashboard, one line per package, read off build_runner's log.
//
//   dart run tool/src/commands/run_codegen.dart [--force] <target>...
//
// Only packages changed against BASE (env var, default "main") run, whole,
// because build_runner has no finer unit; `--force` runs every one of them.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../cli/dashboard.dart';
import '../repo.dart';
import '../theme/theme.dart';
import '../tty.dart';
import 'process.dart';

// Every package, the ones with no generator included — `_hasBuildRunner`
// skips those. An unknown target fails the run *after* `tom codegen --hard`
// has deleted the output it was about to rebuild.
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

void main(List<String> rawArgs) async {
  final force = rawArgs.contains('--force');
  final args = rawArgs.where((a) => a != '--force').toList();
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/src/commands/run_codegen.dart [--force] <pkg>...',
    );
    exit(64);
  }

  final root = repoRoot();
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
  // No ticker without a terminal: its only job is to advance a spinner in
  // place, and in a log it would print the same frame four times a second.
  final ticker = isPlain
      ? null
      : Timer.periodic(
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

  ticker?.cancel();
  dashboard.render();

  final failedRows = rows.where((r) => r.failed).toList();
  final totalOutputs = rows.fold(0, (a, r) => a + (r.outputs ?? 0));
  final totalElapsed = formatDuration(
    DateTime.now().difference(dashboard.started),
  );

  stdout.writeln();
  stdout.writeln(
    failedRows.isEmpty
        ? '  • Summary: ${palette.ok}${Status.ok}${Ansi.reset} '
              'all packages succeeded'
        : '  • Summary: ${palette.fail}${Status.fail}${Ansi.reset} '
              '${failedRows.length} package(s) failed',
  );
  stdout.writeln('    • $totalOutputs file(s) written by codegen');
  stdout.writeln('    • ⏱ $totalElapsed');

  if (failedRows.isNotEmpty) {
    stdout.writeln();
    stdout.writeln('${palette.fail}${Status.fail}${Ansi.reset} Failed:');
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

bool _hasBuildRunner(_Target target) {
  final pubspec = File('${target.dir.path}/pubspec.yaml');
  return pubspec.existsSync() &&
      pubspec.readAsStringSync().contains('build_runner');
}

/// The package labels that own at least one file changed against [base]: the
/// same three-way diff as run_changed_tests.dart, mapped to whole packages.
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

/// Runs one package's `build_runner build`, streaming its log into [row];
/// false when the run failed.
Future<bool> _runOne(_Target target, _Row row, _Dashboard dashboard) async {
  // No --delete-conflicting-outputs: build_runner 2.15 made it the default
  // and warns on every run if passed.
  final process = await Process.start(dartExecutable, [
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
      dashboard.log(
        '  ${palette.fail}${Status.fail}${Ansi.reset}  ${target.label} '
        '— $message',
      );
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
class _Dashboard extends Dashboard<_Row> {
  _Dashboard(super.rows, super.started);

  @override
  String labelOf(_Row row) => row.label;

  @override
  bool isSettled(_Row row) =>
      row.state != _RowState.queued && row.state != _RowState.running;

  @override
  String header() {
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

  @override
  String renderRow(_Row row) {
    final label = row.label.padRight(labelWidth);
    switch (row.state) {
      case _RowState.skippedNoBuildRunner:
        return '${statusMark(Status.skipped, palette.skipped)}$label  '
            'no build_runner';
      case _RowState.skippedNoChange:
        return '${statusMark(Status.skipped, palette.skipped)}$label  '
            'skipped — no change in this branch';
      case _RowState.queued:
        return '${statusMark(Status.queued, palette.queued)}$label  queued';
      case _RowState.running:
        final spin = spinnerFrames[tick % spinnerFrames.length];
        final elapsed = formatDuration(
          DateTime.now().difference(row.startedAt!),
        );
        return '${statusMark(Status.running, palette.running)}$label  '
            '$spin ${row.stage}  •  ⏱ $elapsed';
      case _RowState.done:
        final elapsed = formatDuration(row.elapsed ?? Duration.zero);
        final mark = row.failed
            ? statusMark(Status.fail, palette.fail)
            : statusMark(Status.ok, palette.ok);
        final outputs = row.outputs != null ? '${row.outputs} outputs  ' : '';
        return '$mark$label  $outputs⏱ $elapsed';
    }
  }
}
