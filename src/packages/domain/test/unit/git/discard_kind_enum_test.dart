import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  DiscardKindEnum? kindOf(FileStateEnum state, {bool isStaged = false}) =>
      DiscardKindEnum.of(
        StatusEntryValueObject(
          path: RepoRelativePathValueObject('a.md'),
          state: state,
          isStaged: isStaged,
        ),
      );

  test('a row in CHANGES goes back to what is staged', () {
    expect(kindOf(FileStateEnum.modified), DiscardKindEnum.toStaged);
    expect(kindOf(FileStateEnum.deleted), DiscardKindEnum.toStaged);
  });

  test('a row in STAGED goes back to the last commit', () {
    for (final FileStateEnum state in <FileStateEnum>[
      FileStateEnum.modified,
      FileStateEnum.deleted,
      FileStateEnum.renamed,
    ]) {
      expect(kindOf(state, isStaged: true), DiscardKindEnum.toLastCommit);
    }
  });

  test('a file git never committed is deleted, staged or not', () {
    expect(kindOf(FileStateEnum.untracked), DiscardKindEnum.delete);
    expect(kindOf(FileStateEnum.added, isStaged: true), DiscardKindEnum.delete);
  });

  test('a conflicted file offers nothing', () {
    expect(kindOf(FileStateEnum.conflicted), isNull);
    expect(kindOf(FileStateEnum.conflicted, isStaged: true), isNull);
  });
}
