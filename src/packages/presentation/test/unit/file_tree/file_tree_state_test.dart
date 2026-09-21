import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  /// A folder at [path].
  SpaceEntry folder(String path) =>
      SpaceEntry(path: SpaceRelativePath(path), type: SpaceEntryType.directory);

  /// A file at [path].
  SpaceEntry file(String path) =>
      SpaceEntry(path: SpaceRelativePath(path), type: SpaceEntryType.file);

  /// The space of the wireframe, in the order a walk reports it: a folder
  /// immediately followed by what is inside it.
  final List<SpaceEntry> space = <SpaceEntry>[
    folder('guides'),
    file('guides/reviewing.md'),
    folder('guides/deep'),
    file('guides/deep/note.md'),
    file('index.md'),
  ];

  /// The tree showing [space] with [collapsed] closed.
  List<FileTreeRow> rowsWith(Set<String> collapsed) =>
      (FileTreeState.ready(
                entries: space,
                collapsed: <SpaceRelativePath>{
                  for (final String path in collapsed) SpaceRelativePath(path),
                },
              )
              as FileTreeReady)
          .rows;

  /// What the tree is showing, by path.
  List<String> pathsWith(Set<String> collapsed) => <String>[
    for (final FileTreeRow row in rowsWith(collapsed)) row.entry.path.value,
  ];

  group('with everything open', () {
    test('every entry is a row, in the order the walk reported it', () {
      expect(pathsWith(const <String>{}), <String>[
        'guides',
        'guides/reviewing.md',
        'guides/deep',
        'guides/deep/note.md',
        'index.md',
      ]);
    });

    test('depth comes from the path, not from the walk', () {
      expect(
        <int>[
          for (final FileTreeRow row in rowsWith(const <String>{})) row.depth,
        ],
        <int>[0, 1, 1, 2, 0],
      );
    });

    test('only a folder is expandable, and an open one says so', () {
      final List<FileTreeRow> rows = rowsWith(const <String>{});

      expect(rows.first.isFolder, isTrue);
      expect(rows.first.isExpanded, isTrue);
      // A file has nothing to expand: the chevron is absent, not pointing
      // somewhere.
      expect(rows.last.isFolder, isFalse);
      expect(rows.last.isExpanded, isFalse);
    });
  });

  group('with a folder closed', () {
    test('what is inside it goes, and what follows stays', () {
      expect(pathsWith(const <String>{'guides'}), <String>[
        'guides',
        'index.md',
      ]);
    });

    test('the folder itself is still drawn, closed', () {
      final FileTreeRow row = rowsWith(const <String>{'guides'}).first;

      expect(row.isFolder, isTrue);
      expect(row.isExpanded, isFalse);
    });

    test('a folder closed inside a closed one changes nothing', () {
      // The prefix test skips the whole subtree, so the inner state is
      // invisible until the outer folder opens — and is still remembered.
      expect(pathsWith(const <String>{'guides', 'guides/deep'}), <String>[
        'guides',
        'index.md',
      ]);
      expect(pathsWith(const <String>{'guides/deep'}), <String>[
        'guides',
        'guides/reviewing.md',
        'guides/deep',
        'index.md',
      ]);
    });

    test('a folder whose name is a prefix of a sibling is not swept up', () {
      // `guides-old` starts with `guides`, and is a different folder.
      final FileTreeReady state =
          FileTreeState.ready(
                entries: <SpaceEntry>[
                  folder('guides'),
                  file('guides/reviewing.md'),
                  folder('guides-old'),
                  file('guides-old/kept.md'),
                ],
                collapsed: <SpaceRelativePath>{SpaceRelativePath('guides')},
              )
              as FileTreeReady;

      expect(
        <String>[
          for (final FileTreeRow row in state.rows) row.entry.path.value,
        ],
        <String>['guides', 'guides-old', 'guides-old/kept.md'],
      );
    });
  });

  test('an empty space has no rows and is not an error', () {
    const FileTreeReady state =
        FileTreeState.ready(
              entries: <SpaceEntry>[],
              collapsed: <SpaceRelativePath>{},
            )
            as FileTreeReady;

    expect(state.rows, isEmpty);
  });
}
