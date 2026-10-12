import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _Credentials credentials;
  late _Api api;
  late GithubAccountRepositoryImpl repository;

  final RemoteProjectValueObject docs = RemoteProjectValueObject.tryParse(
    'https://github.com/acme/docs.git',
  )!;

  setUp(() {
    credentials = _Credentials();
    api = _Api();
    repository = GithubAccountRepositoryImpl(
      credentials: CredentialsDataSource(
        credentials: credentials,
        folder: '/code/app',
      ),
      api: GithubApiDataSource(api: api),
    );
  });

  Future<List<GithubAccountValueObject>> accounts() async =>
      (await repository.accounts()).valueOrNull!;

  List<String> logins(List<GithubAccountValueObject> found) =>
      found.map((GithubAccountValueObject it) => it.login).toList();

  group('the accounts', () {
    test(
      'a machine with nothing holds none, and GitHub is not asked',
      () async {
        expect(await accounts(), isEmpty);
        expect(api.asked, isEmpty);
      },
    );

    test(
      "gh's accounts come first, and listing them asks GitHub nothing",
      () async {
        credentials.gh =
            '{"hosts":{"github.com":[{"login":"ada","active":true}]}}';

        final List<GithubAccountValueObject> found = await accounts();

        expect(found.single.login, 'ada');
        expect(found.single.source, AccountSourceEnum.gh);
        expect(api.asked, isEmpty);
      },
    );

    test("git's credential names its login, and a new one joins", () async {
      credentials
        ..gh = '{"hosts":{"github.com":[{"login":"ada","active":true}]}}'
        ..git =
            'protocol=https\nhost=github.com\nusername=grace\n'
            'password=tok-git\n';

      final List<GithubAccountValueObject> found = await accounts();

      expect(logins(found), <String>['ada', 'grace']);
      expect(found.last.source, AccountSourceEnum.git);
    });

    test('a login two tools hold is listed once, as the first', () async {
      credentials
        ..gh = '{"hosts":{"github.com":[{"login":"ada","active":true}]}}'
        ..git = 'username=ada\npassword=tok-git\n'
        ..ssh = "Hi ada! You've successfully authenticated";

      expect((await accounts()).single.source, AccountSourceEnum.gh);
    });

    test('an SSH key alone still says who the person is', () async {
      credentials.ssh =
          "Hi linus! You've successfully authenticated, but GitHub does not "
          'provide shell access.';

      final List<GithubAccountValueObject> found = await accounts();

      expect(found.single.login, 'linus');
      expect(found.single.source, AccountSourceEnum.ssh);
    });

    test(
      'a tool that fails holds nothing, and the rest still answer',
      () async {
        credentials
          ..ghFails = true
          ..ssh = "Hi linus! You've successfully authenticated";

        expect(logins(await accounts()), <String>['linus']);
      },
    );

    test('a refused question is a refusal, never "nobody is here"', () async {
      credentials
        ..refuses = <String>{'gh auth status'}
        ..ssh = "Hi linus! You've successfully authenticated";

      final Result<List<GithubAccountValueObject>, AccountFailure> asked =
          await repository.accounts();

      expect(
        (asked as Failure<List<GithubAccountValueObject>, AccountFailure>)
            .failure,
        isA<AccountDenied>(),
      );
      expect(asked.failure.isDenial, isTrue);
      expect(credentials.asked, <String>['gh auth status']);
    });

    test('refusing the second tool stops there too', () async {
      credentials.refuses = <String>{'git credential fill'};

      expect(
        await repository.accounts(),
        isA<Failure<List<GithubAccountValueObject>, AccountFailure>>(),
      );
      expect(credentials.asked, <String>[
        'gh auth status',
        'git credential fill',
      ]);
    });
  });

  group('what an account may do', () {
    const GithubAccountValueObject ada = GithubAccountValueObject(
      login: 'ada',
      source: AccountSourceEnum.gh,
    );

    test("gh's token for that login is the one handed over", () async {
      credentials.tokens = <String, String>{'ada': 'tok-ada'};
      api.repositories = <String, String>{
        'tok-ada': '{"permissions":{"pull":true,"push":true,"admin":false}}',
      };

      expect(
        (await repository.access(ada, docs)).valueOrNull,
        RepositoryAccessValueObject.granted(
          pull: true,
          push: true,
          admin: false,
        ),
      );
      expect(api.asked, <String>['acme/docs']);
    });

    test('an SSH login has no token, so nothing is asked', () async {
      final Result<RepositoryAccessValueObject?, AccountFailure> result =
          await repository.access(
            const GithubAccountValueObject(
              login: 'linus',
              source: AccountSourceEnum.ssh,
            ),
            docs,
          );

      expect(result.valueOrNull, isNull);
      expect(api.asked, isEmpty);
    });

    test("git's own token is used for the account git holds", () async {
      credentials.git = 'username=grace\npassword=tok-git\n';
      api.repositories = <String, String>{
        'tok-git': '{"permissions":{"pull":true,"push":false,"admin":false}}',
      };

      final RepositoryAccessValueObject? access = (await repository.access(
        const GithubAccountValueObject(
          login: 'grace',
          source: AccountSourceEnum.git,
        ),
        docs,
      )).valueOrNull;

      expect(access?.canRead, isTrue);
      expect(access?.canPush, isFalse);
    });

    test(
      'without gh, or a repository GitHub hides, nothing is known',
      () async {
        credentials.tokens = <String, String>{'ada': 'tok-ada'};

        expect((await repository.access(ada, docs)).valueOrNull, isNull);

        api.missing = true;

        final Result<RepositoryAccessValueObject?, AccountFailure> result =
            await repository.access(ada, docs);

        expect(
          result,
          isA<Success<RepositoryAccessValueObject?, AccountFailure>>(),
        );
        expect(result.valueOrNull, isNull);
      },
    );

    test(
      'out of reach and refused come back in the product vocabulary',
      () async {
        credentials.tokens = <String, String>{'ada': 'tok-ada'};
        api.unreachable = true;

        expect(
          (await repository.access(ada, docs)
                  as Failure<RepositoryAccessValueObject?, AccountFailure>)
              .failure,
          isA<AccountUnreachable>(),
        );

        api
          ..unreachable = false
          ..refused = true;

        expect(
          (await repository.access(ada, docs)
                  as Failure<RepositoryAccessValueObject?, AccountFailure>)
              .failure,
          isA<AccountRefused>(),
        );
      },
    );

    test('a refused token is a refusal, and GitHub is not asked', () async {
      credentials
        ..tokens = <String, String>{'ada': 'tok-ada'}
        ..refuses = <String>{'gh auth token'};

      expect(
        (await repository.access(ada, docs)
                as Failure<RepositoryAccessValueObject?, AccountFailure>)
            .failure,
        isA<AccountDenied>(),
      );
      expect(api.asked, isEmpty);
    });

    test('a refused request to GitHub is a refusal too', () async {
      credentials.tokens = <String, String>{'ada': 'tok-ada'};
      api.denied = true;

      expect(
        (await repository.access(ada, docs)
                as Failure<RepositoryAccessValueObject?, AccountFailure>)
            .failure,
        isA<AccountDenied>(),
      );
    });
  });
}

/// The machine's tools, answering what each test says they hold.
final class _Credentials implements Credentials {
  String gh = '';
  bool ghFails = false;
  Map<String, String> tokens = <String, String>{};
  String git = '';
  String ssh = '';

  /// The questions the person says no to, by what they start with.
  Set<String> refuses = <String>{};

  /// Every question put, in order.
  final List<String> asked = <String>[];

  /// [answer], unless the person refuses [question].
  Result<String, CredentialsFailure> _ask(String question, String answer) {
    asked.add(question);
    return refuses.contains(question)
        ? Failure<String, CredentialsFailure>(
            CredentialsCommandDenied(question),
          )
        : Success<String, CredentialsFailure>(answer);
  }

  @override
  Future<Result<String, CredentialsFailure>> ghAccounts(String host) async =>
      ghFails
      ? const Failure<String, CredentialsFailure>(CredentialsTimedOut('gh'))
      : _ask('gh auth status', gh);

  @override
  Future<Result<String, CredentialsFailure>> ghToken(
    String host,
    String login,
  ) async => _ask('gh auth token', tokens[login] ?? '');

  @override
  Future<Result<String, CredentialsFailure>> gitCredential(
    String host, {
    required String folder,
  }) async => _ask('git credential fill', git);

  @override
  Future<Result<String, CredentialsFailure>> sshGreeting(String host) async =>
      _ask('ssh', ssh);
}

/// GitHub through `gh`, answering per token.
final class _Api implements GithubApi {
  Map<String, String> repositories = <String, String>{};
  bool missing = false;
  bool unreachable = false;
  bool refused = false;
  bool denied = false;
  final List<String> asked = <String>[];

  @override
  Future<Result<String, GithubApiFailure>> repository(
    String path, {
    required String token,
  }) async {
    asked.add(path);
    if (denied) {
      return const Failure<String, GithubApiFailure>(
        GithubApiCommandDenied('gh api'),
      );
    }
    if (missing) {
      return const Failure<String, GithubApiFailure>(
        GithubApiUnavailable('gh'),
      );
    }
    if (unreachable) {
      return const Failure<String, GithubApiFailure>(
        GithubApiUnreachable('offline'),
      );
    }
    if (refused) {
      return const Failure<String, GithubApiFailure>(GithubApiRefused(401));
    }
    return repositories[token] == null
        ? const Failure<String, GithubApiFailure>(GithubApiNotFound())
        : Success<String, GithubApiFailure>(repositories[token]!);
  }

  @override
  Future<Result<String, GithubApiFailure>> openPullRequests(
    String folder, {
    required String repository,
    required String head,
    required String token,
  }) => throw UnimplementedError('the account never lists pull requests');

  @override
  Future<Result<String, GithubApiFailure>> createPullRequest(
    String folder, {
    required String repository,
    required String base,
    required String head,
    required String title,
    required String body,
    required String token,
  }) => throw UnimplementedError('the account never opens a pull request');
}
