// `tom coverage` — the HTML report, and the threshold gate.
library;

import 'dart:io';

import '../theme/theme.dart';
import 'process.dart';

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

/// Measures [target], builds an HTML report and opens it.
///
/// Unit and integration tests both feed it: coverage is a property of the
/// package's `lib/`, and which folder exercised a line does not change
/// whether it was exercised.
Future<int> runCoverageReport({String target = 'desktop'}) async {
  final directory = directoryFor(target);
  if (!directory.existsSync()) {
    stderr.writeln('tom: no such package "$target"');
    return 66; // EX_NOINPUT
  }

  announce('Coverage — $target');

  final measured = apps.contains(target)
      ? await flutter(['test', '--coverage'], workingDirectory: directory)
      : await _measurePackage(directory);
  if (measured != 0) return measured;

  final lcov = '${directory.path}/coverage/lcov.info';
  final html = '${directory.path}/coverage/html';

  final generated = await exec('genhtml', [
    lcov,
    '--output-directory',
    html,
  ], workingDirectory: directory);
  if (generated != 0) {
    stderr.writeln(
      'tom: genhtml failed or is not installed — it ships with lcov. '
      'The raw data is still at $lcov',
    );
    return generated;
  }

  return _open('$html/index.html');
}

/// `dart test --coverage` leaves a folder of JSON; the report needs lcov, so
/// the format step is part of measuring rather than a separate concern.
Future<int> _measurePackage(Directory directory) async {
  final tested = await dart([
    'test',
    '--coverage=coverage',
  ], workingDirectory: directory);
  if (tested != 0) return tested;

  return dart([
    'run',
    'coverage:format_coverage',
    '--lcov',
    '--in=coverage',
    '--out=coverage/lcov.info',
    '--report-on=lib',
    // Generated code is not written by anyone, so holding it to a coverage
    // threshold measures the generator, not the package.
    '--ignore-files=**.freezed.dart,**.g.dart',
  ], workingDirectory: directory);
}

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
