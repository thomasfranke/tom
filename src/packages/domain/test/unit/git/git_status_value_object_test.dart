import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  GitStatusValueObject statusWith({
    BranchNameValueObject? branch,
    List<StatusEntryValueObject> entries = const <StatusEntryValueObject>[],
    bool isDetached = false,
  }) => GitStatusValueObject(
    branch: branch,
    upstream: null,
    ahead: 0,
    behind: 0,
    entries: entries,
    isDetached: isDetached,
  );

  StatusEntryValueObject entry({bool isStaged = false}) =>
      StatusEntryValueObject(
        path: RepoRelativePathValueObject('a.md'),
        state: FileStateEnum.modified,
        isStaged: isStaged,
      );

  group('isDetached', () {
    test('a branch means attached', () {
      expect(
        statusWith(branch: BranchNameValueObject('main')).isDetached,
        isFalse,
      );
    });

    test('detachment is told, not inferred from a missing branch', () {
      expect(statusWith(isDetached: true).isDetached, isTrue);
    });

    test('a branch this version cannot name is still not detached', () {
      expect(statusWith().branch, isNull);
      expect(statusWith().isDetached, isFalse);
    });

    test('a named branch cannot also be detached', () {
      expect(
        () =>
            statusWith(branch: BranchNameValueObject('main'), isDetached: true),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('isClean', () {
    test('nothing differs', () {
      expect(statusWith(branch: BranchNameValueObject('main')).isClean, isTrue);
    });

    test('something differs', () {
      expect(
        statusWith(
          branch: BranchNameValueObject('main'),
          entries: <StatusEntryValueObject>[entry()],
        ).isClean,
        isFalse,
      );
    });
  });

  group('hasStagedChanges', () {
    test('false when the only change is in the working tree', () {
      expect(
        statusWith(entries: <StatusEntryValueObject>[entry()]).hasStagedChanges,
        isFalse,
      );
    });

    test('true when one entry is staged among many that are not', () {
      expect(
        statusWith(
          entries: <StatusEntryValueObject>[
            entry(),
            entry(isStaged: true),
            entry(),
          ],
        ).hasStagedChanges,
        isTrue,
      );
    });

    test('false when nothing differs at all', () {
      expect(statusWith().hasStagedChanges, isFalse);
    });
  });

  group('discardable', () {
    StatusEntryValueObject at(
      String path,
      FileStateEnum state, {
      bool isStaged = false,
    }) => StatusEntryValueObject(
      path: RepoRelativePathValueObject(path),
      state: state,
      isStaged: isStaged,
    );

    test('counts what goes back to the last commit, each path once', () {
      expect(
        statusWith(
          entries: <StatusEntryValueObject>[
            at('a.md', FileStateEnum.modified, isStaged: true),
            at('a.md', FileStateEnum.modified),
            at('b.md', FileStateEnum.deleted),
            at('c.md', FileStateEnum.renamed, isStaged: true),
          ],
        ).discardable,
        3,
      );
    });

    test('leaves out what git never committed', () {
      expect(
        statusWith(
          entries: <StatusEntryValueObject>[
            at('new.md', FileStateEnum.untracked),
            at('added.md', FileStateEnum.added, isStaged: true),
          ],
        ).discardable,
        0,
      );
    });
  });

  group('hasNothingAtHead', () {
    StatusEntryValueObject at(
      String path,
      FileStateEnum state, {
      bool isStaged = false,
    }) => StatusEntryValueObject(
      path: RepoRelativePathValueObject(path),
      state: state,
      isStaged: isStaged,
    );

    test('is true for untracked, added and renamed paths', () {
      final GitStatusValueObject status = statusWith(
        entries: <StatusEntryValueObject>[
          at('u.md', FileStateEnum.untracked),
          at('a.md', FileStateEnum.added, isStaged: true),
          at('r.md', FileStateEnum.renamed, isStaged: true),
        ],
      );

      for (final String name in <String>['u.md', 'a.md', 'r.md']) {
        expect(
          status.hasNothingAtHead(RepoRelativePathValueObject(name)),
          true,
        );
      }
    });

    test('is false for committed paths, whatever happened to them', () {
      final GitStatusValueObject status = statusWith(
        entries: <StatusEntryValueObject>[
          at('m.md', FileStateEnum.modified),
          at('d.md', FileStateEnum.deleted),
          at('c.md', FileStateEnum.conflicted),
        ],
      );

      for (final String name in <String>['m.md', 'd.md', 'c.md', 'other.md']) {
        expect(
          status.hasNothingAtHead(RepoRelativePathValueObject(name)),
          false,
        );
      }
    });
  });

  test('two statuses with the same content are equal', () {
    expect(
      statusWith(
        branch: BranchNameValueObject('main'),
        entries: <StatusEntryValueObject>[entry()],
      ),
      statusWith(
        branch: BranchNameValueObject('main'),
        entries: <StatusEntryValueObject>[entry()],
      ),
    );
  });
}
