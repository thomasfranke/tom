// Black-box tests for `tom`, the CLI in tool/.
//
// They run it the way anyone runs it — a process, a command line, an exit
// code — and assert on what comes back. Nothing here imports the CLI, which
// is the point: `tool/` holds no pubspec, because a tool that resolves the
// workspace cannot require the workspace to be resolved before it runs, so it
// can have no test/ of its own. Driving the built artefact from the workspace
// side costs nothing and tests the thing people actually invoke.
//
// Two hatches in the CLI exist for exactly this, and both say so where they
// are defined: `--preview` renders the root screen as static text, and
// Dashboard.frame() does the same for a run. A redraw loop cannot be captured
// by piping stdout anywhere.
library;

import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('--help', () {
    late final ProcessResult result = _tom(<String>['--help']);

    test('succeeds', () {
      expect(result.exitCode, 0);
    });

    test('lists every command, hidden ones included', () {
      // Hidden means "not a row on the root screen", never "not a command":
      // scripts and the Makefile call analyze, setup and the two gates by
      // name, and `--help` is where someone finds out they exist.
      for (final String command in _everyCommand) {
        expect(
          result.stdout,
          contains(command),
          reason: '`$command` is a command but --help does not mention it',
        );
      }
    });
  });

  group('--preview', () {
    late final ProcessResult result = _tom(<String>['--preview']);

    test('renders the root screen without a terminal', () {
      expect(result.exitCode, 0);
      expect(result.stdout, contains('TOM'));
    });

    test('groups the rows under their sections', () {
      for (final String section in <String>['Setup', 'Dev Tools', 'Tests']) {
        expect(result.stdout, contains(section));
      }
    });

    test('offers a way out', () {
      expect(result.stdout, contains('Quit'));
    });
  });

  group('exit codes', () {
    test('an unknown command is a usage error', () {
      // EX_USAGE. A script that mistypes a command has to be able to tell
      // that from the command having failed at its job.
      expect(_tom(<String>['nonesuch']).exitCode, 64);
    });

    test('an unknown package is an input error', () {
      // EX_NOINPUT — the command exists, what it was pointed at does not.
      expect(_tom(<String>['coverage', 'nonesuch']).exitCode, 66);
    });

    test('a terminal-less run with no command explains itself', () {
      final ProcessResult result = _tom(<String>[]);
      expect(result.exitCode, 64);
      expect(result.stderr, contains('no terminal'));
    });
  });

  group('doctor', () {
    late final ProcessResult result = _tom(<String>['doctor']);

    test('passes on a machine that can build this repository', () {
      // If this fails here, the machine running the tests cannot build the
      // product — which is worth failing a test over.
      expect(result.exitCode, 0, reason: result.stdout.toString());
    });

    test('reports on everything the repository needs', () {
      for (final String need in <String>[
        'Git',
        'Dart',
        'Flutter',
        'Workspace',
      ]) {
        expect(result.stdout, contains(need));
      }
    });

    test('leaves the platform toolchains to flutter doctor', () {
      expect(result.stdout, contains('flutter doctor'));
    });
  });
}

/// Every command the CLI answers to, hidden ones included.
///
/// Spelled out here rather than read from `tool/tom.dart`, deliberately: a
/// list derived from the thing under test agrees with it by construction and
/// proves nothing. Adding a command means adding it here, which is the moment
/// to decide whether it belongs in `--help` at all.
const List<String> _everyCommand = <String>[
  'analyze',
  'build',
  'clean',
  'codegen',
  'codegen-gate',
  'coverage',
  'coverage-gate',
  'doctor',
  'format',
  'fvm',
  'run',
  'setup',
  'test',
  'updates',
  'verify',
];

/// Runs the CLI with [arguments] and waits for it to finish.
///
/// [Platform.resolvedExecutable] rather than a bare `dart`, for the same
/// reason the CLI itself uses it: the SDK running these tests is the one that
/// must run what they spawn.
ProcessResult _tom(List<String> arguments) => Process.runSync(
  Platform.resolvedExecutable,
  <String>['run', 'tool/tom.dart', ...arguments],
  workingDirectory: _repositoryRoot.path,
);

/// The repository root, found by marker rather than by counting levels up
/// from this file — which is what broke the scripts in `tool/` when they moved
/// into a subfolder.
Directory get _repositoryRoot {
  Directory directory = Directory.current;
  for (int level = 0; level < 8; level++) {
    if (File('${directory.path}/Makefile').existsSync() &&
        File('${directory.path}/src/pubspec.yaml').existsSync()) {
      return directory;
    }
    final Directory parent = directory.parent;
    if (parent.path == directory.path) {
      break;
    }
    directory = parent;
  }
  throw StateError(
    'Could not find the repository root above ${directory.path}',
  );
}
