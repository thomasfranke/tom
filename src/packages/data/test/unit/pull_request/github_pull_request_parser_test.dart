import 'package:test/test.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const GithubPullRequestParser parser = GithubPullRequestParser();

  group('gh pr list', () {
    test('an entry is a number, an address and a title', () {
      expect(
        parser.openPullRequests(
          '[{"number":123,"title":"Release notes",'
          '"url":"https://github.com/acme/docs/pull/123"}]\n',
        ),
        <OpenedPullRequestValueObject>[
          OpenedPullRequestValueObject(
            number: 123,
            address: Uri.parse('https://github.com/acme/docs/pull/123'),
            title: 'Release notes',
          ),
        ],
      );
    });

    test('none is an empty list', () {
      expect(parser.openPullRequests('[]\n'), isEmpty);
    });

    test('what it cannot read is none, never a throw', () {
      expect(parser.openPullRequests('not json'), isEmpty);
      expect(parser.openPullRequests('{"number":1}'), isEmpty);
      expect(
        parser.openPullRequests('[{"number":"1","url":"x","title":"t"}]'),
        isEmpty,
      );
    });
  });

  group('gh pr create', () {
    test('the printed address names the number', () {
      final OpenedPullRequestValueObject? created = parser.created(
        'https://github.com/acme/docs/pull/7\n',
        'Release notes',
      );

      expect(created?.number, 7);
      expect(
        created?.address,
        Uri.parse('https://github.com/acme/docs/pull/7'),
      );
      expect(created?.title, 'Release notes');
    });

    test('an address that names no pull request is none', () {
      expect(parser.created('https://github.com/acme/docs', 't'), isNull);
      expect(parser.created('', 't'), isNull);
    });
  });
}
