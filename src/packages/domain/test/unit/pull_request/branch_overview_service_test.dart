import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const BranchOverviewService overview = BranchOverviewService();

  BlockValueObject block(
    String source, [
    BlockKindEnum kind = BlockKindEnum.paragraph,
  ]) => BlockValueObject(startLine: 0, endLine: 0, source: source, kind: kind);

  ParsedDocumentValueObject empty() => ParsedDocumentValueObject(
    document: DocumentEntity(
      path: SpaceRelativePathValueObject('a.md'),
      content: '',
    ),
    blocks: const <BlockValueObject>[],
    linkDefinitions: '',
  );

  DocumentDiffValueObject diff(List<DiffBlockValueObject> blocks) =>
      DocumentDiffValueObject(before: empty(), after: empty(), blocks: blocks);

  CommitEntity commit(String subject, int day) => CommitEntity(
    sha: CommitShaValueObject('b' * 40),
    author: const AuthorValueObject(name: 'Ana', email: 'ana@example.com'),
    date: CommitDateValueObject(
      utc: DateTime.utc(2026, 10, day),
      offset: Duration.zero,
    ),
    subject: subject,
    body: '',
  );

  BranchChangeValueObject change(
    String path,
    FileStateEnum state, [
    int? added,
    int? removed,
  ]) => BranchChangeValueObject(
    path: RepoRelativePathValueObject(path),
    state: state,
    added: added,
    removed: removed,
  );

  group('words', () {
    test('markdown marks are not words; contractions and hyphens are one', () {
      expect(
        BranchOverviewService.words("**Don't** re-read the `code` — twice."),
        <String>["don't", 're-read', 'the', 'code', 'twice'],
      );
    });

    test(
      'a rewritten sentence costs the words it changed, not all of them',
      () {
        final BranchOverviewValueObject result = overview.summarise(
          commits: const <CommitEntity>[],
          changes: const <BranchChangeValueObject>[],
          diffs: <DocumentDiffValueObject>[
            diff(<DiffBlockValueObject>[
              DiffBlockValueObject.modified(
                before: block('The diff is drawn in lines.'),
                after: block('The diff is drawn in blocks and words.'),
              ),
            ]),
          ],
        );

        expect(result.wordsAdded, 3);
        expect(result.wordsRemoved, 1);
      },
    );

    test('added and removed blocks count whole, unchanged ones not at all', () {
      final BranchOverviewValueObject result = overview.summarise(
        commits: const <CommitEntity>[],
        changes: const <BranchChangeValueObject>[],
        diffs: <DocumentDiffValueObject>[
          diff(<DiffBlockValueObject>[
            DiffBlockValueObject.unchanged(block('Kept as it was.')),
            DiffBlockValueObject.added(block('Two new words')),
            DiffBlockValueObject.removed(block('Gone')),
          ]),
        ],
      );

      expect(result.wordsAdded, 3);
      expect(result.wordsRemoved, 1);
    });
  });

  test('blocks are counted by kind, most first', () {
    final BranchOverviewValueObject result = overview.summarise(
      commits: const <CommitEntity>[],
      changes: const <BranchChangeValueObject>[],
      diffs: <DocumentDiffValueObject>[
        diff(<DiffBlockValueObject>[
          DiffBlockValueObject.added(block('# A', BlockKindEnum.heading)),
          DiffBlockValueObject.added(block('one')),
          DiffBlockValueObject.removed(block('two')),
          DiffBlockValueObject.unchanged(block('| t |', BlockKindEnum.table)),
        ]),
      ],
    );

    expect(
      result.blocks.entries.map(
        (MapEntry<BlockKindEnum, int> e) => (e.key, e.value),
      ),
      <(BlockKindEnum, int)>[
        (BlockKindEnum.paragraph, 2),
        (BlockKindEnum.heading, 1),
      ],
    );
  });

  test(
    'git’s half: documents, folders, the most changed and the first commit',
    () {
      final BranchOverviewValueObject result = overview.summarise(
        commits: <CommitEntity>[commit('newer', 7), commit('older', 5)],
        changes: <BranchChangeValueObject>[
          change('docs/product/a.md', FileStateEnum.modified, 4, 1),
          change('docs/product/b.md', FileStateEnum.added, 40, 0),
          change('docs/design/c.md', FileStateEnum.modified, 2, 2),
          change('README.md', FileStateEnum.deleted, 0, 9),
          change('logo.png', FileStateEnum.added),
        ],
        diffs: const <DocumentDiffValueObject>[],
      );

      expect(result.commits, 2);
      expect(result.firstCommit?.utc, DateTime.utc(2026, 10, 5));
      expect((result.added, result.modified, result.deleted), (2, 2, 1));
      expect(result.folders.keys.first, 'docs/product');
      expect(result.folders['docs/product'], 2);
      expect(result.folders[''], 2);
      expect(result.mostChanged?.path.value, 'docs/product/b.md');
    },
  );

  test('reading time rounds up at two hundred words a minute', () {
    final BranchOverviewValueObject none = overview.summarise(
      commits: const <CommitEntity>[],
      changes: const <BranchChangeValueObject>[],
      diffs: const <DocumentDiffValueObject>[],
    );
    final BranchOverviewValueObject some = overview.summarise(
      commits: const <CommitEntity>[],
      changes: const <BranchChangeValueObject>[],
      diffs: <DocumentDiffValueObject>[
        diff(<DiffBlockValueObject>[
          DiffBlockValueObject.added(
            block(List<String>.filled(201, 'w').join(' ')),
          ),
        ]),
      ],
    );

    expect(none.readingMinutes, 0);
    expect(some.readingMinutes, 2);
  });
}
