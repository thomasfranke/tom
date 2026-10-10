import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const PullRequestDraftService drafts = PullRequestDraftService();

  CommitEntity commit(String subject) => CommitEntity(
    sha: CommitShaValueObject('a' * 40),
    author: const AuthorValueObject(name: 'Ana', email: 'ana@example.com'),
    date: CommitDateValueObject(utc: DateTime.utc(2026), offset: Duration.zero),
    subject: subject,
    body: '',
  );

  group('seeding a draft from git', () {
    test('the first commit is the heading, the rest a list, oldest first', () {
      // Newest first, as `log` gives them.
      final String seeded = drafts.seed(<CommitEntity>[
        commit('third'),
        commit('second'),
        commit('first'),
      ]);

      expect(seeded, '# first\n\n- second\n- third\n');
    });

    test('one commit is a heading with nothing under it', () {
      expect(drafts.seed(<CommitEntity>[commit('only')]), '# only\n');
    });

    test('no commit is an empty heading, which has no title', () {
      final String seeded = drafts.seed(const <CommitEntity>[]);

      expect(drafts.title(seeded), isNull);
    });
  });

  group('the title is the first heading', () {
    test('a level-one heading on the first line is the title', () {
      expect(drafts.title('# Close the cycle\n\nWhy.'), 'Close the cycle');
    });

    test('blank lines before it do not hide it', () {
      expect(drafts.title('\n\n# Close it\n'), 'Close it');
    });

    test('closing hashes are not part of the title', () {
      expect(drafts.title('# Close it ##\n'), 'Close it');
    });

    test('a draft that starts with prose has no title', () {
      expect(drafts.title('Why.\n# Later'), isNull);
    });

    test('a level-two heading is not a title', () {
      expect(drafts.title('## What\n'), isNull);
    });
  });

  group('the body is everything after the title', () {
    test('trimmed, and without the heading', () {
      expect(drafts.body('# Close it\n\nWhy.\n\n- a\n'), 'Why.\n\n- a');
    });

    test('a draft with no title hands over the whole text', () {
      expect(drafts.body('Just prose.\n'), 'Just prose.');
    });
  });
}
