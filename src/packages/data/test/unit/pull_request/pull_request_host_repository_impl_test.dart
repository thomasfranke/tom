/// [PullRequestHostRepositoryImpl] over a recorded `gh`: the token is the
/// account's, the clone is where `gh` runs, and each answer has its name.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _Credentials credentials;
  late _Api api;
  late PullRequestHostRepositoryImpl repository;

  final RemoteProjectValueObject docs = RemoteProjectValueObject.tryParse(
    'git@github.com:acme/docs.git',
  )!;
  const GithubAccountValueObject ada = GithubAccountValueObject(
    login: 'ada',
    source: AccountSourceEnum.gh,
  );
  final BranchNameValueObject feature = BranchNameValueObject('feat/x');
  final BranchNameValueObject main = BranchNameValueObject('main');

  setUp(() {
    credentials = _Credentials();
    api = _Api();
    repository = PullRequestHostRepositoryImpl(
      tokens: GithubTokenReader(
        credentials: CredentialsDataSource(
          credentials: credentials,
          folder: '/code/app',
        ),
      ),
      api: GithubApiDataSource(api: api),
      folder: '/code/app',
    );
  });

  Future<Result<OpenedPullRequestValueObject, PullRequestHostFailure>>
  create() => repository.create(
    ada,
    docs,
    base: main,
    head: feature,
    title: 'Release notes',
    body: 'Why it exists.\n',
  );

  group('the one already open', () {
    test('none is null, asked as the account from the clone', () async {
      api.listed = '[]';

      final Result<OpenedPullRequestValueObject?, PullRequestHostFailure>
      found = await repository.openFrom(ada, docs, feature);

      expect(found.valueOrNull, isNull);
      expect(found, isA<Success<Object?, Object?>>());
      expect(api.asked.single, <String>[
        'list',
        '/code/app',
        'acme/docs',
        'feat/x',
        'tok-ada',
      ]);
    });

    test('one is the pull request', () async {
      api.listed =
          '[{"number":123,"url":"https://github.com/acme/docs/pull/123",'
          '"title":"Release notes"}]';

      final OpenedPullRequestValueObject? found = (await repository.openFrom(
        ada,
        docs,
        feature,
      )).valueOrNull;

      expect(found?.number, 123);
    });

    test('an account with no token cannot ask, and gh is not run', () async {
      credentials.tokens.clear();

      final Result<OpenedPullRequestValueObject?, PullRequestHostFailure>
      found = await repository.openFrom(ada, docs, feature);

      expect(
        (found
                as Failure<
                  OpenedPullRequestValueObject?,
                  PullRequestHostFailure
                >)
            .failure,
        const PullRequestHostUnavailable(),
      );
      expect(api.asked, isEmpty);
    });

    test('a host that is not GitHub cannot be asked', () async {
      final Result<OpenedPullRequestValueObject?, PullRequestHostFailure>
      found = await repository.openFrom(
        ada,
        RemoteProjectValueObject.tryParse('https://gitlab.com/acme/docs')!,
        feature,
      );

      expect(
        (found
                as Failure<
                  OpenedPullRequestValueObject?,
                  PullRequestHostFailure
                >)
            .failure,
        isA<PullRequestHostUnavailable>(),
      );
      expect(api.asked, isEmpty);
    });

    test('without gh there is nobody to ask', () async {
      api.failure = const GithubApiUnavailable('gh');

      final Result<OpenedPullRequestValueObject?, PullRequestHostFailure>
      found = await repository.openFrom(ada, docs, feature);

      expect(
        (found
                as Failure<
                  OpenedPullRequestValueObject?,
                  PullRequestHostFailure
                >)
            .failure,
        isA<PullRequestHostUnavailable>(),
      );
    });
  });

  group('opening one', () {
    test('answers the pull request gh created, titled as asked', () async {
      api.printed = 'https://github.com/acme/docs/pull/7';

      final OpenedPullRequestValueObject? created =
          (await create()).valueOrNull;

      expect(created?.number, 7);
      expect(created?.title, 'Release notes');
      expect(api.asked.single, <String>[
        'create',
        '/code/app',
        'acme/docs',
        'main',
        'feat/x',
        'Release notes',
        'Why it exists.\n',
        'tok-ada',
      ]);
    });

    test('one already open is the answer, not a refusal', () async {
      api.failure = const GithubApiPullRequestExists(
        'https://github.com/acme/docs/pull/12',
      );

      expect((await create()).valueOrNull?.number, 12);
    });

    test('each refusal keeps its name', () async {
      api.failure = const GithubApiUnreachable('offline');
      expect(
        (await create()
                as Failure<
                  OpenedPullRequestValueObject,
                  PullRequestHostFailure
                >)
            .failure,
        isA<PullRequestHostUnreachable>(),
      );

      api.failure = const GithubApiRefused(401);
      expect(
        (await create()
                as Failure<
                  OpenedPullRequestValueObject,
                  PullRequestHostFailure
                >)
            .failure,
        isA<PullRequestHostRefused>(),
      );

      api.failure = const GithubApiOperationFailed('No commits between');
      expect(
        (await create()
                as Failure<
                  OpenedPullRequestValueObject,
                  PullRequestHostFailure
                >)
            .failure,
        isA<PullRequestHostOperationFailed>(),
      );
    });

    test('a token from git’s credential helper serves as well', () async {
      api.printed = 'https://github.com/acme/docs/pull/8';
      credentials.git = 'username=ada\npassword=tok-helper\n';

      await repository.create(
        const GithubAccountValueObject(
          login: 'ada',
          source: AccountSourceEnum.git,
        ),
        docs,
        base: main,
        head: feature,
        title: 't',
        body: '',
      );

      expect(api.asked.single.last, 'tok-helper');
    });

    test('a refused command is a refusal of its own, not a fault', () async {
      api.failure = const GithubApiCommandDenied('gh pr create');

      final PullRequestHostFailure refused =
          (await create()
                  as Failure<
                    OpenedPullRequestValueObject,
                    PullRequestHostFailure
                  >)
              .failure;

      expect(refused, isA<PullRequestHostDenied>());
      expect(refused.isDenial, isTrue);
    });

    test('a refused token is one too, and gh is never reached', () async {
      credentials.refusesToken = true;

      expect(
        (await create()
                as Failure<
                  OpenedPullRequestValueObject,
                  PullRequestHostFailure
                >)
            .failure,
        isA<PullRequestHostDenied>(),
      );
      expect(
        (await repository.openFrom(ada, docs, feature)
                as Failure<
                  OpenedPullRequestValueObject?,
                  PullRequestHostFailure
                >)
            .failure,
        isA<PullRequestHostDenied>(),
      );
      expect(api.asked, isEmpty);
    });
  });
}

/// The machine's tools: `gh` holds a token for ada.
final class _Credentials implements Credentials {
  Map<String, String> tokens = <String, String>{'ada': 'tok-ada'};
  String git = '';

  /// Whether the person says no to reading a token.
  bool refusesToken = false;

  @override
  Future<Result<String, CredentialsFailure>> ghAccounts(String host) async =>
      const Success<String, CredentialsFailure>('');

  @override
  Future<Result<String, CredentialsFailure>> ghToken(
    String host,
    String login,
  ) async => refusesToken
      ? const Failure<String, CredentialsFailure>(
          CredentialsCommandDenied('gh auth token'),
        )
      : Success<String, CredentialsFailure>(tokens[login] ?? '');

  @override
  Future<Result<String, CredentialsFailure>> gitCredential(
    String host, {
    required String folder,
  }) async => Success<String, CredentialsFailure>(git);

  @override
  Future<Result<String, CredentialsFailure>> sshGreeting(String host) async =>
      const Success<String, CredentialsFailure>('');
}

/// `gh`, writing down each call and answering what the test set.
final class _Api implements GithubApi {
  String listed = '[]';
  String printed = '';
  GithubApiFailure? failure;
  final List<List<String>> asked = <List<String>>[];

  @override
  Future<Result<String, GithubApiFailure>> repository(
    String path, {
    required String token,
  }) => throw UnimplementedError('never asked here');

  @override
  Future<Result<String, GithubApiFailure>> openPullRequests(
    String folder, {
    required String repository,
    required String head,
    required String token,
  }) async {
    asked.add(<String>['list', folder, repository, head, token]);
    return failure == null
        ? Success<String, GithubApiFailure>(listed)
        : Failure<String, GithubApiFailure>(failure!);
  }

  @override
  Future<Result<String, GithubApiFailure>> createPullRequest(
    String folder, {
    required String repository,
    required String base,
    required String head,
    required String title,
    required String body,
    required String token,
  }) async {
    asked.add(<String>[
      'create',
      folder,
      repository,
      base,
      head,
      title,
      body,
      token,
    ]);
    return failure == null
        ? Success<String, GithubApiFailure>(printed)
        : Failure<String, GithubApiFailure>(failure!);
  }
}
