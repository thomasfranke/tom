// `tom format`, `tom analyze`, and `tom verify` — the PR gate.
library;

import 'dart:io';

import '../repo.dart';
import '../theme/theme.dart';
import 'codegen.dart';
import 'coverage.dart';
import 'process.dart';
import 'tests.dart';

/// Formats every Dart file, failing if anything was not already formatted.
///
/// `--set-exit-if-changed` rather than a plain format: in a gate, "I fixed it
/// for you" and "it was wrong" are the same event, and only the second one
/// can fail a build.
Future<int> runFormat() async {
  announce('Format');
  return dart(['format', '--set-exit-if-changed', 'src', 'tool']);
}

/// Static analysis over the workspace and over the CLI itself.
///
/// Two passes, because they are two analysis contexts. `flutter analyze`
/// resolves the workspace in `src/`; `tool/` is not in it and has no package
/// of its own, so it is analysed on its own terms with its own
/// `analysis_options.yaml` — which is why this file existed for a while
/// formatted by the gate but never analysed by it.
Future<int> runAnalyze() async {
  announce('Analyze — workspace');
  final workspace = await flutter(['analyze'], workingDirectory: srcDirectory);
  if (workspace != 0) return workspace;

  announce('Analyze — CLI');
  // `--fatal-infos`, because every lint this config leaves on was left on to
  // be obeyed. The ones that were not worth obeying are off, and say so.
  return dart(['analyze', '--fatal-infos', 'tool']);
}

/// Everything the PR gate checks, in the order that fails cheapest first.
///
/// Formatting and analysis take seconds and catch the most common mistakes;
/// the codegen gate and the suite take minutes. Stopping at the first failure
/// is the point — a run that reports five failures caused by one of them
/// wastes the time it spent finding the other four.
Future<int> runVerify() async {
  final steps = <String, Future<int> Function()>{
    'format': runFormat,
    'analyze': runAnalyze,
    'codegen gate': runCodegenGate,
    'tests': runTests,
    'coverage gate': runCoverageGate,
  };

  for (final step in steps.entries) {
    final code = await step.value();
    if (code != 0) {
      stdout.writeln();
      stdout.writeln('${palette.detailIcon}✗${Ansi.reset} ${step.key} failed');
      return code;
    }
  }

  stdout.writeln();
  stdout.writeln(
    '${palette.rowEmphasized}✓ Everything CI runs is green'
    '${Ansi.reset}',
  );
  return 0;
}

/// Regenerates everything from scratch and fails if the result differs from
/// what is committed.
///
/// Generated files are committed rather than gitignored, so drift here means
/// what is checked in is not what the annotations actually produce — someone
/// hand-edited a generated file, or changed a source and did not regenerate.
Future<int> runCodegenGate() async {
  announce('Codegen gate');

  final code = await runCodegen(hard: true);
  if (code != 0) return code;

  final drift = await Process.run('git', [
    'status',
    '--porcelain',
    '--',
    '*.freezed.dart',
    '*.g.dart',
  ], workingDirectory: repoRoot().path);

  final changes = (drift.stdout as String).trim();
  if (changes.isEmpty) {
    stdout.writeln('  Generated files match the committed source.');
    return 0;
  }

  stdout
    ..writeln(
      '  Generated files are out of date — commit the regenerated '
      'result:',
    )
    ..writeln(changes);
  return 1;
}
