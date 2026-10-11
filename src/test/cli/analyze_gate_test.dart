/// The analysis gate: what it asks of the analyser, written out where a test
/// can hold it.
///
/// A lint that does not break the gate is a lint nobody obeys, so the flags
/// that make an info or a warning fatal are pinned here, and the pipeline is
/// held to call the same command.
library;

import 'dart:io';

import 'package:test/test.dart';

import '../../../tool/src/commands/quality.dart';

void main() {
  test('the workspace pass makes an info and a warning fatal', () {
    expect(workspaceAnalyzeFlags, contains('--fatal-infos'));
    expect(workspaceAnalyzeFlags, contains('--fatal-warnings'));
  });

  test('the CLI pass keeps --fatal-infos', () {
    final String source = File(
      '../tool/src/commands/quality.dart',
    ).readAsStringSync();
    expect(source, contains("dart(['analyze', '--fatal-infos', 'tool'])"));
  });

  test('the pipeline calls the same command the gate runs', () {
    final String workflow = File(
      '../.github/workflows/pr-checks.yml',
    ).readAsStringSync();
    expect(workflow, contains('make analyze'));
  });
}
