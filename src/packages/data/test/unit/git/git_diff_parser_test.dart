import 'package:test/test.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const GitDiffParser parser = GitDiffParser();
  const String nul = '\u0000';

  test('the two diffs are joined by path, in git’s order', () {
    expect(
      parser.parse(
        nameStatus: 'M${nul}a.md${nul}A${nul}docs/b.md${nul}D${nul}c.md$nul',
        numstat: '3\t1\ta.md${nul}10\t0\tdocs/b.md${nul}0\t7\tc.md$nul',
      ),
      <BranchChangeValueObject>[
        BranchChangeValueObject(
          path: RepoRelativePathValueObject('a.md'),
          state: FileStateEnum.modified,
          added: 3,
          removed: 1,
        ),
        BranchChangeValueObject(
          path: RepoRelativePathValueObject('docs/b.md'),
          state: FileStateEnum.added,
          added: 10,
          removed: 0,
        ),
        BranchChangeValueObject(
          path: RepoRelativePathValueObject('c.md'),
          state: FileStateEnum.deleted,
          added: 0,
          removed: 7,
        ),
      ],
    );
  });

  test('a binary file keeps null counts, and a type change is modified', () {
    expect(
      parser.parse(
        nameStatus: 'T${nul}logo.png$nul',
        numstat: '-\t-\tlogo.png$nul',
      ),
      <BranchChangeValueObject>[
        BranchChangeValueObject(
          path: RepoRelativePathValueObject('logo.png'),
          state: FileStateEnum.modified,
        ),
      ],
    );
  });

  test('nothing changed is an empty list', () {
    expect(parser.parse(nameStatus: '', numstat: ''), isEmpty);
  });
}
