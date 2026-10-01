// `tom doctor` — whether this machine can build the repository.
library;

import 'dart:io';

import '../theme/theme.dart';
import 'process.dart';
import 'toolchain.dart';

/// Reports the toolchain, and fails only if something the repository requires
/// is missing or too old.
///
/// A difference that does not stop a build does not stop the command: the
/// question is "can this be built here", not "is this machine CI". Platform
/// toolchains are left to `flutter doctor`, which already asks properly.
Future<int> runDoctor() async {
  announce('Doctor — what this repository needs');

  final checks = [
    await _git(),
    _dart(),
    await _flutter(),
    await _fvm(),
    _workspace(),
    await _lcov(),
  ];

  // Width from the longest label, so adding a check cannot break the column.
  final width = checks
      .map((check) => check.label.length)
      .reduce((a, b) => a > b ? a : b);

  stdout.writeln();
  for (final check in checks) {
    stdout.writeln(
      '${check.mark}${check.label.padRight(width)}  '
      '${palette.detail}${check.detail}${Ansi.reset}',
    );
  }

  final required = checks.where((check) => check.required).toList();
  final failed = required.where((check) => check.outcome == _Outcome.failed);
  final verdict = failed.isEmpty
      ? '${palette.ok}${Status.ok}${Ansi.reset} ready'
      : '${palette.fail}${Status.fail}${Ansi.reset} not ready';

  stdout
    ..writeln()
    ..writeln('  • Summary:')
    ..writeln(
      '    • ${required.length - failed.length}/${required.length} required',
    )
    ..writeln('    • $verdict')
    ..writeln()
    ..writeln(
      '${palette.detail}  Platform toolchains — Xcode, Visual Studio, the '
      'Linux build packages —\n  are Flutter\'s own question: run '
      '`flutter doctor`.${Ansi.reset}',
    );

  return failed.isEmpty ? 0 : 1;
}

/// Git, which the infra layer drives as a system binary rather than through a
/// library (Decision 2), so the product does not work without it.
Future<_Check> _git() async {
  final version = await versionOf('git');
  return version == null
      ? const _Check.failed(
          'Git',
          'not on PATH — TOM drives git through the system binary',
        )
      : _Check.ok('Git', '$version');
}

/// The Dart SDK running this CLI, against the constraint the workspace
/// declares.
_Check _dart() {
  final constraint = declaredDartConstraint();
  final wanted = constraint == null ? null : Version.parse(constraint);
  final installed = installedDart();

  if (installed == null) {
    return const _Check.attention(
      'Dart',
      'could not read this SDK\'s own version',
    );
  }
  if (wanted == null) {
    return _Check.attention(
      'Dart',
      '$installed — no sdk constraint found in $workspacePubspecPath',
    );
  }

  return installed.satisfiesCaret(wanted)
      ? _Check.ok('Dart', '$installed — satisfies $constraint')
      : _Check.failed(
          'Dart',
          '$installed — $workspacePubspecPath asks for $constraint',
        );
}

/// Flutter, against the pin every other reader of this repository uses.
///
/// Not the pinned one is an annotation, not a failure: anything recent
/// enough resolves the workspace, but the difference is worth seeing before
/// it explains a green machine and a red pipeline.
Future<_Check> _flutter() async {
  final flutter = await installedFlutter();
  if (flutter == null) {
    return const _Check.failed(
      'Flutter',
      'not on PATH — the desktop app cannot be built or run',
    );
  }

  final pinned = pinnedFlutterVersion();
  final pin = pinned == null ? null : Version.parse(pinned);
  if (pin == null) {
    return _Check.attention(
      'Flutter',
      '${flutter.framework} — could not read the pin from $fvmrcPath',
    );
  }

  return flutter.framework == pin
      ? _Check.ok(
          'Flutter',
          '${flutter.framework} (${flutter.channel}) — matches $fvmrcPath',
        )
      : _Check.attention(
          'Flutter',
          '${flutter.framework} — $fvmrcPath pins $pinned, '
              'which is what CI builds with; `tom fvm` matches it',
        );
}

/// FVM, which applies the pin. Optional: it is `tom fvm` that installs it,
/// and a machine already on the right Flutter never needs it.
Future<_Check> _fvm() async => await isInstalled('fvm')
    ? const _Check.ok(
        'FVM',
        'installed — `tom fvm` pins this workspace',
        required: false,
      )
    : const _Check.absent(
        'FVM',
        'not installed — `tom fvm` installs it when the pin is needed',
      );

/// Whether the workspace has been resolved here.
_Check _workspace() => isWorkspaceResolved()
    ? const _Check.ok('Workspace', 'resolved')
    : const _Check.attention('Workspace', 'not resolved — run `tom setup`');

/// genhtml, which turns the measured coverage into the report `tom coverage`
/// opens. Optional: the gate reads the raw lcov and never needs it.
Future<_Check> _lcov() async => await isInstalled('genhtml')
    ? const _Check.ok('lcov', 'genhtml available', required: false)
    : const _Check.absent(
        'lcov',
        'genhtml not installed — only `tom coverage` needs it',
      );

/// What one check found: four outcomes rather than a boolean, because only
/// "missing and required" should fail a build.
enum _Outcome {
  ok(Status.ok),
  attention(Layout.detailMarker),
  failed(Status.fail),
  optional(Status.skipped);

  const _Outcome(this.glyph);

  final String glyph;

  /// The palette role this outcome is drawn in.
  String get color => switch (this) {
    _Outcome.ok => palette.ok,
    _Outcome.attention => palette.detailIcon,
    _Outcome.failed => palette.fail,
    _Outcome.optional => palette.skipped,
  };
}

/// One row of the report.
final class _Check {
  const _Check(this.label, this.outcome, this.detail, {this.required = true});

  /// [required] is the one thing a caller still says: a tool that is present
  /// says nothing about whether the build needed it.
  const _Check.ok(String label, String detail, {bool required = true})
    : this(label, _Outcome.ok, detail, required: required);

  const _Check.attention(String label, String detail)
    : this(label, _Outcome.attention, detail);

  const _Check.failed(String label, String detail)
    : this(label, _Outcome.failed, detail);

  /// A tool only some commands reach for, and this machine does not have —
  /// counted in no total, and never a reason to fail.
  const _Check.absent(String label, String detail)
    : this(label, _Outcome.optional, detail, required: false);

  final String label;
  final _Outcome outcome;
  final String detail;

  /// Whether a failure here means the repository cannot be built at all.
  final bool required;

  /// The status mark and the margin around it: five columns, the same as the
  /// coverage gate's, so two reports line their labels up.
  String get mark => '  ${outcome.color}${outcome.glyph}${Ansi.reset}  ';
}
