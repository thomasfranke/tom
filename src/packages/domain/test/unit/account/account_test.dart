import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const AccountChoiceService choice = AccountChoiceService();
  const GithubAccountValueObject ada = GithubAccountValueObject(
    login: 'ada',
    source: AccountSourceEnum.gh,
  );
  const GithubAccountValueObject grace = GithubAccountValueObject(
    login: 'grace',
    source: AccountSourceEnum.ssh,
  );

  group('what GitHub grants, column by column', () {
    test('pull alone is reading and nothing else', () {
      expect(
        RepositoryAccessValueObject.granted(
          pull: true,
          push: false,
          admin: false,
        ),
        const RepositoryAccessValueObject(
          canRead: true,
          canOpenPullRequests: false,
          canPush: false,
          canMerge: false,
          canAdminister: false,
        ),
      );
    });

    test('push carries the pull request and the merge with it', () {
      final RepositoryAccessValueObject access =
          RepositoryAccessValueObject.granted(
            pull: true,
            push: true,
            admin: false,
          );

      expect(access.canOpenPullRequests, isTrue);
      expect(access.canMerge, isTrue);
      expect(access.canAdminister, isFalse);
    });

    test('admin is every column', () {
      final RepositoryAccessValueObject access =
          RepositoryAccessValueObject.granted(
            pull: false,
            push: false,
            admin: true,
          );

      expect(<bool>[
        access.canRead,
        access.canOpenPullRequests,
        access.canPush,
        access.canMerge,
        access.canAdminister,
      ], everyElement(isTrue));
    });
  });

  group('which account a repository is used with', () {
    test('the recorded login, when the machine still holds it', () {
      expect(
        choice.recorded(<GithubAccountValueObject>[ada, grace], 'grace'),
        grace,
      );
      expect(choice.recorded(<GithubAccountValueObject>[ada], 'grace'), isNull);
      expect(choice.recorded(<GithubAccountValueObject>[ada], null), isNull);
    });

    test('else the first that may push, asking no further', () async {
      final List<String> asked = <String>[];

      final GithubAccountValueObject? chosen = await choice.fallback(
        <GithubAccountValueObject>[ada, grace],
        (GithubAccountValueObject account) async {
          asked.add(account.login);
          return true;
        },
      );

      expect(chosen, ada);
      expect(asked, <String>['ada']);
    });

    test('else the first, and none without accounts', () async {
      Future<bool> never(GithubAccountValueObject _) async => false;

      expect(
        await choice.fallback(<GithubAccountValueObject>[grace, ada], never),
        grace,
      );
      expect(
        await choice.fallback(const <GithubAccountValueObject>[], never),
        isNull,
      );
    });

    test('the whole rule asks nothing when a login was recorded', () async {
      final List<String> asked = <String>[];
      Future<bool> canPush(GithubAccountValueObject account) async {
        asked.add(account.login);
        return true;
      }

      expect(
        await choice.choose(
          <GithubAccountValueObject>[ada, grace],
          'grace',
          canPush,
        ),
        grace,
      );
      expect(asked, isEmpty);
      expect(
        await choice.choose(<GithubAccountValueObject>[ada], 'gone', canPush),
        ada,
      );
    });
  });

  group('the rest of the vocabulary', () {
    test('only SSH holds no token', () {
      expect(AccountSourceEnum.gh.holdsToken, isTrue);
      expect(AccountSourceEnum.git.holdsToken, isTrue);
      expect(AccountSourceEnum.ssh.holdsToken, isFalse);
    });

    test('an identity missing either half is incomplete', () {
      expect(const CommitIdentityValueObject(name: 'Ada').isIncomplete, isTrue);
      expect(
        const CommitIdentityValueObject(
          name: 'Ada',
          email: 'ada@x.org',
        ).isIncomplete,
        isFalse,
      );
    });

    test('a project names itself and its page', () {
      final RemoteProjectValueObject project =
          RemoteProjectValueObject.tryParse('git@github.com:acme/docs.git')!;

      expect(project.label, 'github.com/acme/docs');
      expect(project.page, Uri.parse('https://github.com/acme/docs'));
    });
  });
}
