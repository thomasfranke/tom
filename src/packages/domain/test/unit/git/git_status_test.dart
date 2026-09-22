import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  GitStatus statusWith({
    BranchName? branch,
    List<StatusEntry> entries = const <StatusEntry>[],
    bool isDetached = false,
  }) => GitStatus(
    branch: branch,
    upstream: null,
    ahead: 0,
    behind: 0,
    entries: entries,
    isDetached: isDetached,
  );

  StatusEntry entry({bool isStaged = false}) => StatusEntry(
    path: RepoRelativePath('a.md'),
    state: FileStateEnum.modified,
    isStaged: isStaged,
  );

  group('isDetached', () {
    test('a branch means attached', () {
      expect(statusWith(branch: BranchName('main')).isDetached, isFalse);
    });

    test('detachment is told, not inferred from a missing branch', () {
      expect(statusWith(isDetached: true).isDetached, isTrue);
    });

    test('a branch this version cannot name is still not detached', () {
      // Two different answers used to share one null: a name the parser
      // could not read reported a detached HEAD, which would put a warning
      // on a repository sitting on an ordinary branch.
      expect(statusWith().branch, isNull);
      expect(statusWith().isDetached, isFalse);
    });

    test('a named branch cannot also be detached', () {
      expect(
        () => statusWith(branch: BranchName('main'), isDetached: true),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('isClean', () {
    test('nothing differs', () {
      expect(statusWith(branch: BranchName('main')).isClean, isTrue);
    });

    test('something differs', () {
      expect(
        statusWith(
          branch: BranchName('main'),
          entries: <StatusEntry>[entry()],
        ).isClean,
        isFalse,
      );
    });
  });

  group('hasStagedChanges', () {
    test('false when the only change is in the working tree', () {
      // What the commit button reads: a dirty tree with an empty index has
      // nothing to record (docs/product/git-workflow/commit/doc.md).
      expect(
        statusWith(entries: <StatusEntry>[entry()]).hasStagedChanges,
        isFalse,
      );
    });

    test('true when one entry is staged among many that are not', () {
      expect(
        statusWith(
          entries: <StatusEntry>[entry(), entry(isStaged: true), entry()],
        ).hasStagedChanges,
        isTrue,
      );
    });

    test('false when nothing differs at all', () {
      expect(statusWith().hasStagedChanges, isFalse);
    });
  });

  test('two statuses with the same content are equal', () {
    expect(
      statusWith(branch: BranchName('main'), entries: <StatusEntry>[entry()]),
      statusWith(branch: BranchName('main'), entries: <StatusEntry>[entry()]),
    );
  });
}
