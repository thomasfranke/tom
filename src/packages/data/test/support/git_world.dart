/// A world for git tests of the test's own: one temporary folder holding an
/// empty global config, a `git` wrapper that makes the real binary read only
/// that config, and every repository the test builds.
///
/// Nothing of the machine's `~/.gitconfig`, system config or credential
/// helper reaches a test that goes through [GitWorld.git] or a client made
/// by [GitWorld.client], so the result stops depending on whose machine it
/// runs on (decision T5).
/// POSIX only: the wrapper is a shell script, so the tests that use it say
/// `@TestOn('!windows')`.
library;

import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

/// The folder, its configuration and the git that reads it.
final class GitWorld {
  /// A world whose configuration names an author and nothing else.
  GitWorld() : root = Directory.systemTemp.createTempSync('tom_git_world_') {
    // Resolved, because the macOS temporary directory is a symlink and git
    // answers with the real path.
    base = root.resolveSymbolicLinksSync().replaceAll(r'\', '/');
    File(configPath).writeAsStringSync(
      '[user]\n\tname = Test\n\temail = test@example.com\n'
      '[commit]\n\tgpgsign = false\n'
      '[init]\n\tdefaultBranch = main\n',
    );
    Directory('$base/bin').createSync();
    // The environment is the wrapper's, not only the caller's: the client
    // under test starts its own git with the parent environment, and this
    // is the one place that reaches it.
    _script('git', '''
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_ASKPASS SSH_ASKPASS
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
export HOME="$base"
export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL="$configPath"
export LC_ALL=C
export GIT_TERMINAL_PROMPT=0
exec "${_which('git')}" "\$@"''');
  }

  /// The world's folder.
  final Directory root;

  /// [root] resolved and forward-slashed.
  late final String base;

  /// The global configuration every git of the world reads.
  String get configPath => '${root.path}/gitconfig';

  /// The wrapper around the real git.
  String get gitExecutable => '$base/bin/git';

  /// What every program of the world is started with: nothing of the real
  /// machine's git configuration.
  Map<String, String> get environment => <String, String>{
    'HOME': base,
    'GIT_CONFIG_NOSYSTEM': '1',
    'GIT_CONFIG_GLOBAL': configPath,
    'LC_ALL': 'C',
    'GIT_TERMINAL_PROMPT': '0',
  };

  /// Replaces the global configuration with [text].
  void configure(String text) => File(configPath).writeAsStringSync(text);

  /// Appends [text] to the global configuration.
  void configureMore(String text) =>
      File(configPath).writeAsStringSync(text, mode: FileMode.append);

  /// Puts an executable shell script named [name] in the world's `bin/`.
  void _script(String name, String body) {
    final File script = File('$base/bin/$name')
      ..writeAsStringSync('#!/bin/sh\n$body\n');
    Process.runSync('chmod', <String>['+x', script.path]);
  }

  /// A program of the world's own: [body] runs in place of `git`, for a
  /// test that needs an older one or a slow one. Returns its path.
  String fakeGit(String name, String body) {
    _script(name, body);
    return '$base/bin/$name';
  }

  /// Runs the real git in [inside], failing the test on a non-zero exit,
  /// and answers what it printed.
  String git(List<String> arguments, {required String inside}) {
    final ProcessResult result = run(arguments, inside: inside);
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
    return (result.stdout as String).trim();
  }

  /// Runs the real git in [inside] and answers the whole result.
  ProcessResult run(List<String> arguments, {required String inside}) =>
      Process.runSync(
        gitExecutable,
        arguments,
        workingDirectory: inside,
        environment: environment,
      );

  /// Writes [content] at [relativePath] under [folder].
  void write(String folder, String relativePath, String content) {
    File('$folder/$relativePath')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  /// Reads the file at [relativePath] under [folder].
  String read(String folder, String relativePath) =>
      File('$folder/$relativePath').readAsStringSync();

  /// A repository at [path] on `main`, with no commit.
  String init(String path) {
    Directory(path).createSync(recursive: true);
    git(<String>['init', '--quiet', '.'], inside: path);
    git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main'], inside: path);
    return path;
  }

  /// Stages everything under [inside] and commits it as [message].
  void commitAll(String inside, String message) {
    git(<String>['add', '--all'], inside: inside);
    git(<String>['commit', '--quiet', '--message', message], inside: inside);
  }

  /// Writes [content] at [relativePath] and commits it alone.
  void commitFile(
    String inside,
    String relativePath,
    String content, {
    String? message,
  }) {
    write(inside, relativePath, content);
    git(<String>['add', '--', relativePath], inside: inside);
    git(<String>[
      'commit',
      '--quiet',
      '--message',
      message ?? 'Edit $relativePath',
    ], inside: inside);
  }

  /// A bare repository at [path] with `main` as its head.
  String bare(String path) {
    Directory(path).createSync(recursive: true);
    git(<String>['init', '--quiet', '--bare', '.'], inside: path);
    git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main'], inside: path);
    return path;
  }

  /// A clone of [remote] at [path].
  String clone(String remote, String path) {
    git(<String>['clone', '--quiet', remote, path], inside: base);
    return path;
  }

  /// A bare remote at `$base/remote.git` with one commit on `main` (the file
  /// [file]), and a clone of it at `$base/work` — the person's.
  ({String remote, String work}) remoteWithClone({
    String file = 'index.md',
    String content = '# Index\n',
  }) {
    final String seed = init('$base/seed');
    commitFile(seed, file, content, message: 'Start');
    final String remote = '$base/remote.git';
    git(<String>['clone', '--quiet', '--bare', seed, remote], inside: base);
    Directory(seed).deleteSync(recursive: true);
    return (remote: remote, work: clone(remote, '$base/work'));
  }

  /// A second clone of [remote], where somebody else works.
  String colleague(String remote) => clone(remote, '$base/colleague');

  /// A client of the real git, inside [folder], under the world's config.
  DartIoGitClientImpl client(
    String folder, {
    String? executable,
    Duration timeout = const Duration(seconds: 30),
    Duration networkTimeout = const Duration(seconds: 30),
    CommandGate commandGate = const OpenCommandGateImpl(),
  }) => DartIoGitClientImpl(
    workingDirectory: folder,
    executable: executable ?? gitExecutable,
    timeout: timeout,
    networkTimeout: networkTimeout,
    commandGate: commandGate,
  );

  /// The repository contract over the real git, inside [folder].
  GitRepositoryImpl repository(String folder, {String? executable}) =>
      GitRepositoryImpl(
        git: GitDataSource(client: client(folder, executable: executable)),
      );

  /// Removes the world.
  void dispose() => root.deleteSync(recursive: true);
}

/// What [result] holds, or a failure of the test if it did not succeed.
T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
  Success<T, F>(value: final T value) => value,
  Failure<T, F>(failure: final F failure) => throw StateError(
    'expected a success, got $failure',
  ),
};

/// What [result] failed with, or a failure of the test if it succeeded.
F failureOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
  Success<T, F>() => throw StateError('expected a failure, got a success'),
  Failure<T, F>(failure: final F failure) => failure,
};

/// A path as the repository speaks it.
RepoRelativePathValueObject rel(String path) =>
    RepoRelativePathValueObject(path);

/// A branch name.
BranchNameValueObject branch(String name) => BranchNameValueObject(name);

/// Where [program] is on the real machine's `PATH`.
String _which(String program) =>
    (Process.runSync('which', <String>[program]).stdout as String)
        .split('\n')
        .first
        .trim();
