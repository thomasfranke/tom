import 'package:test/test.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const GithubAccountParser parser = GithubAccountParser();

  group("gh's accounts", () {
    test('the JSON report, the active account first', () {
      // `gh auth status --json hosts`, gh 2.102.
      const String report =
          '{"hosts":{"github.com":['
          '{"state":"success","active":false,"host":"github.com",'
          '"login":"grace","tokenSource":"keyring","gitProtocol":"https"},'
          '{"state":"success","active":true,"host":"github.com",'
          '"login":"ada","tokenSource":"keyring","scopes":"repo",'
          '"gitProtocol":"https"}]}}';

      expect(parser.ghLogins(report, 'github.com'), <String>['ada', 'grace']);
    });

    test('another host is not this one', () {
      const String report =
          '{"hosts":{"ghe.example.com":[{"login":"ada","active":true}]}}';

      expect(parser.ghLogins(report, 'github.com'), isEmpty);
    });

    test('the text report of a gh from before --json, both wordings', () {
      const String report = '''
github.com
  ✓ Logged in to github.com account ada (keyring)
  - Active account: true
  ✓ Logged in to github.com as grace (oauth_token)
''';

      expect(parser.ghLogins(report, 'github.com'), <String>['ada', 'grace']);
    });

    test('nothing gh says is nothing, never a throw', () {
      expect(parser.ghLogins('', 'github.com'), isEmpty);
      expect(parser.ghLogins('{"hosts":[]}', 'github.com'), isEmpty);
      expect(
        parser.ghLogins('You are not logged into any GitHub hosts.', 'x'),
        isEmpty,
      );
    });
  });

  group("git's credential", () {
    test('the password is the token', () {
      expect(
        parser.credentialToken(
          'protocol=https\nhost=github.com\nusername=ada\npassword=gho_abc\n',
        ),
        'gho_abc',
      );
    });

    test('an answer without one carries none', () {
      expect(parser.credentialToken('protocol=https\nhost=github.com\n'), null);
      expect(parser.credentialToken('password=\n'), isNull);
    });

    test('the username is the login, when it can be one', () {
      expect(parser.credentialLogin('username=ada-l\npassword=x\n'), 'ada-l');
      expect(parser.credentialLogin('username=x-access-token\n'), isNull);
      expect(parser.credentialLogin('username=ada@example.com\n'), isNull);
      expect(parser.credentialLogin('password=x\n'), isNull);
    });
  });

  group("ssh's greeting", () {
    test('GitHub greets a key by its login', () {
      expect(
        parser.sshLogin(
          "Hi ada-l! You've successfully authenticated, but GitHub does not "
          'provide shell access.',
        ),
        'ada-l',
      );
    });

    test('a refusal, or a deploy key, is no login', () {
      expect(parser.sshLogin('git@github.com: Permission denied.'), isNull);
      expect(
        parser.sshLogin("Hi acme/docs! You've successfully authenticated"),
        isNull,
      );
    });
  });

  group("GitHub's answers", () {
    test('the permissions of GET /repos', () {
      expect(
        parser.access(
          '{"full_name":"acme/docs","permissions":{"admin":false,'
          '"maintain":false,"push":true,"triage":true,"pull":true},'
          '"role_name":"write"}',
        ),
        RepositoryAccessValueObject.granted(
          pull: true,
          push: true,
          admin: false,
        ),
      );
    });

    test('an answer without permissions grants nothing known', () {
      expect(parser.access('{"full_name":"acme/docs"}'), isNull);
    });
  });
}
