/// A machine of the test's own for the git client's remote, merge and process
/// tests: an empty git configuration, a `git` the client is handed by path,
/// bare remotes with hooks, and a loopback server that refuses everyone.
library;

import 'dart:async';
import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// One temporary folder holding everything a test arranges.
///
/// The client starts git with the parent environment, so isolation is the
/// `git` it is handed: a script that sets `HOME`, `GIT_CONFIG_GLOBAL` (an
/// empty file) and `GIT_CONFIG_NOSYSTEM` and then runs the real one. Nothing
/// of the developer's configuration reaches a test, and a test that needs a
/// setting writes it with [writeGlobalConfig].
final class GitRemoteWorld {
  /// Creates the folder, the empty configuration and the `git` script.
  GitRemoteWorld()
    : base = Directory.systemTemp
          .createTempSync('tom_git_remote_world_')
          .resolveSymbolicLinksSync()
          .replaceAll(r'\', '/') {
    Directory('$base/bin').createSync();
    File(globalConfig).writeAsStringSync('');
    final String real =
        (Process.runSync('which', <String>['git']).stdout as String).trim();
    File(executable)
      ..writeAsStringSync(
        '#!/bin/sh\n'
        'export HOME="$base" GIT_CONFIG_NOSYSTEM=1 '
        'GIT_CONFIG_GLOBAL="$globalConfig"\n'
        'exec "$real" "\$@"\n',
      )
      ..createSync();
    Process.runSync('chmod', <String>['+x', executable]);
  }

  /// The folder, resolved and forward-slashed as git spells paths.
  final String base;

  /// The person's global configuration: empty until a test writes to it.
  String get globalConfig => '$base/.gitconfig';

  /// What the client is started with in place of `git`.
  String get executable => '$base/bin/git';

  /// What every arranging command runs with: the isolated machine, and the
  /// parent's `PATH` so a hook can find `sh`.
  Map<String, String> get environment => <String, String>{
    'HOME': base,
    'PATH': Platform.environment['PATH'] ?? '/usr/bin:/bin',
    'GIT_CONFIG_NOSYSTEM': '1',
    'GIT_CONFIG_GLOBAL': globalConfig,
    'LC_ALL': 'C',
    'GIT_TERMINAL_PROMPT': '0',
  };

  /// Replaces the person's global configuration with [content].
  void writeGlobalConfig(String content) =>
      File(globalConfig).writeAsStringSync(content);

  /// Runs the real git in [inside], failing the test setup when it exits
  /// non-zero unless [mayFail].
  ProcessResult git(
    List<String> arguments, {
    required String inside,
    bool mayFail = false,
  }) {
    final ProcessResult result = Process.runSync(
      'git',
      arguments,
      workingDirectory: inside,
      environment: environment,
      includeParentEnvironment: false,
    );
    if (result.exitCode != 0 && !mayFail) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
    return result;
  }

  /// What git printed for [arguments] in [inside], trimmed.
  String say(List<String> arguments, {required String inside}) =>
      (git(arguments, inside: inside).stdout as String).trim();

  /// A repository at [path] on `main`, with an identity of its own.
  ///
  /// `symbolic-ref` rather than `--initial-branch`, which needs git 2.28.
  void init(String path, {bool bare = false}) {
    Directory(path).createSync(recursive: true);
    git(<String>['init', '--quiet', if (bare) '--bare', '.'], inside: path);
    git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main'], inside: path);
    if (!bare) {
      identify(path);
    }
  }

  /// Gives the repository at [path] a name, an address and no signing.
  void identify(String path, {String name = 'Test'}) {
    for (final List<String> setting in <List<String>>[
      <String>['user.name', name],
      <String>['user.email', 'test@example.com'],
      <String>['commit.gpgsign', 'false'],
    ]) {
      git(<String>['config', ...setting], inside: path);
    }
  }

  /// Writes [content] to [relative] inside [repository].
  void write(String repository, String relative, String content) {
    File('$repository/$relative')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  /// Stages everything in [repository] and commits it with [message].
  void commitAll(String repository, String message) {
    git(<String>['add', '--all'], inside: repository);
    git(<String>[
      'commit',
      '--quiet',
      '--message',
      message,
    ], inside: repository);
  }

  /// A bare remote at `$base/remote.git`, and a working clone of it at
  /// [clone] holding one commit (`a.md`) that is pushed and tracked.
  ///
  /// The returned path is the bare repository.
  String remoteWithClone(String clone, {String file = 'a.md'}) {
    final String remote = '$base/remote.git';
    init(remote, bare: true);
    init(clone);
    write(clone, file, '# A\n');
    commitAll(clone, 'Add A');
    git(<String>['remote', 'add', 'origin', remote], inside: clone);
    git(<String>[
      'push',
      '--quiet',
      '--set-upstream',
      'origin',
      'main',
    ], inside: clone);
    return remote;
  }

  /// A second working copy of [remote], as another person would have.
  String peerOf(String remote, String path) {
    git(<String>['clone', '--quiet', remote, path], inside: base);
    identify(path, name: 'Peer');
    return path;
  }

  /// Installs [script] as the hook [name] of the bare repository [remote].
  void hook(String remote, String name, String script) {
    final File file = File('$remote/hooks/$name')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('#!/bin/sh\n$script\n');
    Process.runSync('chmod', <String>['+x', file.path]);
  }

  /// A client running in [folder] over this machine's `git`.
  DartIoGitClientImpl clientIn(
    String folder, {
    CommandLog commandLog = const SilentCommandLogImpl(),
    Duration timeout = const Duration(seconds: 30),
    Duration networkTimeout = const Duration(seconds: 30),
    String? executable,
  }) => DartIoGitClientImpl(
    workingDirectory: folder,
    executable: executable ?? this.executable,
    commandLog: commandLog,
    timeout: timeout,
    networkTimeout: networkTimeout,
  );

  /// Removes everything the test made.
  void dispose() => Directory(base).deleteSync(recursive: true);
}

/// A server on a loopback port that answers every request 401, as a
/// remote does for credentials it does not accept.
final class RefusingHttpServer {
  RefusingHttpServer._(this._server) {
    _server.listen((HttpRequest request) {
      requests.add('${request.method} ${request.uri}');
      request.response
        ..statusCode = HttpStatus.unauthorized
        ..headers.set('WWW-Authenticate', 'Basic realm="docs"');
      unawaited(request.response.close());
    });
  }

  /// Starts listening on a free port of the loopback interface.
  static Future<RefusingHttpServer> start() async => RefusingHttpServer._(
    await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
  );

  final HttpServer _server;

  /// Every request received, as `METHOD /path`.
  final List<String> requests = <String>[];

  /// An address of a repository on this server.
  String get url => 'http://127.0.0.1:${_server.port}/docs.git';

  /// Stops listening.
  Future<void> close() => _server.close(force: true);
}

/// A [CommandLog] that keeps what it is told.
final class KeptCommandLog implements CommandLog {
  /// Every record written, oldest first.
  final List<CommandRecord> records = <CommandRecord>[];

  @override
  void record(CommandRecord record) => records.add(record);
}
