import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  /// A space opened *at* the repository: every path git names is in it.
  final SpaceEntity wholeRepo = SpaceEntity(
    root: '/code/app',
    repositoryRoot: '/code/app',
    name: 'app',
  );

  /// A space opened at `docs/` inside a bigger repository.
  final SpaceEntity docsOnly = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  GitStatusValueObject statusOf(Map<String, FileStateEnum> paths) =>
      GitStatusValueObject(
        branch: BranchNameValueObject('main'),
        upstream: null,
        ahead: 0,
        behind: 0,
        isDetached: false,
        entries: <StatusEntryValueObject>[
          for (final MapEntry<String, FileStateEnum> each in paths.entries)
            StatusEntryValueObject(
              path: RepoRelativePathValueObject(each.key),
              state: each.value,
              isStaged: false,
            ),
        ],
      );

  SpaceRelativePathValueObject at(String path) =>
      SpaceRelativePathValueObject(path);

  test('nothing read yet is nothing to draw', () {
    final FileTreeChanges changes = FileTreeChanges.of(wholeRepo, null);

    expect(changes.isEmpty, isTrue);
    expect(changes.stateOf(at('README.md')), isNull);
  });

  test('a changed file carries its state', () {
    final FileTreeChanges changes = FileTreeChanges.of(
      wholeRepo,
      statusOf(<String, FileStateEnum>{'README.md': FileStateEnum.modified}),
    );

    expect(changes.stateOf(at('README.md')), FileStateEnum.modified);
    expect(changes.stateOf(at('other.md')), isNull);
  });

  test('every folder above a changed file holds a change', () {
    final FileTreeChanges changes = FileTreeChanges.of(
      wholeRepo,
      statusOf(<String, FileStateEnum>{
        'docs/guides/writing.md': FileStateEnum.added,
      }),
    );

    expect(changes.holdsChange(at('docs')), isTrue);
    expect(changes.holdsChange(at('docs/guides')), isTrue);
    expect(changes.holdsChange(at('lib')), isFalse);
  });

  test('a file is not its own folder', () {
    final FileTreeChanges changes = FileTreeChanges.of(
      wholeRepo,
      statusOf(<String, FileStateEnum>{'README.md': FileStateEnum.modified}),
    );

    expect(changes.holdsChange(at('README.md')), isFalse);
  });

  group('a space opened inside a repository', () {
    test('a path inside it is reported against the space root', () {
      final FileTreeChanges changes = FileTreeChanges.of(
        docsOnly,
        statusOf(<String, FileStateEnum>{
          'docs/index.md': FileStateEnum.modified,
        }),
      );

      expect(changes.stateOf(at('index.md')), FileStateEnum.modified);
    });

    test('a path outside it is dropped rather than drawn', () {
      // Git reports the whole repository; the tree shows one folder.
      final FileTreeChanges changes = FileTreeChanges.of(
        docsOnly,
        statusOf(<String, FileStateEnum>{
          'lib/main.dart': FileStateEnum.modified,
        }),
      );

      expect(changes.isEmpty, isTrue, reason: 'the tree has no row for it');
      expect(changes.holdsChange(at('lib')), isFalse);
    });

    test('an outside path does not mark a folder that shares its name', () {
      final FileTreeChanges changes = FileTreeChanges.of(
        docsOnly,
        statusOf(<String, FileStateEnum>{
          'lib/guides/thing.dart': FileStateEnum.modified,
          'docs/guides/writing.md': FileStateEnum.modified,
        }),
      );

      expect(changes.holdsChange(at('guides')), isTrue);
      expect(changes.stateOf(at('guides/writing.md')), FileStateEnum.modified);
      expect(changes.stateOf(at('guides/thing.dart')), isNull);
    });
  });

  test('every state git reports reaches the tree', () {
    final FileTreeChanges changes = FileTreeChanges.of(
      wholeRepo,
      statusOf(<String, FileStateEnum>{
        'a.md': FileStateEnum.modified,
        'b.md': FileStateEnum.added,
        'c.md': FileStateEnum.deleted,
        'd.md': FileStateEnum.renamed,
        'e.md': FileStateEnum.untracked,
        'f.md': FileStateEnum.conflicted,
      }),
    );

    expect(changes.stateOf(at('e.md')), FileStateEnum.untracked);
    expect(changes.stateOf(at('f.md')), FileStateEnum.conflicted);
  });
}
