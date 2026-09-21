// `tom coverage` — the HTML report, and the threshold gate.
library;

import 'dart:io';

import '../theme/theme.dart';
import 'process.dart';
import 'tests.dart';

/// Fails if any implemented package is under the line-coverage threshold.
///
/// A package with nothing under `lib/src` yet, or with code but no tests yet,
/// is skipped rather than counted against — the gate is about code that has
/// tests falling behind, not about code that has not been written.
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
/// Unit and integration tests both feed it: coverage is a property of a
/// package's `lib/`, and which folder exercised a line does not change
/// whether it was exercised.
///
/// The measuring is [runTests]'s, not this command's. It already runs each
/// package's suite with coverage on and writes the lcov beside it — that is
/// where the `◔` on every test row comes from — so measuring again here was
/// a second implementation of one thing, and the one without a progress bar:
/// this command used to print raw test output for minutes with nothing on
/// screen saying how far along it was.
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

  // One report for the whole run, at the workspace root, rather than one per
  // package: genhtml takes every lcov at once and breaks the result down by
  // directory anyway, so a single report is both the combined number and the
  // per-package one — and there is one place to look for it.
  final html = Directory('${srcDirectory.path}/coverage/html');

  // Emptied first, because one directory now holds the report for whatever
  // was last measured. Without this a run over one package leaves the other
  // seven's pages sitting beside it, and a run that fails halfway leaves the
  // half it wrote — both of which read as part of the current report. The
  // measurement is elsewhere; this only ever holds a rendering of it.
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
/// the same reason the HTML is: a copy left by a previous, wider run is not
/// part of this one.
Directory get _rewrittenLcov => Directory('${srcDirectory.path}/coverage/lcov');

/// Measures only what was touched recently, and reports on those files alone.
///
/// The point of it is the suite it does not run. [runCoverageReport] measures
/// every package to answer for one, which is minutes; the question after an
/// edit is about the file that was edited, and the tests it maps to are
/// seconds. [count] defaults to one, because "the file I just changed" is
/// what the command is for — pass more to widen it.
///
/// The report is the run's own, printed as it finishes: coverage per file,
/// least covered first. Nothing is rendered and no browser opens. A page
/// would say the same thing one context switch away, and the answer here is
/// three lines long.
Future<int> runLastCoverage({int? count}) => runLastTests(count: count ?? 1);

/// The same, over everything this branch changed rather than what was edited
/// last. Slower, and the one to run before opening a PR.
Future<int> runDiffCoverage({String? base}) =>
    runChangedTests(base: base ?? 'main');

/// Whether [target]'s lcov was written by the run that started at [since].
///
/// Freshness rather than existence, because a leftover file is worse than no
/// file. The mobile app has no tests, so nothing ever rewrites its
/// `coverage/lcov.info` and it still holds whatever the last run that did
/// produce one left behind — genhtml refuses it outright, since the data
/// points at line 116 of a `main.dart` that now has 51. A layer with no tests
/// yet is the same case seen from the other side: it writes no lcov, and a
/// report should not fail over a package nobody expected to be measured.
bool _measuredSince(String target, DateTime since) {
  final lcov = File('${directoryFor(target).path}/coverage/lcov.info');
  return lcov.existsSync() && !lcov.lastModifiedSync().isBefore(since);
}

/// Rewrites one package's lcov with every source path made absolute, and
/// answers where the rewritten copy is.
///
/// The two measuring tools disagree about how to spell a path.
/// `coverage:format_coverage`, which measures the pure Dart packages, writes
/// absolute ones; `flutter test --coverage`, which measures the apps, writes
/// them relative to the package it ran in — `SF:lib/main.dart`. Either alone
/// is fine. Together they are not: genhtml resolves relative paths against
/// its own single working directory, so combining an app and a package fails
/// on the app's first file, which is what `tom coverage all` hit the moment
/// it was fixed enough to get that far.
///
/// Rewritten into a copy rather than in place: the original belongs to the
/// tool that wrote it, and the coverage gate reads it expecting exactly what
/// that tool produced.
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

/// Opens [path] in whatever the platform uses for that.
///
/// The Makefile hardcoded `open`, which is macOS only — the same POSIX
/// assumption that made `runner-hard` fail on Windows.
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
