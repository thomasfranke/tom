/// A bare remote, two clones of it and the app's own object graph over the
/// first, all under an empty git configuration of the test's own.
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/bootstrap/git_wiring.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// What [RealRemoteStack] builds: `remote.git` (bare), `work/repo` (the clone
/// the app has open, with its space `docs/` below the root) and `other` (a
/// second clone, for a person elsewhere who pushes).
///
/// Nothing of the developer's machine is read. The app starts git through
/// `gitExecutableProvider`, which here names a script of this stack that
/// sets an empty `GIT_CONFIG_GLOBAL`, no system config and `LC_ALL=C` and
/// runs the real git — so the process environment is never touched. `gh`
/// is a script on a `PATH` of the stack's own, answering from files.
final class RealRemoteStack {
  RealRemoteStack._(this.root, this.container, this.gateSeen);

  /// Builds the three repositories and the graph; the first commit on
  /// `main` is pushed, so the clone tracks it.
  ///
  /// [gateSeen] receives the command line of every command the gate was
  /// asked about, in order.
  factory RealRemoteStack.create({List<String>? gateSeen}) {
    final Directory temp = Directory.systemTemp.createTempSync('tom_remote_');
    final String root = temp.resolveSymbolicLinksSync();
    final List<String> seen = gateSeen ?? <String>[];
    Directory('$root/home').createSync();
    Directory('$root/bin').createSync();
    File('$root/home/.gitconfig').writeAsStringSync('');
    final String real =
        (Process.runSync('which', <String>['git']).stdout as String).trim();
    File('$root/bin/git')
      ..writeAsStringSync(
        '#!/bin/sh\n'
        'export HOME="$root/home"\n'
        'export GIT_CONFIG_GLOBAL="$root/home/.gitconfig"\n'
        'export GIT_CONFIG_NOSYSTEM=1\n'
        'export GIT_TERMINAL_PROMPT=0\n'
        'export LC_ALL=C\n'
        'exec "$real" "\$@"\n',
      )
      ..createSync();
    Process.runSync('chmod', <String>['+x', '$root/bin/git']);

    final Map<String, String> environment = <String, String>{
      'HOME': '$root/home',
      'PATH': '$root/bin',
      'GIT_CONFIG_NOSYSTEM': '1',
      'GIT_CONFIG_GLOBAL': '$root/home/.gitconfig',
    };
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        ...appOverrides,
        settingsProvider.overrideWith(
          (Ref ref) => JsonFileSettingsImpl(
            filesystem: ref.watch(filesystemProvider),
            path: '$root/app/preferences.json',
          ),
        ),
        gitExecutableProvider.overrideWithValue('$root/bin/git'),
        userHomeProvider.overrideWithValue('$root/home'),
        commandGateProvider.overrideWith(
          (Ref ref) => _SpyingGate(ref.watch(commandsProvider.notifier), seen),
        ),
        // The developer's `gh`, keychain and SSH key are out of reach.
        credentialsProvider.overrideWith(
          (Ref ref) => CommandLineCredentialsImpl(
            environment: environment,
            includeParentEnvironment: false,
            commandLog: ref.watch(commandLogProvider),
            commandGate: ref.watch(commandGateProvider),
          ),
        ),
        githubApiProvider.overrideWith(
          (Ref ref) => GhCliGithubApiImpl(
            environment: environment,
            includeParentEnvironment: false,
            commandLog: ref.watch(commandLogProvider),
            commandGate: ref.watch(commandGateProvider),
          ),
        ),
      ],
    );
    final RealRemoteStack stack = RealRemoteStack._(root, container, seen);
    Directory('$root/work').createSync();
    stack
      ..git(<String>['init', '--quiet', '--bare', 'remote.git'], inside: root)
      ..git(<String>[
        'symbolic-ref',
        'HEAD',
        'refs/heads/main',
      ], inside: stack.remote)
      ..git(<String>['init', '--quiet', 'work/repo'], inside: root)
      ..git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main'])
      .._identify(stack.clone)
      ..git(<String>['remote', 'add', 'origin', stack.remote])
      ..write('docs/guide.md', '# Guide\n\nOriginal line.\n')
      ..write('README.md', '# Readme\n')
      ..git(<String>['add', '.'])
      ..git(<String>['commit', '--quiet', '-m', 'base'])
      ..git(<String>['push', '--quiet', '-u', 'origin', 'main'])
      ..git(<String>['clone', '--quiet', stack.remote, 'other'], inside: root)
      .._identify(stack.other);
    addTearDown(() {
      container.dispose();
      temp.deleteSync(recursive: true);
    });
    return stack;
  }

  /// The stack's folder, every link on the way resolved.
  final String root;

  /// The app's object graph, over [clone].
  final ProviderContainer container;

  /// The command lines the gate was asked about, oldest first.
  final List<String> gateSeen;

  /// The bare repository both clones talk to.
  String get remote => '$root/remote.git';

  /// The clone the app has open.
  String get clone => '$root/work/repo';

  /// The second clone: somebody else, pushing.
  String get other => '$root/other';

  /// The machine's own home — what `--global` writes to.
  String get home => '$root/home';

  /// The `docs/` folder of [clone] as the space the app has open.
  SpaceEntity get space =>
      SpaceEntity(root: '$clone/docs', repositoryRoot: clone, name: 'docs');

  /// What every program of this machine is started with.
  Map<String, String> get environment => <String, String>{
    'HOME': home,
    'PATH': '$root/bin',
    'GIT_CONFIG_NOSYSTEM': '1',
    'GIT_CONFIG_GLOBAL': '$home/.gitconfig',
  };

  /// Runs the isolated git in [inside] (the clone by default), failing the
  /// test unless [allowFailure]; the standard output comes back.
  String git(
    List<String> arguments, {
    String? inside,
    bool allowFailure = false,
  }) {
    final ProcessResult result = Process.runSync(
      '$root/bin/git',
      arguments,
      workingDirectory: inside ?? clone,
      environment: environment,
      includeParentEnvironment: false,
    );
    if (result.exitCode != 0 && !allowFailure) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
    return result.stdout.toString();
  }

  /// Writes [content] at [path], relative to the clone (or to [inside]).
  void write(String path, String content, {String? inside}) =>
      File('${inside ?? clone}/$path')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(content);

  /// What the file at [path] holds in the clone (or in [inside]).
  String read(String path, {String? inside}) =>
      File('${inside ?? clone}/$path').readAsStringSync();

  /// Whether anything is at [path] in the clone.
  bool has(String path) => File('$clone/$path').existsSync();

  /// The paths git still calls unmerged in the clone.
  List<String> get unmerged => git(<String>[
    'diff',
    '--name-only',
    '--diff-filter=U',
  ]).split('\n').where((String line) => line.isNotEmpty).toList();

  /// A hook on the remote: [script] runs when the remote reaches [name]
  /// (`pre-receive` refuses a push by exiting non-zero).
  void installRemoteHook(String name, String script) {
    final File hook = File('$remote/hooks/$name')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('#!/bin/sh\n$script\n');
    Process.runSync('chmod', <String>['+x', hook.path]);
  }

  /// A commit by somebody else, on `main` of the remote: [files] written in
  /// [other], committed and pushed after it caught up.
  void pushFromElsewhere(Map<String, String> files, {String? message}) {
    git(<String>[
      'pull',
      '--quiet',
      '--no-rebase',
      'origin',
      'main',
    ], inside: other);
    files.forEach((String path, String content) {
      write(path, content, inside: other);
    });
    git(<String>['add', '.'], inside: other);
    git(<String>[
      'commit',
      '--quiet',
      '-m',
      message ?? 'from elsewhere',
    ], inside: other);
    git(<String>['push', '--quiet', 'origin', 'main'], inside: other);
  }

  /// Leaves [clone] in the middle of a pull that stopped on a conflict in
  /// `docs/guide.md` and `README.md`: both changed on both sides.
  void conflictingPull() {
    pushFromElsewhere(<String, String>{
      'docs/guide.md': '# Guide\n\nTheir line.\n',
      'README.md': '# Readme\n\nTheir line.\n',
    }, message: 'theirs');
    write('docs/guide.md', '# Guide\n\nOur line.\n');
    write('README.md', '# Readme\n\nOur line.\n');
    git(<String>['commit', '--quiet', '-am', 'ours']);
    // Expected to stop: the conflict is the arrangement.
    git(<String>['pull', '--no-rebase', 'origin', 'main'], allowFailure: true);
  }

  /// A `gh` on this machine's `PATH`, answering from files of its own.
  ///
  /// [logins] are the accounts `gh auth status` reports; [pushers] the ones
  /// whose token `gh api` answers with push permission. `pr create` keeps
  /// the title, the body (read from its standard input) and the folder it
  /// ran in, and the list that follows answers with the pull request.
  void installGh({
    List<String> logins = const <String>['ada'],
    List<String> pushers = const <String>[],
  }) {
    final String state = '$root/gh';
    Directory(state).createSync(recursive: true);
    final String entries = logins
        .map((String it) => '{"login":"$it","active":true}')
        .join(',');
    File(
      '$state/accounts.json',
    ).writeAsStringSync('{"hosts":{"github.com":[$entries]}}');
    File(
      '$state/pushers',
    ).writeAsStringSync(pushers.map((String it) => 'tok-$it').join('\n'));
    File('$root/bin/gh').writeAsStringSync(
      '#!/bin/sh\n'
      'PATH=/usr/bin:/bin\n'
      'state="$state"\n'
      'echo "\$GH_TOKEN|\$*" >> "\$state/asked.log"\n'
      'case "\$1 \$2" in\n'
      '  "auth status") cat "\$state/accounts.json" ;;\n'
      '  "auth token") echo "tok-\$6" ;;\n'
      '  "pr list")\n'
      '    pwd > "\$state/pr-list.folder"\n'
      '    if [ -f "\$state/opened.json" ]; then cat "\$state/opened.json"\n'
      '    else echo "[]"; fi ;;\n'
      '  "pr create")\n'
      '    pwd > "\$state/pr-create.folder"\n'
      '    title=""; previous=""\n'
      '    for argument in "\$@"; do\n'
      '      [ "\$previous" = "--title" ] && title="\$argument"\n'
      '      previous="\$argument"\n'
      '    done\n'
      '    printf "%s" "\$title" > "\$state/title.txt"\n'
      '    cat > "\$state/body.md"\n'
      '    printf \'[{"number":123,"url":"https://github.com/acme/docs/pull/123",'
      '"title":"%s"}]\\n\' "\$title" > "\$state/opened.json"\n'
      '    echo "https://github.com/acme/docs/pull/123" ;;\n'
      '  *)\n'
      '    if [ "\$1" = "api" ] && grep -qx "\$GH_TOKEN" "\$state/pushers"; then\n'
      '      echo \'{"permissions":{"pull":true,"push":true,'
      '"admin":false}}\'\n'
      '    elif [ "\$1" = "api" ]; then\n'
      '      echo \'{"permissions":{"pull":true,"push":false,'
      '"admin":false}}\'\n'
      '    else echo "gh: Not Found (HTTP 404)" >&2; exit 1; fi ;;\n'
      'esac\n',
    );
    Process.runSync('chmod', <String>['+x', '$root/bin/gh']);
  }

  /// Every call the fake `gh` received, as `token|arguments`.
  List<String> ghAsked() {
    final File log = File('$root/gh/asked.log');
    return log.existsSync() ? log.readAsLinesSync() : const <String>[];
  }

  /// What the fake `gh` wrote down under [name] (`body.md`, `title.txt`…).
  String ghKept(String name) => File('$root/gh/$name').readAsStringSync();

  /// Whether the fake `gh` wrote [name] down.
  bool ghKeeps(String name) => File('$root/gh/$name').existsSync();

  /// Sets the identity commits are made with in [folder].
  void _identify(String folder) {
    for (final List<String> setting in const <List<String>>[
      <String>['user.name', 'Test'],
      <String>['user.email', 'test@example.com'],
      <String>['commit.gpgsign', 'false'],
    ]) {
      git(<String>['config', ...setting], inside: folder);
    }
  }
}

/// The real gate with a note kept of every command asked about.
final class _SpyingGate implements CommandGate {
  const _SpyingGate(this._real, this._seen);

  final CommandGate _real;

  final List<String> _seen;

  @override
  CommandPlan plan(List<CommandRequest> commands) {
    _seen.addAll(commands.map((CommandRequest it) => it.commandLine));
    return _real.plan(commands);
  }
}
