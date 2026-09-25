import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const String sha = 'a618609c8c58e65560ac3b7341607f93cb4e3019';

  final BranchEntity main = BranchEntity(
    name: BranchNameValueObject('main'),
    isCurrent: true,
  );
  final CommitEntity commit = CommitEntity(
    sha: CommitShaValueObject(sha),
    author: const AuthorValueObject(name: 'Test', email: 'test@example.com'),
    date: CommitDateValueObject(utc: DateTime.utc(2026), offset: Duration.zero),
    subject: 'docs: expand the index',
    body: '',
  );

  test('a branch is resolved by its name', () {
    // The name and not a sha: a branch moves, and comparing against it means
    // against wherever it stands when git is asked.
    expect(RevisionValueObject.branch(main).spec, 'main');
  });

  test('a commit is resolved by its full sha', () {
    expect(RevisionValueObject.commit(commit).spec, sha);
  });

  test('two revisions naming the same thing are the same revision', () {
    expect(RevisionValueObject.branch(main), RevisionValueObject.branch(main));
    expect(
      RevisionValueObject.branch(main),
      isNot(RevisionValueObject.commit(commit)),
    );
  });
}
