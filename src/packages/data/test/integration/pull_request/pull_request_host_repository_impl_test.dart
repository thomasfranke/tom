/// [PullRequestHostRepositoryImpl] over the real credentials and `gh`
/// capabilities and the real parser: `gh` is a script on a `PATH` of the
/// test's own that writes down what reached it, git is the real one, and
/// nothing reaches GitHub.
@TestOn('!windows')
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

import '../../support/scripted_machine.dart';

void main() {
  late ScriptedMachine machine;

  final RemoteProjectValueObject docs = RemoteProjectValueObject.tryParse(
    'git@github.com:acme/docs.git',
  )!;
  const GithubAccountValueObject ada = GithubAccountValueObject(
    login: 'ada',
    source: AccountSourceEnum.gh,
  );
  const GithubAccountValueObject hopper = GithubAccountValueObject(
    login: 'hopper',
    source: AccountSourceEnum.git,
  );
  final BranchNameValueObject feature = BranchNameValueObject('feat/x');
  final BranchNameValueObject main = BranchNameValueObject('main');

  setUp(() => machine = ScriptedMachine());

  tearDown(() => machine.dispose());

  PullRequestHostRepositoryImpl repository({
    CommandGate gate = const OpenCommandGateImpl(),
  }) => PullRequestHostRepositoryImpl(
    tokens: GithubTokenReader(
      credentials: CredentialsDataSource(
        credentials: machine.credentials(gate: gate),
        folder: machine.clone,
      ),
    ),
    api: GithubApiDataSource(api: machine.api(gate: gate)),
    folder: machine.clone,
  );

  /// A `gh` holding `tok-of-<login>` for every login, answering `gh pr
  /// list` with [list] and `gh pr create` — its input and its folder
  /// written down first — with [create].
  void gh({
    String list = 'echo "[]"',
    String create = 'exit 0',
  }) => machine.program(
    'gh',
    'case "\$1 \$2" in\n'
        '  "auth token") echo "tok-of-\$6" ;;\n'
        '  "pr list") /bin/pwd > "${machine.root.path}/gh.folder"; $list ;;\n'
        '  "pr create") /bin/pwd > "${machine.root.path}/gh.folder"\n'
        '    /bin/cat > "${machine.root.path}/gh.input"; $create ;;\n'
        'esac',
  );

  String folderAsked() => Directory(
    File('${machine.root.path}/gh.folder').readAsStringSync().trim(),
  ).resolveSymbolicLinksSync();

  Future<Result<OpenedPullRequestValueObject, PullRequestHostFailure>> create({
    GithubAccountValueObject account = ada,
    CommandGate gate = const OpenCommandGateImpl(),
  }) => repository(gate: gate).create(
    account,
    docs,
    base: main,
    head: feature,
    title: 'Release notes',
    body: 'Why it exists — in “quotes”.\n',
  );

  group('the one already open', () {
    test('none is null, asked as the account from the clone', () async {
      gh();

      final Result<OpenedPullRequestValueObject?, PullRequestHostFailure>
      found = await repository().openFrom(ada, docs, feature);

      expect(
        found,
        isA<Success<OpenedPullRequestValueObject?, PullRequestHostFailure>>(),
      );
      expect(found.valueOrNull, isNull);
      expect(machine.asked('gh'), <String>[
        '|auth token --hostname github.com --user ada',
        'tok-of-ada|pr list --repo github.com/acme/docs --head feat/x '
            '--state open --json number,url,title',
      ]);
      expect(
        folderAsked(),
        Directory(machine.clone).resolveSymbolicLinksSync(),
      );
    });

    test('one is its number, its page and the title the host holds', () async {
      gh(
        list:
            'echo \'[{"number":7,"title":"Notes, retitled on the host",'
            '"url":"https://github.com/acme/docs/pull/7"}]\'',
      );

      final Result<OpenedPullRequestValueObject?, PullRequestHostFailure>
      found = await repository().openFrom(ada, docs, feature);

      expect(
        found.valueOrNull,
        OpenedPullRequestValueObject(
          number: 7,
          address: Uri.parse('https://github.com/acme/docs/pull/7'),
          title: 'Notes, retitled on the host',
        ),
      );
    });

    test('an answer that is not the list asked for is none', () async {
      gh(list: 'echo "no pull requests match your search in acme/docs"');

      final Result<OpenedPullRequestValueObject?, PullRequestHostFailure>
      found = await repository().openFrom(ada, docs, feature);

      expect(
        found,
        isA<Success<OpenedPullRequestValueObject?, PullRequestHostFailure>>(),
      );
      expect(found.valueOrNull, isNull);
    });

    test("an account read from git's helper asks with the helper's "
        'password', () async {
      gh();
      machine.credentialHelper(login: 'hopper', password: 'tok-from-helper');

      await repository().openFrom(hopper, docs, feature);

      expect(machine.asked('gh'), <String>[
        'tok-from-helper|pr list --repo github.com/acme/docs --head feat/x '
            '--state open --json number,url,title',
      ]);
    });

    test('no connection is unreachable', () async {
      gh(
        list:
            'echo "error connecting to api.github.com" >&2; '
            'echo "check your internet connection or '
            'https://githubstatus.com" >&2; exit 1',
      );

      expect(
        _failureOf(await repository().openFrom(ada, docs, feature)),
        isA<PullRequestHostUnreachable>(),
      );
    });

    test('any other answer is a failure carrying what gh said', () async {
      gh(
        list:
            'echo "GraphQL: Could not resolve to a Repository with the name '
            "'acme/docs'. (repository)\" >&2; exit 1",
      );

      final PullRequestHostFailure failure = _failureOf(
        await repository().openFrom(ada, docs, feature),
      );

      expect(failure, isA<PullRequestHostOperationFailed>());
      expect(
        failure.cause,
        const GithubApiOperationFailed(
          'GraphQL: Could not resolve to a Repository with the name '
          "'acme/docs'. (repository)",
        ),
      );
    });
  });

  group('no way to ask', () {
    test(
      'an SSH key holds no token: unavailable, and gh is never started',
      () async {
        gh();

        final PullRequestHostFailure failure = _failureOf(
          await repository().openFrom(
            const GithubAccountValueObject(
              login: 'linus',
              source: AccountSourceEnum.ssh,
            ),
            docs,
            feature,
          ),
        );

        expect(failure, isA<PullRequestHostUnavailable>());
        expect(machine.asked('gh'), isEmpty);
      },
    );

    test(
      'a login gh holds no token for: unavailable, and nothing is sent',
      () async {
        machine.program(
          'gh',
          'echo "no oauth token found for github.com account ada" >&2\nexit 1',
        );

        expect(_failureOf(await create()), isA<PullRequestHostUnavailable>());
        expect(machine.asked('gh'), <String>[
          '|auth token --hostname github.com --user ada',
        ]);
      },
    );

    test(
      'a project on another host: unavailable, and nothing is started',
      () async {
        gh();

        final PullRequestHostFailure failure = _failureOf(
          await repository().openFrom(
            ada,
            RemoteProjectValueObject.tryParse('git@gitlab.com:acme/docs.git')!,
            feature,
          ),
        );

        expect(failure, isA<PullRequestHostUnavailable>());
        expect(machine.asked('gh'), isEmpty);
      },
    );

    test("without gh a helper's account has nobody to ask: unavailable, "
        'naming gh under it', () async {
      machine.credentialHelper(login: 'hopper', password: 'tok-from-helper');

      final PullRequestHostFailure failure = _failureOf(
        await create(account: hopper),
      );

      expect(failure, isA<PullRequestHostUnavailable>());
      expect(failure.cause, const GithubApiUnavailable('gh'));
    });
  });

  group('opening one', () {
    test('is the pull request at the address gh printed, the body on its '
        'input and the token never in an argument', () async {
      gh(create: 'echo "https://github.com/acme/docs/pull/12"');

      final Result<OpenedPullRequestValueObject, PullRequestHostFailure>
      opened = await create();

      expect(
        opened.valueOrNull,
        OpenedPullRequestValueObject(
          number: 12,
          address: Uri.parse('https://github.com/acme/docs/pull/12'),
          title: 'Release notes',
        ),
      );
      expect(machine.asked('gh'), <String>[
        '|auth token --hostname github.com --user ada',
        'tok-of-ada|pr create --repo github.com/acme/docs --base main '
            '--head feat/x --title Release notes --body-file -',
      ]);
      expect(
        File('${machine.root.path}/gh.input').readAsStringSync(),
        'Why it exists — in “quotes”.\n',
      );
      expect(
        folderAsked(),
        Directory(machine.clone).resolveSymbolicLinksSync(),
      );
    });

    test('the one already open is the answer, not a refusal', () async {
      gh(
        create:
            'echo \'a pull request for branch "feat/x" into branch "main" '
            "already exists:' >&2; "
            'echo "https://github.com/acme/docs/pull/7" >&2; exit 1',
      );

      final Result<OpenedPullRequestValueObject, PullRequestHostFailure>
      opened = await create();

      expect(
        opened.valueOrNull,
        OpenedPullRequestValueObject(
          number: 7,
          address: Uri.parse('https://github.com/acme/docs/pull/7'),
          title: 'Release notes',
        ),
      );
    });

    test(
      'a gh that says it worked and prints no address is a failure',
      () async {
        gh(create: 'echo "Creating pull request for feat/x into main"');

        expect(
          _failureOf(await create()),
          const PullRequestHostOperationFailed(),
        );
      },
    );

    test('a refusal gh words itself is a failure carrying it', () async {
      gh(
        create:
            'echo "pull request create failed: GraphQL: No commits between '
            'main and feat/x (createPullRequest)" >&2; exit 1',
      );

      final PullRequestHostFailure failure = _failureOf(await create());

      expect(failure, isA<PullRequestHostOperationFailed>());
      expect(failure.cause, isA<GithubApiOperationFailed>());
    });

    test('refusing the token question sends nothing', () async {
      gh(create: 'echo "https://github.com/acme/docs/pull/12"');

      final PullRequestHostFailure failure = _failureOf(
        await create(gate: const RefusingGate('auth token')),
      );

      expect(failure, isA<PullRequestHostDenied>());
      expect(failure.isDenial, isTrue);
      expect(machine.asked('gh'), isEmpty);
    });

    test('refusing the creation itself sends nothing either, after the '
        'token was read', () async {
      gh(create: 'echo "https://github.com/acme/docs/pull/12"');

      final PullRequestHostFailure failure = _failureOf(
        await create(gate: const RefusingGate('pr create')),
      );

      expect(failure, isA<PullRequestHostDenied>());
      expect(machine.asked('gh'), <String>[
        '|auth token --hostname github.com --user ada',
      ]);
      expect(File('${machine.root.path}/gh.input').existsSync(), isFalse);
    });
  });
}

/// What [result] failed with.
PullRequestHostFailure _failureOf<T>(
  Result<T, PullRequestHostFailure> result,
) => (result as Failure<T, PullRequestHostFailure>).failure;
