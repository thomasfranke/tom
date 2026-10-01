/// Black-box tests for `tom`, run as a process and asserted on what comes
/// back, because `tool/` has no pubspec and so no test/ of its own.
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
      // Hidden means not a row on the root screen, never not a command:
      // scripts call analyze, setup and the gates by name.
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
      // EX_USAGE, so a script can tell a mistyped command from a failed one.
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

  group('e2e', () {
    test('a flag on its own is not a scenario name', () {
      // Taking `--watch` out can leave no name, and no name is the same
      // request as `tom e2e`: a listing, not a scenario called ''.
      final ProcessResult result = _tom(<String>['e2e', '--watch']);

      expect(result.exitCode, 0);
      expect(result.stdout, contains('End-to-end'));
    });

    test('a name that does not exist is still a usage error', () {
      final ProcessResult result = _tom(<String>[
        'e2e',
        'Nothing by this name',
      ]);

      expect(result.exitCode, 64);
    });
  });

  group('doctor', () {
    late final ProcessResult result = _tom(<String>['doctor']);

    test('passes on a machine that can build this repository', () {
      // A machine that cannot build the product is worth failing a test over.
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
/// Spelled out rather than read from `tool/tom.dart`: a list derived from
/// the thing under test agrees with it by construction and proves nothing.
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

/// The CLI run with [arguments], through [Platform.resolvedExecutable] so
/// the SDK running these tests is the one running what they spawn.
ProcessResult _tom(List<String> arguments) => Process.runSync(
  Platform.resolvedExecutable,
  <String>['run', 'tool/tom.dart', ...arguments],
  workingDirectory: _repositoryRoot.path,
);

/// The repository root, found by marker rather than by counting levels up,
/// so moving this file cannot break it.
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
