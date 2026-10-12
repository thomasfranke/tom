/// [GithubAccountRepositoryImpl] over the real credentials and `gh`
/// capabilities and the real parsers: `gh` and `ssh` are scripts on a
/// `PATH` of the test's own, git is the real one with a helper the test
/// wrote, and nothing reaches GitHub.
@TestOn('!windows')
library;

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

  setUp(() => machine = ScriptedMachine());

  tearDown(() => machine.dispose());

  GithubAccountRepositoryImpl repository({
    CommandGate gate = const OpenCommandGateImpl(),
  }) => GithubAccountRepositoryImpl(
    credentials: CredentialsDataSource(
      credentials: machine.credentials(gate: gate),
      folder: machine.clone,
    ),
    api: GithubApiDataSource(api: machine.api(gate: gate)),
  );

  /// A `gh` signed in as [status] says, holding `tok-of-<login>` for every
  /// login, and answering `gh api` with [api].
  void gh({
    String status =
        'echo \'{"hosts":{"github.com":['
        '{"login":"grace","active":false},{"login":"ada","active":true}]}}\'',
    String api = 'echo "{}"',
  }) => machine.program(
    'gh',
    'case "\$1 \$2" in\n'
        '  "auth status") $status ;;\n'
        '  "auth token") echo "tok-of-\$6" ;;\n'
        '  "api --hostname") $api ;;\n'
        'esac',
  );

  /// An `ssh` that GitHub greets as [login].
  void ssh(String login) => machine.program(
    'ssh',
    'echo "Hi $login! You\'ve successfully authenticated, but GitHub does '
        'not provide shell access." >&2\n'
        'exit 1',
  );

  Future<List<GithubAccountValueObject>> accounts() async =>
      (await repository().accounts()).valueOrNull!;

  group('the accounts this machine holds', () {
    test("come from gh, git's helper and ssh in that order, the active one "
        'first and each login once', () async {
      gh();
      machine.credentialHelper(login: 'hopper', password: 'tok-from-helper');
      ssh('grace');

      expect(await accounts(), const <GithubAccountValueObject>[
        ada,
        GithubAccountValueObject(login: 'grace', source: AccountSourceEnum.gh),
        hopper,
      ]);
    });

    test('an SSH key alone still says who the person is', () async {
      ssh('linus');

      expect(await accounts(), const <GithubAccountValueObject>[
        GithubAccountValueObject(login: 'linus', source: AccountSourceEnum.ssh),
      ]);
    });

    test('a machine with git and nothing else holds none', () async {
      expect(await accounts(), isEmpty);
    });

    test('a gh too old for --json is read from its report', () async {
      gh(
        status:
            'case "\$*" in\n'
            '      *--json*) echo "unknown flag: --json" >&2; exit 1 ;;\n'
            '    esac\n'
            '    echo "github.com" >&2\n'
            '    echo "  ✓ Logged in to github.com as ada (oauth_token)" >&2',
      );

      expect(await accounts(), const <GithubAccountValueObject>[ada]);
    });

    test('a gh with nobody signed in, and a helper that stored no login, '
        'hold none', () async {
      gh(
        status: 'echo "You are not logged into any GitHub hosts." >&2; exit 1',
      );
      machine.credentialHelper(login: 'x-access-token', password: 'ghs_app');

      expect(await accounts(), isEmpty);
    });

    test('a refused question is a refusal, never "nobody is here", and '
        'nothing after it is asked', () async {
      gh();
      ssh('linus');

      final Result<List<GithubAccountValueObject>, AccountFailure> asked =
          await repository(gate: const RefusingGate('auth status')).accounts();

      final AccountFailure failure =
          (asked as Failure<List<GithubAccountValueObject>, AccountFailure>)
              .failure;
      expect(failure, isA<AccountDenied>());
      expect(failure.isDenial, isTrue);
      expect(machine.asked('gh'), isEmpty);
      expect(machine.asked('ssh'), isEmpty);
    });
  });

  group('what an account may do on a repository', () {
    const String canPush =
        'echo \'{"full_name":"acme/docs","permissions":'
        '{"admin":false,"push":true,"pull":true}}\'';

    test(
      "gh's own token for that login is the one GitHub is asked with",
      () async {
        gh(api: canPush);

        final Result<RepositoryAccessValueObject?, AccountFailure> access =
            await repository().access(ada, docs);

        expect(
          access.valueOrNull,
          const RepositoryAccessValueObject(
            canRead: true,
            canOpenPullRequests: true,
            canPush: true,
            canMerge: true,
            canAdminister: false,
          ),
        );
        expect(machine.asked('gh'), <String>[
          '|auth token --hostname github.com --user ada',
          'tok-of-ada|api --hostname github.com repos/acme/docs',
        ]);
      },
    );

    test("an account read from git's helper is asked with the helper's "
        'password', () async {
      gh(api: canPush);
      machine.credentialHelper(login: 'hopper', password: 'tok-from-helper');

      final Result<RepositoryAccessValueObject?, AccountFailure> access =
          await repository().access(hopper, docs);

      expect(access.valueOrNull?.canPush, isTrue);
      expect(machine.asked('gh'), <String>[
        'tok-from-helper|api --hostname github.com repos/acme/docs',
      ]);
    });

    test('a token that may only read grants reading alone', () async {
      gh(
        api:
            'echo \'{"permissions":'
            '{"admin":false,"push":false,"pull":true}}\'',
      );

      expect(
        (await repository().access(ada, docs)).valueOrNull,
        const RepositoryAccessValueObject(
          canRead: true,
          canOpenPullRequests: false,
          canPush: false,
          canMerge: false,
          canAdminister: false,
        ),
      );
    });

    test('a repository the token cannot see is nothing known, not a '
        'failure', () async {
      gh(
        api:
            'echo \'{"message":"Not Found"}\'; '
            'echo "gh: Not Found (HTTP 404)" >&2; exit 1',
      );

      final Result<RepositoryAccessValueObject?, AccountFailure> access =
          await repository().access(ada, docs);

      expect(
        access,
        isA<Success<RepositoryAccessValueObject?, AccountFailure>>(),
      );
      expect(access.valueOrNull, isNull);
    });

    test('an SSH key holds no token: nothing is known and GitHub is never '
        'asked', () async {
      gh(api: canPush);

      final Result<RepositoryAccessValueObject?, AccountFailure> access =
          await repository().access(
            const GithubAccountValueObject(
              login: 'linus',
              source: AccountSourceEnum.ssh,
            ),
            docs,
          );

      expect(
        access,
        isA<Success<RepositoryAccessValueObject?, AccountFailure>>(),
      );
      expect(access.valueOrNull, isNull);
      expect(machine.asked('gh'), isEmpty);
    });

    test('a login gh holds no token for is nothing known, and GitHub is '
        'never asked', () async {
      machine.program(
        'gh',
        'echo "no oauth token found for github.com account ada" >&2\nexit 1',
      );

      final Result<RepositoryAccessValueObject?, AccountFailure> access =
          await repository().access(ada, docs);

      expect(
        access,
        isA<Success<RepositoryAccessValueObject?, AccountFailure>>(),
      );
      expect(access.valueOrNull, isNull);
      expect(machine.asked('gh'), <String>[
        '|auth token --hostname github.com --user ada',
      ]);
    });

    test(
      "without gh a helper's account has nobody to ask: nothing known",
      () async {
        machine.credentialHelper(login: 'hopper', password: 'tok-from-helper');

        final Result<RepositoryAccessValueObject?, AccountFailure> access =
            await repository().access(hopper, docs);

        expect(
          access,
          isA<Success<RepositoryAccessValueObject?, AccountFailure>>(),
        );
        expect(access.valueOrNull, isNull);
      },
    );

    test(
      'a token GitHub refuses is a refusal, with what gh said under it',
      () async {
        gh(api: 'echo "gh: Bad credentials (HTTP 401)" >&2; exit 1');

        final AccountFailure failure = _failureOf(
          await repository().access(ada, docs),
        );

        expect(failure, isA<AccountRefused>());
        expect(failure.cause, const GithubApiRefused(401));
      },
    );

    test('no connection is unreachable', () async {
      gh(
        api:
            'echo "error connecting to api.github.com" >&2; '
            'echo "check your internet connection or '
            'https://githubstatus.com" >&2; exit 1',
      );

      expect(
        _failureOf(await repository().access(ada, docs)),
        isA<AccountUnreachable>(),
      );
    });

    test('any other answer is a failure carrying it', () async {
      gh(api: 'echo "gh: Server Error (HTTP 502)" >&2; exit 1');

      final AccountFailure failure = _failureOf(
        await repository().access(ada, docs),
      );

      expect(failure, isA<AccountOperationFailed>());
      expect(
        failure.cause,
        const GithubApiOperationFailed('gh: Server Error (HTTP 502)'),
      );
    });

    test('a body with no permissions in it is nothing known', () async {
      gh(api: 'echo \'{"full_name":"acme/docs"}\'');

      final Result<RepositoryAccessValueObject?, AccountFailure> access =
          await repository().access(ada, docs);

      expect(
        access,
        isA<Success<RepositoryAccessValueObject?, AccountFailure>>(),
      );
      expect(access.valueOrNull, isNull);
    });

    test('refusing the token question is a refusal, and GitHub is never '
        'asked', () async {
      gh(api: canPush);

      final AccountFailure failure = _failureOf(
        await repository(
          gate: const RefusingGate('auth token'),
        ).access(ada, docs),
      );

      expect(failure, isA<AccountDenied>());
      expect(machine.asked('gh'), isEmpty);
    });

    test('refusing the question to GitHub is a refusal too, after the '
        'token was read', () async {
      gh(api: canPush);

      final AccountFailure failure = _failureOf(
        await repository(gate: const RefusingGate('gh api')).access(ada, docs),
      );

      expect(failure, isA<AccountDenied>());
      expect(machine.asked('gh'), <String>[
        '|auth token --hostname github.com --user ada',
      ]);
    });
  });
}

/// What [result] failed with.
AccountFailure _failureOf<T>(Result<T, AccountFailure> result) =>
    (result as Failure<T, AccountFailure>).failure;
