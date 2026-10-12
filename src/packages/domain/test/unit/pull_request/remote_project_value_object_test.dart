import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('reading a remote address', () {
    for (final (String address, RemoteHostEnum host, String path)
        in <(String, RemoteHostEnum, String)>[
          (
            'https://github.com/acme/docs.git',
            RemoteHostEnum.github,
            'acme/docs',
          ),
          ('https://github.com/acme/docs', RemoteHostEnum.github, 'acme/docs'),
          ('git@github.com:acme/docs.git', RemoteHostEnum.github, 'acme/docs'),
          (
            'ssh://git@github.com:22/acme/docs.git',
            RemoteHostEnum.github,
            'acme/docs',
          ),
          (
            'https://someone@gitlab.com/group/sub/docs.git',
            RemoteHostEnum.gitlab,
            'group/sub/docs',
          ),
          (
            'git@bitbucket.org:team/docs.git',
            RemoteHostEnum.bitbucket,
            'team/docs',
          ),
        ]) {
      test('$address is $path on ${host.label}', () {
        expect(
          RemoteProjectValueObject.tryParse(address),
          RemoteProjectValueObject(host: host, path: path),
        );
      });
    }

    test('a host nobody named is no project, so no action is drawn', () {
      expect(
        RemoteProjectValueObject.tryParse('https://git.acme.dev/docs.git'),
        isNull,
      );
      expect(RemoteProjectValueObject.tryParse('/srv/git/docs.git'), isNull);
      expect(RemoteProjectValueObject.tryParse(''), isNull);
    });

    test('an address with no owner is not a project', () {
      expect(
        RemoteProjectValueObject.tryParse('https://github.com/docs'),
        isNull,
      );
    });
  });

  group('the compare page', () {
    final BranchNameValueObject base = BranchNameValueObject('main');
    final BranchNameValueObject head = BranchNameValueObject('feat/diff');

    test('GitHub compares the branch onto the base, title and body filled', () {
      final Uri page = const RemoteProjectValueObject(
        host: RemoteHostEnum.github,
        path: 'acme/docs',
      ).compare(base: base, head: head, title: 'Close it', body: 'Why & how');

      expect(page.host, 'github.com');
      expect(page.path, '/acme/docs/compare/main...feat/diff');
      expect(page.queryParameters, <String, String>{
        'expand': '1',
        'title': 'Close it',
        'body': 'Why & how',
      });
    });

    test('GitLab names the two branches and the description', () {
      final Uri page = const RemoteProjectValueObject(
        host: RemoteHostEnum.gitlab,
        path: 'group/docs',
      ).compare(base: base, head: head, title: 'Close it', body: 'Body');

      expect(page.path, '/group/docs/-/merge_requests/new');
      expect(page.queryParameters['merge_request[source_branch]'], 'feat/diff');
      expect(page.queryParameters['merge_request[target_branch]'], 'main');
      expect(page.queryParameters['merge_request[title]'], 'Close it');
      expect(page.queryParameters['merge_request[description]'], 'Body');
    });

    test('Bitbucket carries the branches and nothing else', () {
      final Uri page = const RemoteProjectValueObject(
        host: RemoteHostEnum.bitbucket,
        path: 'team/docs',
      ).compare(base: base, head: head, title: 'Close it');

      expect(page.queryParameters, <String, String>{
        'source': 'feat/diff',
        'dest': 'main',
      });
    });

    test('a description too long for an address stays in the draft', () {
      final Uri page =
          const RemoteProjectValueObject(
            host: RemoteHostEnum.github,
            path: 'acme/docs',
          ).compare(
            base: base,
            head: head,
            title: 'Close it',
            body: 'x' * (RemoteProjectValueObject.bodyBudget + 1),
          );

      expect(page.queryParameters.containsKey('body'), isFalse);
      expect(page.queryParameters['title'], 'Close it');
    });

    test('the budget is measured encoded: CJK runs out nine times sooner', () {
      final Uri page = const RemoteProjectValueObject(
        host: RemoteHostEnum.github,
        path: 'acme/docs',
      ).compare(base: base, head: head, title: 'T', body: '文' * 700);

      expect(page.queryParameters.containsKey('body'), isFalse);
    });
  });
}
