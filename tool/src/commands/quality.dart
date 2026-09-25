// `tom format`, `tom analyze`, and `tom verify` — the PR gate.
library;

import 'dart:io';

import '../repo.dart';
import '../theme/theme.dart';
import 'codegen.dart';
import 'coverage.dart';
import 'process.dart';
import 'rules.dart';
import 'tests.dart';

/// Formats every Dart file, failing if anything was not already formatted:
/// in a gate, "I fixed it for you" is the wrong answer.
Future<int> runFormat() async {
  announce('Format');
  return dart(['format', '--set-exit-if-changed', 'src', 'tool']);
}

/// Static analysis over the workspace and over the CLI itself — two passes,
/// because `tool/` is not in the workspace and is analysed on its own
/// `analysis_options.yaml`.
Future<int> runAnalyze() async {
  announce('Analyze — workspace');
  final workspace = await flutter(['analyze'], workingDirectory: srcDirectory);
  if (workspace != 0) return workspace;

  announce('Analyze — CLI');
  // `--fatal-infos`, because every lint this config leaves on was left on to
  // be obeyed. The ones that were not worth obeying are off, and say so.
  return dart(['analyze', '--fatal-infos', 'tool']);
}

/// Everything the PR gate checks, in the order that fails cheapest first;
/// stopping at the first failure is the point.
Future<int> runVerify() async {
  final steps = <String, Future<int> Function()>{
    'format': runFormat,
    'analyze': runAnalyze,
    'rules': runRules,
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
/// what is committed: generated files are committed, so drift means someone
/// hand-edited one or did not regenerate.
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
