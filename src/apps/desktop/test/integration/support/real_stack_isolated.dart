/// `RealStack`'s twin that runs under an empty git configuration: the git
/// the test arranges with and the git the app starts are one and the same
/// program, and neither reads the developer's own settings (decision T5).
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/bootstrap/git_wiring.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// A temporary repository with `docs/` open as the space, like `RealStack`,
/// but with `git` replaced — for the arranging and for the app — by a script
/// that sets `HOME`, `GIT_CONFIG_GLOBAL` (an empty file) and
/// `GIT_CONFIG_NOSYSTEM` and then runs the real binary.
///
/// The composition root starts git with the parent environment, so the only
/// seam that reaches it is `gitExecutableProvider`; the process's own
/// environment is never touched. What a test needs from a config it writes
/// itself, in the repository or in [globalConfig].
final class IsolatedStack {
  IsolatedStack._(this._temp, this.repository, this.container, this._git);

  /// Builds the repository — empty, `main` unborn — and tears it down with
  /// the test. [identity] false leaves it without a `user.name`/`user.email`.
  factory IsolatedStack.create({bool identity = true}) {
    final Directory temp = Directory.systemTemp.createTempSync('tom_iso_');
    final String root = temp.resolveSymbolicLinksSync();
    File('$root/.gitconfig').writeAsStringSync('');
    Directory('$root/bin').createSync();
    final String real =
        (Process.runSync('which', <String>['git']).stdout as String)
            .split('\n')
            .first
            .trim();
    final File wrapper = File('$root/bin/git')
      ..writeAsStringSync(
        '#!/bin/sh\n'
        'export HOME="$root"\n'
        'export GIT_CONFIG_NOSYSTEM=1\n'
        'export GIT_CONFIG_GLOBAL="$root/.gitconfig"\n'
        'exec "$real" "\$@"\n',
      );
    Process.runSync('chmod', <String>['+x', wrapper.path]);
    final String repository = '$root/repo';
    Directory('$repository/docs').createSync(recursive: true);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        ...appOverrides,
        gitExecutableProvider.overrideWithValue(wrapper.path),
        settingsProvider.overrideWith(
          (Ref ref) => JsonFileSettingsImpl(
            filesystem: ref.watch(filesystemProvider),
            path: '$root/app/preferences.json',
          ),
        ),
      ],
    );
    final IsolatedStack stack =
        IsolatedStack._(temp, repository, container, wrapper.path)
          ..git(<String>['init', '--quiet', '.'])
          ..git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main'])
          ..git(<String>['config', 'commit.gpgsign', 'false'])
          ..git(<String>['config', 'merge.conflictStyle', 'merge']);
    if (identity) {
      stack
        ..git(<String>['config', 'user.name', 'Test'])
        ..git(<String>['config', 'user.email', 'test@example.com']);
    }
    addTearDown(() {
      container.dispose();
      temp.deleteSync(recursive: true);
    });
    return stack;
  }

  final Directory _temp;
  final String _git;

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

  /// The repository seen as a folder: where a change beside the space is
  /// addressed.
  SpaceEntity get beside => space.repositorySpace!;

  /// Where this stack keeps what is not the repository.
  String get scratch => _temp.path;

  /// The empty file that stands for the person's own `~/.gitconfig`.
  File get globalConfig =>
      File('${_temp.resolveSymbolicLinksSync()}/.gitconfig');

  /// Runs git in the repository, failing the test unless [allowFailure].
  String git(List<String> arguments, {bool allowFailure = false}) {
    final ProcessResult result = Process.runSync(
      _git,
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

  /// Writes raw [bytes] at [path].
  void writeBytes(String path, List<int> bytes) => File('$repository/$path')
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(bytes);

  /// What the file at [path] holds.
  String read(String path) => File('$repository/$path').readAsStringSync();

  /// Removes the file at [path] from the disk, git none the wiser.
  void delete(String path) => File('$repository/$path').deleteSync();

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
  List<String> get unmerged =>
      _lines(<String>['diff', '--name-only', '--diff-filter=U']);

  /// The paths in the index that differ from `HEAD` (none before the first
  /// commit, where there is no `HEAD` to differ from).
  List<String> get staged =>
      _lines(<String>['diff', '--cached', '--name-only']);

  /// The commit `HEAD` names.
  String get head => git(<String>['rev-parse', 'HEAD']).trim();

  List<String> _lines(List<String> arguments) => git(
    arguments,
  ).split('\n').where((String line) => line.isNotEmpty).toList();
}
