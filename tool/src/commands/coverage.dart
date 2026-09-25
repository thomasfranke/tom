// `tom coverage` — the HTML report, and the threshold gate.
library;

import 'dart:io';

import '../theme/theme.dart';
import 'process.dart';
import 'tests.dart';

/// Fails if any gated package is under the line-coverage threshold; which
/// packages are gated is coverage_gate.dart's to say.
Future<int> runCoverageGate({int? threshold}) async {
  announce('Coverage gate');
  return dart([
    'run',
    'tool/src/commands/coverage_gate.dart',
    if (threshold != null) '--threshold=$threshold',
  ]);
}

/// Measures [targets], builds one HTML report out of all of them, opens it.
///
/// The measuring is [runTests]'s: it already writes each package's lcov
/// beside it, and a second measurement here would be the one without a
/// progress bar.
Future<int> runCoverageReport({List<String> targets = allTargets}) async {
  final unknown = targets.where((t) => !directoryFor(t).existsSync()).toList();
  if (unknown.isNotEmpty) {
    stderr.writeln('tom: no such package "${unknown.first}"');
    return 66; // EX_NOINPUT
  }

  // Before the run, so a file written during it can be told from one that was
  // already there.
  final startedAt = DateTime.now();
  final measured = await runTests(targets: targets);
  if (measured != 0) return measured;

  if (_rewrittenLcov.existsSync()) {
    _rewrittenLcov.deleteSync(recursive: true);
  }
  final lcov = [
    for (final target in targets)
      if (_measuredSince(target, startedAt)) _absolutePaths(target),
  ];

  if (lcov.isEmpty) {
    stderr.writeln(
      'tom: nothing was measured — none of those packages has tests yet',
    );
    return 66;
  }

  // One report at the workspace root: genhtml takes every lcov at once and
  // breaks it down by directory, so one report is also the per-package one.
  final html = Directory('${srcDirectory.path}/coverage/html');

  // Emptied first: the directory holds the report of whatever was last
  // measured, and a run over one package would leave the other seven's pages
  // beside it.
  if (html.existsSync()) html.deleteSync(recursive: true);

  announce('Coverage report — ${lcov.length} package(s)');
  final generated = await exec('genhtml', [
    ...lcov,
    '--output-directory',
    html.path,
  ]);
  if (generated != 0) {
    stderr.writeln(
      'tom: genhtml failed or is not installed — it ships with lcov. '
      'The raw data is still beside each package, in coverage/lcov.info',
    );
    return generated;
  }

  return _open('${html.path}/index.html');
}

/// Where the rewritten copies go, emptied at the start of every report for
/// the same reason the HTML is.
Directory get _rewrittenLcov => Directory('${srcDirectory.path}/coverage/lcov');

/// Measures only what was touched recently, and reports on those files alone.
///
/// [runCoverageReport] measures every package to answer for one, which is
/// minutes; the tests an edited file maps to are seconds. [count] defaults to
/// one, and nothing is rendered: the answer is three lines long.
Future<int> runLastCoverage({int? count}) => runLastTests(count: count ?? 1);

/// The same, over everything this branch changed rather than what was edited
/// last. Slower, and the one to run before opening a PR.
Future<int> runDiffCoverage({String? base}) =>
    runChangedTests(base: base ?? 'main');

/// Whether [target]'s lcov was written by the run that started at [since].
///
/// Freshness rather than existence: a package with no tests never rewrites
/// its lcov, and genhtml refuses a stale one whose line numbers no longer
/// exist.
bool _measuredSince(String target, DateTime since) {
  final lcov = File('${directoryFor(target).path}/coverage/lcov.info');
  return lcov.existsSync() && !lcov.lastModifiedSync().isBefore(since);
}

/// One package's lcov with every source path made absolute, at a new path.
///
/// `format_coverage` writes absolute paths and `flutter test --coverage`
/// package-relative ones, which genhtml resolves against its own working
/// directory; a copy rather than in place, since the gate reads the original
/// as its tool wrote it.
String _absolutePaths(String target) {
  final directory = directoryFor(target);
  final source = File('${directory.path}/coverage/lcov.info');
  final rewritten = File('${_rewrittenLcov.path}/$target.info')
    ..parent.createSync(recursive: true);

  rewritten.writeAsStringSync(
    source
        .readAsLinesSync()
        .map((line) {
          if (!line.startsWith('SF:')) return line;
          final path = line.substring(3);
          return _isAbsolute(path) ? line : 'SF:${directory.path}/$path';
        })
        .join('\n'),
  );
  return rewritten.path;
}

/// Whether [path] is already absolute, on either kind of machine — a leading
/// separator, or a drive letter.
bool _isAbsolute(String path) =>
    path.startsWith('/') || RegExp(r'^[A-Za-z]:').hasMatch(path);

/// Opens [path] in whatever the platform uses for that; `open` is macOS only.
Future<int> _open(String path) async {
  final (executable, arguments) = switch (Platform.operatingSystem) {
    'macos' => ('open', [path]),
    'windows' => ('cmd', ['/c', 'start', '', path]),
    _ => ('xdg-open', [path]),
  };

  final code = await exec(executable, arguments);
  if (code != 0) {
    stdout.writeln('${palette.prompt}Report at $path${Ansi.reset}');
  }
  return 0;
}
