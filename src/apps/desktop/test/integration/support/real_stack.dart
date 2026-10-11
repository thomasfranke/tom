/// A real repository and the app's own object graph over it, for the tests
/// that run a use case against git and the disk.
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// A temporary repository with a `docs/` folder opened as the space, and the
/// composition root wired the way `runTom` wires it.
///
/// The space sits **below** the repository root on purpose: a change beside
/// it is the case a fixture at the root cannot see. Preferences live in the
/// same temporary folder, so nothing here reads or writes a person's own.
final class RealStack {
  RealStack._(this._temp, this.repository, this.container);

  /// Builds the repository — one commit on `main` holding `docs/guide.md`
  /// and `README.md` — and tears it down with the test.
  factory RealStack.create() {
    final Directory temp = Directory.systemTemp.createTempSync('tom_stack_');
    final String repository = '${temp.resolveSymbolicLinksSync()}/repo';
    Directory('$repository/docs').createSync(recursive: true);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        ...appOverrides,
        settingsProvider.overrideWith(
          (Ref ref) => JsonFileSettingsImpl(
            filesystem: ref.watch(filesystemProvider),
            path: '${temp.path}/app/preferences.json',
          ),
        ),
      ],
    );
    final RealStack stack = RealStack._(temp, repository, container)
      ..git(<String>['init', '--quiet', '.'])
      ..git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main']);
    for (final List<String> setting in const <List<String>>[
      <String>['user.name', 'Test'],
      <String>['user.email', 'test@example.com'],
      <String>['commit.gpgsign', 'false'],
      // Said here, so a developer's own style does not decide what git
      // writes into a conflicted file.
      <String>['merge.conflictStyle', 'merge'],
    ]) {
      stack.git(<String>['config', ...setting]);
    }
    addTearDown(() {
      container.dispose();
      temp.deleteSync(recursive: true);
    });
    return stack;
  }

  final Directory _temp;

  /// The repository's root, every link on the way resolved.
  final String repository;

  /// The app's object graph.
  final ProviderContainer container;

  /// The `docs/` folder as the space the app has open.
  SpaceEntity get space => SpaceEntity(
    root: '$repository/docs',
    repositoryRoot: repository,
    name: 'docs',
  );

  /// Where this stack keeps what is not the repository.
  String get scratch => _temp.path;

  /// Runs git in the repository, failing the test unless [allowFailure].
  String git(List<String> arguments, {bool allowFailure = false}) {
    final ProcessResult result = Process.runSync(
      'git',
      arguments,
      workingDirectory: repository,
      environment: const <String, String>{'LC_ALL': 'C'},
    );
    if (result.exitCode != 0 && !allowFailure) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
    return result.stdout.toString();
  }

  /// Writes [content] at [path], relative to the repository root.
  void write(String path, String content) => File('$repository/$path')
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(content);

  /// What the file at [path] holds.
  String read(String path) => File('$repository/$path').readAsStringSync();

  /// Whether anything is at [path].
  bool has(String path) => File('$repository/$path').existsSync();

  /// Commits `docs/guide.md` and `README.md` as [base] on `main`.
  void commitBase(String base) {
    write('docs/guide.md', base);
    write('README.md', base);
    git(<String>['add', '.']);
    git(<String>['commit', '--quiet', '-m', 'base']);
  }

  /// Leaves `docs/guide.md` and `README.md` conflicted, the way a pull that
  /// stopped does: both changed on `main` and on `other`, then merged.
  void conflict({
    String base = '# Guide\n\nOriginal line.\n',
    String ours = '# Guide\n\nOur line.\n',
    String theirs = '# Guide\n\nTheir line.\n',
  }) {
    commitBase(base);
    git(<String>['checkout', '--quiet', '-b', 'other']);
    write('docs/guide.md', theirs);
    write('README.md', theirs);
    git(<String>['commit', '--quiet', '-am', 'theirs']);
    git(<String>['checkout', '--quiet', 'main']);
    write('docs/guide.md', ours);
    write('README.md', ours);
    git(<String>['commit', '--quiet', '-am', 'ours']);
    // Expected to stop: the conflict is the arrangement.
    git(<String>['merge', 'other'], allowFailure: true);
  }

  /// The paths git still calls unmerged.
  List<String> get unmerged => git(<String>[
    'diff',
    '--name-only',
    '--diff-filter=U',
  ]).split('\n').where((String line) => line.isNotEmpty).toList();

  /// The paths in the index that differ from `HEAD`.
  List<String> get staged => git(<String>[
    'diff',
    '--cached',
    '--name-only',
  ]).split('\n').where((String line) => line.isNotEmpty).toList();
}
