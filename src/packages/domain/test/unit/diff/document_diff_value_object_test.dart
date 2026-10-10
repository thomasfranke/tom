import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  test('a deleted document is every block removed, and nothing after', () {
    const BlockValueObject heading = BlockValueObject(
      startLine: 0,
      endLine: 0,
      source: '# Gone',
      kind: BlockKindEnum.heading,
    );
    const BlockValueObject prose = BlockValueObject(
      startLine: 2,
      endLine: 2,
      source: 'It was here.',
      kind: BlockKindEnum.paragraph,
    );
    final ParsedDocumentValueObject last = ParsedDocumentValueObject(
      document: DocumentEntity(
        path: SpaceRelativePathValueObject('old.md'),
        content: '# Gone\n\nIt was here.\n',
      ),
      blocks: <BlockValueObject>[heading, prose],
      linkDefinitions: '[a]: https://example.com',
    );

    final DocumentDiffValueObject diff = DocumentDiffValueObject.deleted(last);

    expect(diff.before, last);
    expect(diff.blocks, <DiffBlockValueObject>[
      const DiffBlockValueObject.removed(heading),
      const DiffBlockValueObject.removed(prose),
    ]);
    expect(diff.after.blocks, isEmpty);
    expect(diff.after.document.content, isEmpty);
    expect(diff.after.document.path, last.document.path);
    expect(diff.isUnchanged, isFalse);
  });
}
