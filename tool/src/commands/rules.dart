// `tom rules` — the catalogue of rule files, and the run that checks them.
//
// The rules themselves live one theme per file in `src/rules/`, which holds
// nothing else: a row on the menu is a file there, so a break names what to
// open. This is the list both faces read, and the record of what each one
// last said.
library;

import 'dart:convert';
import 'dart:io';

import '../cli/dashboard.dart';
import '../repo.dart';
import '../rule.dart';
import '../rules/comment_rules.dart';
import '../rules/data_layer_rules.dart';
import '../rules/infrastructure_rules.dart';
import '../rules/naming_rules.dart';
import '../theme/theme.dart';
import '../tty.dart';
import 'e2e_catalogue.dart' show appVersion, describeElapsed, describeWhen;
import 'process.dart';

/// The rule files, alphabetically — the order the menu lists them and the
/// order `--help` prints them, so a row is found by name.
const catalogue = <RuleFile>[
  (
    name: 'comments',
    label: 'Comment Rules',
    file: 'comment_rules.dart',
    description:
        'A comment is two or three lines, and twelve is the ceiling on the '
        'exception. A ratchet rather than a ban: what is already over the '
        'ceiling is a budget that never rises, so nothing new gets in and '
        'every trim lowers it.',
    checks: <Rule>[commentsHaveACeiling],
  ),
  (
    name: 'data-layer',
    label: 'Data Layer Rules',
    file: 'data_layer_rules.dart',
    description:
        'Which half of tom_data does what (Decision 25). A repository holds '
        'no capability — it orchestrates, converts and translates; a data '
        'source names no domain type — it obtains. The same boundary read '
        'from either side.',
    checks: <Rule>[repositoriesReadThroughDataSources, dataSourcesKnowNoDomain],
  ),
  (
    name: 'infrastructure',
    label: 'Infrastructure Rules',
    file: 'infrastructure_rules.dart',
    description:
        'The shape of tom_infra (Decision 24). A capability is a folder '
        'holding its contract, its failures and one subfolder per way of '
        'doing it, with nothing loose beside it — and the barrel is that '
        "folder's whole contents, so what another package can see is "
        'answered by listing it.',
    checks: <Rule>[capabilitiesAreFolders, barrelIsWholeOfSrc],
  ),
  (
    name: 'naming',
    label: 'Naming Rules',
    file: 'naming_rules.dart',
    description:
        'What a name has to say. An implementation is <How>Impl in '
        '<how>_impl.dart (Decision 24); a failure variant carries its '
        "hierarchy's prefix, so two hierarchies naming the same concept "
        'cannot collide; a domain type says whether it is an entity or a '
        'value object (Decision 23).',
    checks: <Rule>[
      implementationsSaySo,
      failuresCarryTheirPrefix,
      domainTypesSayWhichKind,
    ],
  ),
];

/// The entry named [name], or null when nothing is.
RuleFile? ruleFileNamed(String name) {
  for (final entry in catalogue) {
    if (entry.name == name) return entry;
  }
  return null;
}

/// Runs the rules of [only], or every file's when it is null.
///
/// Everything runs in full rather than stopping at the first break: these
/// are cheap and independent, and a list of every rename to do beats five
/// runs that each report one.
Future<int> runRules([String? only]) async {
  final chosen = only == null ? catalogue : <RuleFile>[?ruleFileNamed(only)];
  if (chosen.isEmpty) {
    stderr.writeln('No rule file is called "$only".');
    return 64;
  }

  announce(only == null ? 'Rules' : ruleFileNamed(only)!.label);
  final root = repoRoot();
  final version = appVersion();
  var failed = false;

  final progress = _Progress(chosen.length);
  for (var index = 0; index < chosen.length; index++) {
    final entry = chosen[index];
    // Drawn before the file runs, so the name on the bar is the one being
    // checked rather than the one just finished.
    progress.show(entry.label);

    final started = DateTime.now();
    final found = <Offence>[for (final check in entry.checks) ...check(root)];
    final over = _budgetOverrunOf(entry, found);
    final broke = over ?? found.isNotEmpty;

    writeRuleResult(entry.name, (
      passed: !broke,
      when: started.toUtc(),
      version: version,
      offences: found.length,
      elapsed: DateTime.now().difference(started),
    ));

    progress.settle(broke: broke);
    if (!broke) continue;
    failed = true;
    // Above the bar, so the breaks accumulate while it keeps moving.
    progress.log(
      <String>[
        for (final offence in found)
          '${palette.detailIcon}✗${Ansi.reset} ${offence.rule}\n'
              '  ${entry.file} · ${offence.where}\n'
              '  ${offence.detail}',
      ].join('\n'),
    );
  }
  progress.clear();

  stdout.writeln();
  if (failed) {
    stdout.writeln('Fix them, or say why in the rule that objects.');
    return 1;
  }
  stdout.writeln(
    '${palette.rowEmphasized}✓ Every rule holds${Ansi.reset}'
    '${_budgetNote(chosen, root)}',
  );
  return 0;
}

/// Where a run of every rule file has got to, repainted where it stands.
///
/// The end-to-end suite's block, in miniature and for the same reason: a run
/// reads as one thing rather than a stack of unrelated ones, and the
/// question someone actually has — *is this going well?* — is answered
/// without scrolling. One bar, never one line per file, because four
/// finished names say nothing the summary will not say better.
///
/// In a log there is no cursor to rewind, so it draws nothing: what carries
/// the run there is the breaks, which are printed either way.
final class _Progress {
  _Progress(this.total) : _started = DateTime.now();

  /// How many files this run covers.
  final int total;

  final DateTime _started;
  int _done = 0;
  int _broken = 0;
  int _lines = 0;

  /// Repaints with [label] as the file now being checked.
  void show(String label) {
    if (isPlain) return;
    _erase();
    final percent = total == 0 ? 0 : ((_done / total) * 100).round();
    final broken = _broken == 0
        ? ''
        : '   ${palette.fail}✘ $_broken${Ansi.reset}';
    final lines = <String>[
      '  ${palette.section}Rules${Ansi.reset}  ${palette.detail}'
          '·  ${_done + 1}/$total  ·  ${_clock()}${Ansi.reset}',
      '',
      '  ${_bar(percent)}  ${palette.detail}$percent%${Ansi.reset}$broken'
          '   ${palette.detail}$label${Ansi.reset}',
    ];
    stdout.writeln(lines.join('\n'));
    _lines = lines.length;
  }

  /// Records that the file just checked was clean, or was not.
  void settle({required bool broke}) {
    _done++;
    if (broke) _broken++;
  }

  /// Writes [text] above the block, so it survives the next repaint.
  void log(String text) {
    if (isPlain) {
      stdout.writeln(text);
      return;
    }
    _erase();
    stdout.writeln(text);
  }

  /// Takes the block down, leaving what was logged above it.
  void clear() => _erase();

  /// The bar, drawn as a filled block so it reads at a glance.
  String _bar(int percent) {
    final filled = ((barWidth * percent) / 100).round().clamp(0, barWidth);
    return '${palette.prompt}${'█' * filled}${Ansi.reset}'
        '${palette.detail}${'░' * (barWidth - filled)}${Ansi.reset}';
  }

  /// `00:03`, which is how long a person reads a stopwatch as.
  String _clock() {
    final d = DateTime.now().difference(_started);
    return '${d.inMinutes.toString().padLeft(2, '0')}:'
        '${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void _erase() {
    if (isPlain || _lines == 0) return;
    stdout.write('\x1B[${_lines}A\x1B[J');
    _lines = 0;
  }
}

/// Whether [found] breaks the comment budget, or null when it is not one.
///
/// The ceiling is a ratchet rather than a ban, so its offences are a count
/// to keep down and not a build to break — until the count rises.
bool? _budgetOverrunOf(RuleFile entry, List<Offence> found) =>
    entry.checks.contains(commentsHaveACeiling)
    ? found.length > commentBudget
    : null;

/// How much of the comment backlog is left, when that file ran.
String _budgetNote(List<RuleFile> chosen, Directory root) {
  if (!chosen.any((entry) => entry.checks.contains(commentsHaveACeiling))) {
    return '';
  }
  final left = commentsHaveACeiling(root).length;
  return '  ($left/$commentBudget comments still over the ceiling)';
}

/// What one rule file last said.
typedef RuleResult = ({
  bool passed,
  DateTime when,
  String version,
  int offences,
  Duration elapsed,
});

/// Where the record of what ran is kept.
///
/// Beside the results of the end-to-end scenarios and for the same reason:
/// the list is read to answer *has this been checked since?*, and a record
/// that anything rebuilds cannot answer it.
const ruleResultsFile = '.rules-results.json';

/// What each rule file said the last time it ran, by name.
Map<String, RuleResult> readRuleResults() {
  final file = File('${repoRoot().path}/$ruleResultsFile');
  if (!file.existsSync()) return const {};
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, Object?>) return const {};
    return <String, RuleResult>{
      for (final entry in decoded.entries)
        if (_resultFrom(entry.value) case final result?) entry.key: result,
    };
  } on FormatException {
    // A results file nobody can read is a results file with nothing in it.
    return const {};
  }
}

/// Records what [name] did, keeping every other file's result.
void writeRuleResult(String name, RuleResult result) {
  final file = File('${repoRoot().path}/$ruleResultsFile');
  final all = <String, Object?>{
    for (final entry in readRuleResults().entries)
      entry.key: _resultToJson(entry.value),
    name: _resultToJson(result),
  };
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(all)}\n',
  );
}

/// What a row says about [result], or that it has never run.
String describeRuleResult(RuleResult? result) => result == null
    ? 'never run'
    : '${result.passed ? '✓' : '✘'} '
          '${describeWhen(result.when)} · v${result.version} '
          '· ${describeElapsed(result.elapsed)}';

Map<String, Object?> _resultToJson(RuleResult result) => <String, Object?>{
  'passed': result.passed,
  'when': result.when.toIso8601String(),
  'version': result.version,
  'offences': result.offences,
  'elapsedMs': result.elapsed.inMilliseconds,
};

RuleResult? _resultFrom(Object? json) {
  if (json is! Map<String, Object?>) return null;
  final when = DateTime.tryParse(json['when'] as String? ?? '');
  if (when == null) return null;
  return (
    passed: json['passed'] as bool? ?? false,
    when: when,
    version: json['version'] as String? ?? '?',
    offences: json['offences'] as int? ?? 0,
    elapsed: Duration(milliseconds: json['elapsedMs'] as int? ?? 0),
  );
}
