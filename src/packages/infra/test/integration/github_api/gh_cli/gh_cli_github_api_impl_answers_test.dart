/// Every answer `gh` gives, through [GhCliGithubApiImpl] and a real
/// process: a `gh` of the test's own on a `PATH` of its own, saying on its
/// error stream what the real one says and writing down what reached it.
@TestOn('!windows')
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory machine;
  late Directory clone;

  setUp(() {
    machine = Directory.systemTemp.createTempSync('tom_gh_answers_test_');
    // A space in the name: the clone is a person's folder, not a test's.
    clone = Directory('${machine.path}/my clone')..createSync();
    Directory('${machine.path}/bin').createSync();
  });

  tearDown(() => machine.deleteSync(recursive: true));

  /// Puts a `gh` on the test's `PATH` that writes down its arguments, its
  /// folder, its input and what it was started with, then runs [answer].
  void gh(String answer, {bool executable = true}) {
    final File script = File('${machine.path}/bin/gh')
      ..writeAsStringSync(
        '#!/bin/sh\n'
        'PATH=/usr/bin:/bin\n'
        'out="${machine.path}/asked"\n'
        r'for a in "$@"; do printf "%s\0" "$a"; done > "$out.arguments"'
        '\n'
        r'pwd > "$out.folder"'
        '\n'
        r'printf "%s" "$GH_TOKEN" > "$out.token"'
        '\n'
        r'printf "%s|%s|%s|%s" "$LC_ALL" "$LANG" "$GH_PROMPT_DISABLED" '
        r'"$GH_NO_UPDATE_NOTIFIER" > "$out.environment"'
        '\n'
        r'echo $$ > "$out.pid"'
        '\n'
        '$answer\n',
      );
    if (executable) {
      Process.runSync('chmod', <String>['+x', script.path]);
    }
  }

  /// A `gh` that fails the way the real one does: [said] on the error
  /// stream, exit 1.
  void ghSays(String said, {String printed = ''}) => gh(
    "printf '%s\\n' '$printed'\n"
    "cat >&2 <<'TOM_EOF'\n"
    '$said\n'
    'TOM_EOF\n'
    'exit 1',
  );

  GhCliGithubApiImpl api({
    Duration timeout = const Duration(seconds: 15),
    Map<String, String> more = const <String, String>{},
    CommandGate gate = const OpenCommandGateImpl(),
  }) => GhCliGithubApiImpl(
    environment: <String, String>{'PATH': '${machine.path}/bin', ...more},
    includeParentEnvironment: false,
    timeout: timeout,
    commandGate: gate,
  );

  File asked(String what) => File('${machine.path}/asked.$what');

  /// The arguments as the script received them, one entry each — a newline
  /// inside one stays inside it.
  List<String> arguments() {
    final List<String> all = asked(
      'arguments',
    ).readAsStringSync().split('\x00');
    return all.sublist(0, all.length - 1);
  }

  Future<Result<String, GithubApiFailure>> repository() =>
      api().repository('acme/docs', token: 'tok-secret');

  Future<Result<String, GithubApiFailure>> list() => api().openPullRequests(
    clone.path,
    repository: 'acme/docs',
    head: 'feat/x',
    token: 'tok-secret',
  );

  Future<Result<String, GithubApiFailure>> create({
    GhCliGithubApiImpl? through,
    String title = 'Release notes',
    String body = 'Why it exists.\n',
  }) => (through ?? api()).createPullRequest(
    clone.path,
    repository: 'acme/docs',
    base: 'main',
    head: 'feat/x',
    title: title,
    body: body,
    token: 'tok-secret',
  );

  group('what a token may do on a repository', () {
    test('is asked of the host with the token in the environment, and the '
        'body comes back as it was printed', () async {
      gh('echo \'{"permissions":{"pull":true,"push":false}}\'');

      final Result<String, GithubApiFailure> answered = await repository();

      expect(
        (answered as Success<String, GithubApiFailure>).value,
        '{"permissions":{"pull":true,"push":false}}\n',
      );
      expect(arguments(), <String>[
        'api',
        '--hostname',
        'github.com',
        'repos/acme/docs',
      ]);
      expect(asked('token').readAsStringSync(), 'tok-secret');
      expect(arguments().join(' '), isNot(contains('tok-secret')));
    });

    test('another host is the one named to gh', () async {
      gh('echo "{}"');

      await GhCliGithubApiImpl(
        host: 'git.acme.example',
        environment: <String, String>{'PATH': '${machine.path}/bin'},
        includeParentEnvironment: false,
      ).repository('acme/docs', token: 'tok-secret');

      expect(
        arguments(),
        containsAllInOrder(<String>['--hostname', 'git.acme.example']),
      );
    });

    test('a token GitHub does not know is refused, 401', () async {
      ghSays(
        'gh: Bad credentials (HTTP 401)',
        printed: '{"message":"Bad credentials"}',
      );

      expect((await repository()).failureOrNull, const GithubApiRefused(401));
    });

    test('a token that may not is refused, 403', () async {
      ghSays('gh: Resource not accessible by personal access token (HTTP 403)');

      expect((await repository()).failureOrNull, const GithubApiRefused(403));
    });

    test('a repository the token cannot see is not found', () async {
      ghSays('gh: Not Found (HTTP 404)', printed: '{"message":"Not Found"}');

      expect((await repository()).failureOrNull, const GithubApiNotFound());
    });

    test('no connection is unreachable, with what gh said about it', () async {
      ghSays(
        'error connecting to api.github.com\n'
        'check your internet connection or https://githubstatus.com',
      );

      expect(
        (await repository()).failureOrNull,
        isA<GithubApiUnreachable>().having(
          (GithubApiUnreachable it) => it.description,
          'description',
          startsWith('error connecting to api.github.com'),
        ),
      );
    });

    test('a name that does not resolve is unreachable too', () async {
      ghSays(
        'Get "https://api.github.com/repos/acme/docs": dial tcp: lookup '
        'api.github.com: no such host',
      );

      expect((await repository()).failureOrNull, isA<GithubApiUnreachable>());
    });

    test('any other answer carries the error stream and nothing of the '
        'body', () async {
      ghSays(
        'gh: Server Error (HTTP 502)',
        printed: '{"secret":"never-carried"}',
      );

      expect(
        (await repository()).failureOrNull,
        const GithubApiOperationFailed('gh: Server Error (HTTP 502)'),
      );
    });
  });

  group('a gh that cannot answer', () {
    test('one that outlives its time is unreachable, and killed', () async {
      // `exec`, so the process the implementation started is the one that
      // sleeps — as the real `gh` is one process.
      gh('exec sleep 30');

      final Result<String, GithubApiFailure> answered = await api(
        timeout: const Duration(milliseconds: 600),
      ).repository('acme/docs', token: 'tok-secret');

      expect(answered.failureOrNull, const GithubApiUnreachable('timed out'));
      expect(await _gone(asked('pid').readAsStringSync().trim()), isTrue);
    });

    test('one that may not be executed is a failure naming gh, not a '
        'missing program', () async {
      gh('echo "[]"', executable: false);

      expect(
        (await list()).failureOrNull,
        isA<GithubApiOperationFailed>().having(
          (GithubApiOperationFailed it) => it.description,
          'description',
          startsWith('gh: '),
        ),
      );
      expect(asked('arguments').existsSync(), isFalse);
    });

    test('none on the PATH is unavailable, for every method', () async {
      expect(
        (await repository()).failureOrNull,
        const GithubApiUnavailable('gh'),
      );
      expect((await list()).failureOrNull, const GithubApiUnavailable('gh'));
      expect((await create()).failureOrNull, const GithubApiUnavailable('gh'));
    });

    test(
      'a clone folder that is gone is a failure of its own — not "gh is '
      'not installed"',
      () async {
        gh('echo "[]"');

        final Result<String, GithubApiFailure> answered = await api()
            .openPullRequests(
              '${machine.path}/gone',
              repository: 'acme/docs',
              head: 'feat/x',
              token: 'tok-secret',
            );

        expect(answered.failureOrNull, isA<GithubApiOperationFailed>());
      },
      skip:
          'defect S7-GH-2: a working folder that is gone makes '
          '`Process.start` throw with errno 2, the same code as a missing '
          "program, so the answer is GithubApiUnavailable('gh') with gh "
          'on the PATH',
    );

    test('a request refused at the gate starts nothing, and names the '
        'command as it would have run', () async {
      gh('echo "[]"');

      final Result<String, GithubApiFailure> answered =
          await api(gate: const _ClosedGate()).openPullRequests(
            clone.path,
            repository: 'acme/docs',
            head: 'feat/x',
            token: 'tok-secret',
          );

      expect(
        answered.failureOrNull,
        isA<GithubApiCommandDenied>().having(
          (GithubApiCommandDenied it) => it.command,
          'command',
          allOf(startsWith('gh pr list'), isNot(contains('tok-secret'))),
        ),
      );
      expect(asked('arguments').existsSync(), isFalse);
    });
  });

  group('the open pull requests', () {
    test('are asked for the branch, from the clone, whatever its folder is '
        'called', () async {
      gh(
        'echo \'[{"number":7,"title":"Release notes",'
        '"url":"https://github.com/acme/docs/pull/7"}]\'',
      );

      final Result<String, GithubApiFailure> listed = await list();

      expect(
        (listed as Success<String, GithubApiFailure>).value.trim(),
        '[{"number":7,"title":"Release notes",'
        '"url":"https://github.com/acme/docs/pull/7"}]',
      );
      expect(arguments(), <String>[
        'pr',
        'list',
        '--repo',
        'github.com/acme/docs',
        '--head',
        'feat/x',
        '--state',
        'open',
        '--json',
        'number,url,title',
      ]);
      expect(
        Directory(
          asked('folder').readAsStringSync().trim(),
        ).resolveSymbolicLinksSync(),
        clone.resolveSymbolicLinksSync(),
      );
    });

    test(
      'a refused token is refused here too, in the words gh uses outside '
      '`gh api`',
      () async {
        ghSays(
          'HTTP 401: Bad credentials (https://api.github.com/graphql)\n'
          'Try authenticating with:  gh auth login',
        );

        expect((await list()).failureOrNull, const GithubApiRefused(401));
      },
      skip:
          'defect S7-GH-1: `gh pr list` and `gh pr create` report a status '
          'as `HTTP 401: …`, which `GhCliGithubApiImpl._status` '
          r'(`\(HTTP (\d{3})\)`, the wording of `gh api`) does not match — '
          'a refused token reads as GithubApiOperationFailed. Wording from '
          "gh's source, not checked against a live gh",
    );
  });

  group('opening a pull request', () {
    test('the one already open is named by its address', () async {
      ghSays(
        'a pull request for branch "feat/x" into branch "main" already '
        'exists:\n'
        'https://github.com/acme/docs/pull/7',
      );

      expect(
        (await create()).failureOrNull,
        const GithubApiPullRequestExists('https://github.com/acme/docs/pull/7'),
      );
    });

    test('any other refusal is the error stream, as it was said', () async {
      ghSays(
        'pull request create failed: GraphQL: No commits between main and '
        'feat/x (createPullRequest)',
      );

      expect(
        (await create()).failureOrNull,
        const GithubApiOperationFailed(
          'pull request create failed: GraphQL: No commits between main and '
          'feat/x (createPullRequest)',
        ),
      );
    });

    test('a title with quotes, a line break and a leading dash arrives as '
        'one argument', () async {
      gh('cat > /dev/null\necho "https://github.com/acme/docs/pull/8"');
      const String title = '--draft "quoted" \$HOME `id`\nsecond line';

      final Result<String, GithubApiFailure> created = await create(
        title: title,
      );

      expect(
        (created as Success<String, GithubApiFailure>).value,
        'https://github.com/acme/docs/pull/8',
      );
      expect(arguments(), <String>[
        'pr',
        'create',
        '--repo',
        'github.com/acme/docs',
        '--base',
        'main',
        '--head',
        'feat/x',
        '--title',
        title,
        '--body-file',
        '-',
      ]);
    });

    test('a hundred kilobytes of body arrive whole on the input', () async {
      gh(
        'cat > "\$out.input"\n'
        'echo "https://github.com/acme/docs/pull/9"',
      );
      final String body = '${'Ação — “why”. ' * 6000}\n';

      final Result<String, GithubApiFailure> created = await create(body: body);

      expect(created, isA<Success<String, GithubApiFailure>>());
      expect(body.length, greaterThan(80000));
      expect(asked('input').readAsStringSync(), body);
    });

    test("the person's language never reaches gh: it is asked in C, with "
        'no question and no update notice', () async {
      gh('cat > /dev/null\necho "https://github.com/acme/docs/pull/7"');

      await create(
        through: api(
          more: <String, String>{
            'LANG': 'pt_BR.UTF-8',
            'LC_ALL': 'pt_BR.UTF-8',
          },
        ),
      );

      expect(asked('environment').readAsStringSync(), 'C|pt_BR.UTF-8|1|1');
    });
  });
}

extension _Failed<T, F extends AppFailure> on Result<T, F> {
  /// What it failed with, or null when it worked.
  F? get failureOrNull => fold((T _) => null, (F failure) => failure);
}

/// Whether the process [pid] has ended, given a moment to.
Future<bool> _gone(String pid) async {
  for (int attempt = 0; attempt < 40; attempt++) {
    if (Process.runSync('kill', <String>['-0', pid]).exitCode != 0) {
      return true;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  return false;
}

/// A gate at which somebody says no — the port is ours, so this is an
/// implementation of it and not a stand-in for one.
final class _ClosedGate implements CommandGate {
  const _ClosedGate();

  @override
  CommandPlan plan(List<CommandRequest> commands) => const _RefusedPlan();
}

final class _RefusedPlan implements CommandPlan {
  const _RefusedPlan();

  @override
  Future<CommandVerdict> next() =>
      Future<CommandVerdict>.value(const CommandVerdict.denied());

  @override
  void close() {}
}
