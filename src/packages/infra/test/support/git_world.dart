/// A machine of the test's own for the git client: a temporary folder, an
/// empty global git configuration, and a `git` that runs under it.
///
/// The client starts git itself with the parent's environment, so the
/// isolation is a program: `executable` is a script that fixes `HOME`, the
/// global and system configuration, and runs the real git. Nothing of the
/// developer's `~/.gitconfig` can reach a test (decision T5).
library;

import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// The folder, its configuration and the repositories a test builds in it.
final class GitWorld {
  /// Creates the folder, an empty configuration and the `git` wrapper.
  GitWorld() : _temp = Directory.systemTemp.createTempSync('tom_git_world_') {
    // Resolved and forward-slashed, because git reports the real path in its
    // own spelling: the macOS temporary directory is a symlink.
    base = _temp.resolveSymbolicLinksSync().replaceAll(r'\', '/');
    Directory('$base/bin').createSync();
    File(globalConfig).writeAsStringSync('');
    File(executable).writeAsStringSync(
      '#!/bin/sh\n'
      'unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_AUTHOR_NAME '
      'GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL EMAIL\n'
      'export HOME="$base"\n'
      'export GIT_CONFIG_GLOBAL="$globalConfig"\n'
      'export GIT_CONFIG_NOSYSTEM=1\n'
      'exec "$_realGit" "\$@"\n',
    );
    Process.runSync('chmod', <String>['755', executable]);
    repo = '$base/repo';
  }

  final Directory _temp;

  /// The resolved folder everything lives in.
  late final String base;

  /// The main repository's folder, `$base/repo`; [init] makes it one.
  late final String repo;

  /// The global configuration file, empty until a test writes to it.
  String get globalConfig => '$base/gitconfig';

  /// The `git` the client is handed.
  String get executable => '$base/bin/git';

  static final String _realGit = _which('git');

  static String _which(String name) {
    final ProcessResult found = Process.runSync('which', <String>[name]);
    return found.stdout.toString().trim();
  }

  /// What every arranging command runs with: nothing of the real machine's
  /// but the `PATH`.
  Map<String, String> get environment => <String, String>{
    'PATH': Platform.environment['PATH'] ?? '/usr/bin:/bin',
    'HOME': base,
    'GIT_CONFIG_GLOBAL': globalConfig,
    'GIT_CONFIG_NOSYSTEM': '1',
    'LC_ALL': 'C',
  };

  /// Replaces the global configuration with [text], the way a person's
  /// `~/.gitconfig` would read.
  void configure(String text) => File(globalConfig).writeAsStringSync(text);

  /// Runs the real git inside [inside] (the main repository by default), to
  /// arrange what the client is then asked about.
  ProcessResult git(List<String> arguments, {String? inside}) {
    final ProcessResult result = run(arguments, inside: inside);
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
    return result;
  }

  /// [git], returning the result whatever the exit code.
  ProcessResult run(List<String> arguments, {String? inside}) =>
      Process.runSync(
        _realGit,
        arguments,
        workingDirectory: inside ?? repo,
        environment: environment,
        includeParentEnvironment: false,
      );

  /// A repository on `main` at [path]: with an identity of its own unless
  /// [identity] is false, and the committing author of the tests.
  ///
  /// `symbolic-ref` rather than `init --initial-branch`, which needs 2.28.
  void init(String path, {bool bare = false, bool identity = true}) {
    Directory(path).createSync(recursive: true);
    git(<String>['init', '--quiet', if (bare) '--bare', '.'], inside: path);
    git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main'], inside: path);
    if (bare || !identity) {
      return;
    }
    git(<String>['config', 'user.name', 'Test'], inside: path);
    git(<String>['config', 'user.email', 'test@example.com'], inside: path);
  }

  /// Writes [content] at [relativePath] inside [inside] (the main repository
  /// by default), creating the folders above it.
  void write(String relativePath, String content, {String? inside}) {
    File('${inside ?? repo}/$relativePath')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  /// Reads [relativePath] inside [inside] (the main repository by default).
  String read(String relativePath, {String? inside}) =>
      File('${inside ?? repo}/$relativePath').readAsStringSync();

  /// Writes, stages and commits [relativePath] with [content].
  void commitFile(
    String relativePath,
    String content, {
    String message = 'Add a file',
    String? inside,
  }) {
    write(relativePath, content, inside: inside);
    git(<String>['add', '--', relativePath], inside: inside);
    git(<String>['commit', '--quiet', '--message', message], inside: inside);
  }

  /// A `main` with `a.md` committed, in [repo] — the shape most tests start
  /// from.
  void seed() {
    init(repo);
    commitFile('a.md', '# A\n', message: 'Add A');
  }

  /// Leaves `a.md` conflicted by merging a branch that changed the same line
  /// as `main`, with no remote involved. The branch is `topic`.
  void conflict({String? inside}) {
    final String where = inside ?? repo;
    git(<String>['switch', '--quiet', '--create', 'topic'], inside: where);
    commitFile('a.md', '# A, topic\n', message: 'Topic', inside: where);
    git(<String>['switch', '--quiet', 'main'], inside: where);
    commitFile('a.md', '# A, main\n', message: 'Main', inside: where);
    run(<String>['merge', 'topic'], inside: where);
  }

  /// Puts an executable shell script at `.git/hooks/[name]` in [repo].
  void hook(String name, String body) {
    final File script = File('$repo/.git/hooks/$name')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('#!/bin/sh\n$body\n');
    Process.runSync('chmod', <String>['755', script.path]);
  }

  /// A client running the isolated git inside [inside] (the main repository
  /// by default).
  DartIoGitClientImpl client({
    String? inside,
    Duration timeout = const Duration(seconds: 30),
  }) => DartIoGitClientImpl(
    workingDirectory: inside ?? repo,
    executable: executable,
    timeout: timeout,
  );

  /// Removes the folder and everything in it.
  void dispose() => _temp.deleteSync(recursive: true);
}

/// The value of a successful result, failing the test when it is not one.
T valueOf<T>(Result<T, GitClientFailure> result) {
  if (result case Success<T, GitClientFailure>(:final T value)) {
    return value;
  }
  throw StateError('expected a success, got $result');
}

/// The failure of a failed result, failing the test when it is not one.
GitClientFailure failureOf(Result<Object?, GitClientFailure> result) {
  if (result case Failure<Object?, GitClientFailure>(
    :final GitClientFailure failure,
  )) {
    return failure;
  }
  throw StateError('expected a failure, got $result');
}
